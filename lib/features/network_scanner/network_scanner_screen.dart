import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:zentry/components/scanner_result_card.dart';
import 'package:zentry/components/vulnerability_result_card.dart';
import 'package:zentry/core/ui/generic_loader.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/core/ui/generic_text_dialog.dart';
import 'package:zentry/modules/ai/providers/ai_provider_factory.dart';
import 'package:zentry/modules/ai/services/ai_service.dart';
import 'package:zentry/modules/ai/services/ai_service_factory.dart';
import 'package:zentry/modules/network_scanner/extensions/host_extensions.dart';
import 'package:zentry/modules/network_scanner/extensions/vulnerability_extensions.dart';
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
  late final AIService _aiService;
  List<Host> hosts = [];
  List<Vulnerability> vulnerabilities = [];
  bool isScanning = false;
  bool isAnalyzingScannerResultsWithAi = false;
  bool hasScanned = false;

  @override
  void initState() {
    super.initState();
    _aiService = AiServiceFactory.networkSecurityAiService(
        AiProviderFactory.createGeminiProvider());
  }

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
      hasScanned = true;
    });
  }

  void _analyzeScannerResultsWithAi() async {
    setState(() {
      isAnalyzingScannerResultsWithAi = true;
    });

    final analysisPrompt = '''
Please analyze the discovered hosts and vulnerabilities. Provide a very concise and focused summary of the findings. Be direct and to the point in your analysis, clearly identifying the vulnerabilities found, associated risks, and recommended mitigation measures. Avoid unnecessary details.

${hosts.toSummaryString()}
${vulnerabilities.toSummaryString()}
''';
    final aiResponse = await _aiService.processPrompt(analysisPrompt);

    setState(() {
      isAnalyzingScannerResultsWithAi = false;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => GenericTextDialog(
        title: 'AI Analysis Result',
        mainText: aiResponse.text,
        jsonData: aiResponse.metadata,
        closeButtonText: 'Close',
      ),
    );
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
                if (!isScanning && !isAnalyzingScannerResultsWithAi)
                  ElevatedButton(
                    onPressed: isScanning ? null : _startScan,
                    child: Text(isScanning ? "Scanning..." : "Start Scan"),
                  ),
                if (!isScanning &&
                    !isAnalyzingScannerResultsWithAi &&
                    (hosts.isNotEmpty || vulnerabilities.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ElevatedButton(
                      onPressed: _analyzeScannerResultsWithAi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text("Analyze with AI"),
                    ),
                  ),
                const SizedBox(height: 24),
                if (!isScanning && hosts.isEmpty) const Text("No hosts found."),
                if (hosts.isNotEmpty &&
                    !isAnalyzingScannerResultsWithAi &&
                    hasScanned)
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
          if (isAnalyzingScannerResultsWithAi)
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const GenericLoader(
                  size: 180,
                  loadingText: 'ANALYZING WITH AI...',
                ),
              ),
            )
        ],
      ),
    );
  }
}
