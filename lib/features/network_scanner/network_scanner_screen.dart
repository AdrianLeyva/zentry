import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:zentry/components/scanner_result_card.dart';
import 'package:zentry/components/vulnerability_result_card.dart';
import 'package:zentry/core/ui/generic_loader.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/models/vulnerability.dart';
import 'package:zentry/modules/network_scanner/services/network_scan_service.dart';

class NetworkScannerScreen extends StatefulWidget {
  const NetworkScannerScreen({super.key});

  @override
  State<NetworkScannerScreen> createState() => _NetworkScannerScreenState();
}

class _NetworkScannerScreenState extends State<NetworkScannerScreen> {
  final _scanner = NetworkScanService();
  List<Host> hosts = [];
  List<Vulnerability> vulnerabilities = [];
  bool isScanning = false;

  void _startScan() async {
    setState(() {
      isScanning = true;
      hosts.clear();
      vulnerabilities.clear();
    });

    final scannedHosts = await computeFullScan();
    final vulns = await _scanner.analyzeVulnerabilities(scannedHosts);

    setState(() {
      hosts = scannedHosts;
      vulnerabilities = vulns;
      isScanning = false;
    });
  }

  Future<List<Host>> computeFullScan() async {
    final response = ReceivePort();
    await Isolate.spawn(_fullScanEntryPoint, response.sendPort);
    return await response.first as List<Host>;
  }

  static void _fullScanEntryPoint(SendPort sendPort) async {
    final scanner = NetworkScanService();
    final hosts = await scanner.fullScan();
    sendPort.send(hosts);
  }

  @override
  Widget build(BuildContext context) {
    return GenericScaffold(
      title: "Network Scanner",
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isScanning)
                  ElevatedButton(
                    onPressed: isScanning ? null : _startScan,
                    child: Text(isScanning ? "Scanning..." : "Start Scan"),
                  ),
                const SizedBox(height: 24),
                if (!isScanning && hosts.isEmpty) const Text("No hosts found."),
                if (hosts.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        children: [
                          Text(
                            "🖥️ Discovered Hosts (${hosts.length}):",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...hosts.map((host) => ScannerResultCard(host: host)),
                          const SizedBox(height: 16),
                          Text(
                            "🛡️ Detected Vulnerabilities (${vulnerabilities.length}):",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (vulnerabilities.isEmpty)
                            const Text("No critical vulnerabilities found."),
                          ...vulnerabilities.map(
                            (v) => VulnerabilityResultCard(vulnerability: v),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isScanning)
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const GenericLoader(
                  size: 180,
                  loadingText: 'SCANNING...',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
