import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/features/network_scanner/providers/network_scanner_prompt_provider.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_event.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_state.dart';
import 'package:zentry/modules/ai/providers/ai_provider_factory.dart';
import 'package:zentry/modules/ai/services/ai_service.dart';
import 'package:zentry/modules/ai/services/ai_service_factory.dart';
import 'package:zentry/modules/packet_sniffer/models/packet.dart';
import 'package:zentry/modules/packet_sniffer/services/packet_sniffer.dart';

class PacketSnifferBloc extends Bloc<PacketSnifferEvent, PacketSnifferState> {
  final PacketSniffer _sniffer;
  StreamSubscription<Packet>? _subscription;
  final AIService _aiService;

  PacketSnifferBloc()
      : _sniffer = PacketSniffer(),
        _aiService = AiServiceFactory.networkSecurityAiService(
            AiProviderFactory.createGeminiProvider()),
        super(PacketSnifferState(
          isSniffing: false,
          packets: const [],
          sniffingAvailable: _checkAvailability(),
          totalPackets: 0,
        )) {
    on<StartSniffingEvent>(_onStart);
    on<StopSniffingEvent>(_onStop);
    on<PacketCapturedEvent>(_onPacketCaptured);
    on<AnalyzeWithAiEvent>(_onAnalyzeWithAi);
  }

  static bool _checkAvailability() {
    if (kIsWeb) return false;
    if (Platform.isAndroid) return true;
    return false;
  }

  Future<void> _onStart(
      StartSniffingEvent event, Emitter<PacketSnifferState> emit) async {
    if (!state.sniffingAvailable) return;
    await _sniffer.start();
    emit(state.copyWith(isSniffing: true, packets: [], totalPackets: 0));

    _subscription = _sniffer.sniffPackets().listen((packet) {
      add(PacketCapturedEvent(packet));
    });
  }

  Future<void> _onStop(
      StopSniffingEvent event, Emitter<PacketSnifferState> emit) async {
    await _subscription?.cancel();
    _subscription = null;
    await _sniffer.stop();
    emit(state.copyWith(isSniffing: false));
  }

  void _onPacketCaptured(
      PacketCapturedEvent event, Emitter<PacketSnifferState> emit) {
    final updatedPackets = [event.packet, ...state.packets];
    if (updatedPackets.length > 100) {
      updatedPackets.removeLast();
    }
    emit(state.copyWith(
      packets: updatedPackets,
      totalPackets: state.totalPackets + 1,
    ));
  }

  Future<void> _onAnalyzeWithAi(
      AnalyzeWithAiEvent event, Emitter<PacketSnifferState> emit) async {
    emit(state.copyWith(isAnalyzingWithAi: true));

    final prompt =
        NetworkScannerPromptProvider.buildAnalysisPacketSnifferPrompt(
            state.packets);

    final aiResponse = await _aiService.processPrompt(prompt);
    emit(state.copyWith(
      isAnalyzingWithAi: false,
      aiAnalysisResult: aiResponse.text,
      aiAnalysisMetadata: aiResponse.metadata,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
