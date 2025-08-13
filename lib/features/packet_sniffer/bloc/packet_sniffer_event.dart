import 'package:equatable/equatable.dart';
import 'package:zentry/modules/packet_sniffer/models/packet.dart';

abstract class PacketSnifferEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartSniffingEvent extends PacketSnifferEvent {}

class StopSniffingEvent extends PacketSnifferEvent {}

class PacketCapturedEvent extends PacketSnifferEvent {
  final Packet packet;

  PacketCapturedEvent(this.packet);

  @override
  List<Object?> get props => [packet];
}
