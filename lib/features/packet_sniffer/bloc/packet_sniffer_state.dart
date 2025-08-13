import 'package:equatable/equatable.dart';
import 'package:zentry/modules/packet_sniffer/models/packet.dart';

class PacketSnifferState extends Equatable {
  final bool isSniffing;
  final bool sniffingAvailable;
  final List<Packet> packets;

  const PacketSnifferState({
    required this.isSniffing,
    required this.sniffingAvailable,
    required this.packets,
  });

  PacketSnifferState copyWith({
    bool? isSniffing,
    bool? sniffingAvailable,
    List<Packet>? packets,
  }) {
    return PacketSnifferState(
      isSniffing: isSniffing ?? this.isSniffing,
      sniffingAvailable: sniffingAvailable ?? this.sniffingAvailable,
      packets: packets ?? this.packets,
    );
  }

  @override
  List<Object?> get props => [isSniffing, sniffingAvailable, packets];
}
