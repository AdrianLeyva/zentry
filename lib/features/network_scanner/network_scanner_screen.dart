import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/components/scanner_result_card.dart';
import 'package:zentry/components/vulnerability_result_card.dart';
import 'package:zentry/components/zentry_loader.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/core/ui/generic_text_dialog.dart';
import 'package:zentry/features/network_scanner/bloc/network_scanner_bloc.dart';
import 'package:zentry/features/network_scanner/bloc/network_scanner_event.dart';
import 'package:zentry/features/network_scanner/bloc/network_scanner_state.dart';

class NetworkScannerScreen extends StatelessWidget {
  const NetworkScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NetworkScannerBloc(),
      child: BlocConsumer<NetworkScannerBloc, NetworkScannerState>(
        listener: (context, state) {
          if (state.aiAnalysisResult != null) {
            showDialog(
              context: context,
              builder: (_) => GenericTextDialog(
                title: 'AI Analysis Result',
                mainText: state.aiAnalysisResult!,
                jsonData: state.aiAnalysisMetadata,
                closeButtonText: 'Close',
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<NetworkScannerBloc>();

          return GenericScaffold(
            title: "Network Scanner",
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!state.isScanning && !state.isAnalyzingWithAi)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: state.isScanning
                                      ? null
                                      : () => bloc.add(StartScanEvent()),
                                  icon: const Icon(Icons.wifi_tethering,
                                      size: 20, color: Colors.black87),
                                  label: Text(state.isScanning
                                      ? "Scanning..."
                                      : "Start Scan"),
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (state.hosts.isNotEmpty ||
                                  state.vulnerabilities.isNotEmpty)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        bloc.add(AnalyzeWithAiEvent()),
                                    icon: const Icon(Icons.smart_toy,
                                        size: 20, color: Colors.black87),
                                    label: const Text("Analyze with AI"),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (!state.isScanning && state.hosts.isEmpty)
                        const Text("No hosts found."),
                      if (state.hosts.isNotEmpty &&
                          !state.isAnalyzingWithAi &&
                          state.hasScanned)
                        Expanded(
                          child: ListView(
                            children: [
                              Text(
                                "🖥️ Discovered Hosts (${state.hosts.length}):",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...state.hosts
                                  .map((host) => ScannerResultCard(host: host)),
                              const SizedBox(height: 16),
                              Text(
                                "🛡️ Detected Vulnerabilities (${state.vulnerabilities.length}):",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (state.vulnerabilities.isEmpty)
                                const Text(
                                    "No critical vulnerabilities found."),
                              ...state.vulnerabilities.map(
                                (v) =>
                                    VulnerabilityResultCard(vulnerability: v),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (state.isScanning)
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const ZentryLoader(
                        size: 180,
                        loadingText: 'SCANNING...',
                      ),
                    ),
                  ),
                if (state.isAnalyzingWithAi)
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
        },
      ),
    );
  }
}
