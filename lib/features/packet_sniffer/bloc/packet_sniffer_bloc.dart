import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_event.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_state.dart';
import 'package:zentry/modules/packet_sniffer/models/packet.dart';
import 'package:zentry/modules/packet_sniffer/services/packet_sniffer.dart';

class PacketSnifferBloc extends Bloc<PacketSnifferEvent, PacketSnifferState> {
  final PacketSniffer _sniffer;
  StreamSubscription<Packet>? _subscription;

  PacketSnifferBloc()
      : _sniffer = PacketSniffer(),
        super(PacketSnifferState(
          isSniffing: false,
          packets: const [],
          sniffingAvailable: _checkAvailability(),
        )) {
    on<StartSniffingEvent>(_onStart);
    on<StopSniffingEvent>(_onStop);
    on<PacketCapturedEvent>(_onPacketCaptured);
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
    emit(state.copyWith(isSniffing: true));

    _subscription = _sniffer.sniffPackets().listen((packet) {
      add(PacketCapturedEvent(packet));
    });
  }

  Future<void> _onStop(
      StopSniffingEvent event, Emitter<PacketSnifferState> emit) async {
    await _sniffer.stop();
    await _subscription?.cancel();
    emit(state.copyWith(isSniffing: false));
  }

  void _onPacketCaptured(
      PacketCapturedEvent event, Emitter<PacketSnifferState> emit) {
    final updatedPackets = [event.packet, ...state.packets];
    if (updatedPackets.length > 100) {
      updatedPackets.removeLast();
    }
    emit(state.copyWith(packets: updatedPackets));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
