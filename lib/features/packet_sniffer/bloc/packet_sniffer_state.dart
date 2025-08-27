import 'package:equatable/equatable.dart';
import 'package:zentry/modules/packet_sniffer/models/packet.dart';

class PacketSnifferState extends Equatable {
  final bool isSniffing;
  final bool sniffingAvailable;
  final List<Packet> packets;
  final int totalPackets;
  final bool isAnalyzingWithAi;
  final String? aiAnalysisResult;
  final Map<String, dynamic>? aiAnalysisMetadata;

  const PacketSnifferState({
    required this.isSniffing,
    required this.sniffingAvailable,
    required this.packets,
    this.totalPackets = 0,
    this.isAnalyzingWithAi = false,
    this.aiAnalysisResult,
    this.aiAnalysisMetadata,
  });

  PacketSnifferState copyWith({
    bool? isSniffing,
    bool? sniffingAvailable,
    List<Packet>? packets,
    int? totalPackets,
    bool? isAnalyzingWithAi,
    String? aiAnalysisResult,
    Map<String, dynamic>? aiAnalysisMetadata,
  }) {
    return PacketSnifferState(
        isSniffing: isSniffing ?? this.isSniffing,
        sniffingAvailable: sniffingAvailable ?? this.sniffingAvailable,
        packets: packets ?? this.packets,
        totalPackets: totalPackets ?? this.totalPackets,
        isAnalyzingWithAi: isAnalyzingWithAi ?? this.isAnalyzingWithAi,
        aiAnalysisResult: aiAnalysisResult,
        aiAnalysisMetadata: aiAnalysisMetadata);
  }

  @override
  List<Object?> get props => [
        isSniffing,
        sniffingAvailable,
        packets,
        totalPackets,
        isAnalyzingWithAi,
        aiAnalysisResult,
        aiAnalysisMetadata
      ];
}
