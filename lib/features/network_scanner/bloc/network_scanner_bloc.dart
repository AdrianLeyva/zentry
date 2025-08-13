import 'dart:async';
import 'dart:isolate';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/features/network_scanner/bloc/network_scanner_event.dart';
import 'package:zentry/features/network_scanner/bloc/network_scanner_state.dart';
import 'package:zentry/features/network_scanner/providers/network_scanner_prompt_provider.dart';
import 'package:zentry/modules/ai/providers/ai_provider_factory.dart';
import 'package:zentry/modules/ai/services/ai_service.dart';
import 'package:zentry/modules/ai/services/ai_service_factory.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/services/network_scan_service.dart';

class NetworkScannerBloc
    extends Bloc<NetworkScannerEvent, NetworkScannerState> {
  final NetworkScanService _scanner;
  final AIService _aiService;

  NetworkScannerBloc()
      : _scanner = NetworkScanService(),
        _aiService = AiServiceFactory.networkSecurityAiService(
            AiProviderFactory.createGeminiProvider()),
        super(const NetworkScannerState()) {
    on<StartScanEvent>(_onStartScan);
    on<AnalyzeWithAiEvent>(_onAnalyzeWithAi);
  }

  Future<void> _onStartScan(
      StartScanEvent event, Emitter<NetworkScannerState> emit) async {
    emit(state.copyWith(isScanning: true, hosts: [], vulnerabilities: []));

    final scannedHosts = await _computeFullScan();
    final vulns = await _scanner.analyzeVulnerabilities(scannedHosts);

    emit(state.copyWith(
      hosts: scannedHosts,
      vulnerabilities: vulns,
      isScanning: false,
      hasScanned: true,
    ));
  }

  Future<void> _onAnalyzeWithAi(
      AnalyzeWithAiEvent event, Emitter<NetworkScannerState> emit) async {
    emit(state.copyWith(isAnalyzingWithAi: true));

    final prompt = NetworkScannerPromptProvider.buildAnalysisPrompt(
        state.hosts, state.vulnerabilities);
    final aiResponse = await _aiService.processPrompt(prompt);

    emit(state.copyWith(
      isAnalyzingWithAi: false,
      aiAnalysisResult: aiResponse.text,
      aiAnalysisMetadata: aiResponse.metadata,
    ));
  }

  Future<List<Host>> _computeFullScan() async {
    final response = ReceivePort();
    await Isolate.spawn(_fullScanEntryPoint, response.sendPort);
    return await response.first as List<Host>;
  }

  static void _fullScanEntryPoint(SendPort sendPort) async {
    final scanner = NetworkScanService();
    final hosts = await scanner.fullScan();
    sendPort.send(hosts);
  }
}
