import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:zentry/components/scanner_result_card.dart';
import 'package:zentry/components/vulnerability_result_card.dart';
import 'package:zentry/components/zentry_loader.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/core/ui/generic_text_dialog.dart';
import 'package:zentry/features/network_scanner/network_scanner_prompt_provider.dart';
import 'package:zentry/modules/ai/providers/ai_provider_factory.dart';
import 'package:zentry/modules/ai/services/ai_service.dart';
import 'package:zentry/modules/ai/services/ai_service_factory.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/models/vulnerability.dart';
import 'package:zentry/modules/network_scanner/services/network_scan_service.dart';

class NetworkScannerScreen extends StatefulWidget {
  const NetworkScannerScreen({super.key});

  @override
  State<NetworkScannerScreen> createState() => _NetworkScannerScreenState();
}

class _NetworkScannerScreenState extends State<NetworkScannerScreen>
    with SingleTickerProviderStateMixin {
  final _scanner = NetworkScanService();
  late final AIService _aiService;
  List<Host> hosts = [];
  List<Vulnerability> vulnerabilities = [];
  bool isScanning = false;
  bool isAnalyzingScannerResultsWithAi = false;
  bool hasScanned = false;

  late AnimationController _shadowController;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _aiService = AiServiceFactory.networkSecurityAiService(
        AiProviderFactory.createGeminiProvider());

    _shadowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shadowAnimation = Tween<double>(begin: 4, end: 14).animate(
      CurvedAnimation(parent: _shadowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shadowController.dispose();
    super.dispose();
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

    final analysisPrompt = NetworkScannerPromptProvider.buildAnalysisPrompt(
        hosts, vulnerabilities);
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isScanning ? null : _startScan,
                            icon: const Icon(Icons.wifi_tethering,
                                size: 20, color: Colors.black87),
                            label:
                                Text(isScanning ? "Scanning..." : "Start Scan"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (hosts.isNotEmpty || vulnerabilities.isNotEmpty)
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _shadowAnimation,
                              builder: (context, child) {
                                return ElevatedButton.icon(
                                  onPressed: _analyzeScannerResultsWithAi,
                                  icon: const Icon(Icons.smart_toy,
                                      size: 20, color: Colors.black87),
                                  label: const Text("Analyze with AI"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.yellow.withAlpha(204),
                                    elevation: _shadowAnimation.value,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
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
                child: const ZentryLoader(
                  size: 180,
                  loadingText: 'SCANNING...',
                ),
              ),
            ),
          if (isAnalyzingScannerResultsWithAi)
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const ZentryLoader(
                  size: 180,
                  loadingText: 'ANALYZING WITH AI...',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
