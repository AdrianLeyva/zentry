import 'protocol_type.dart';

class Packet {
  final DateTime timestamp;
  final String sourceIP;
  final String destinationIP;
  final int sourcePort;
  final int destinationPort;
  final ProtocolType protocol;
  final int size;
  final String rawData;

  Packet({
    required this.timestamp,
    required this.sourceIP,
    required this.destinationIP,
    required this.sourcePort,
    required this.destinationPort,
    required this.protocol,
    required this.size,
    required this.rawData,
  });
}
