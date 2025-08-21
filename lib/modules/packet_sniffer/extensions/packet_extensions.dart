import 'package:zentry/modules/packet_sniffer/models/packet.dart';

extension PacketExtensions on List<Packet> {
  String toSummaryString() {
    if (isEmpty) return 'No packets captured.';

    final buffer = StringBuffer();
    buffer.writeln('Packets Summary:');
    for (final packet in this) {
      buffer.writeln('- Timestamp: ${packet.timestamp.toIso8601String()}');
      buffer.writeln('  Source IP: ${packet.sourceIP}');
      buffer.writeln('  Destination IP: ${packet.destinationIP}');
      buffer.writeln('  Source Port: ${packet.sourcePort}');
      buffer.writeln('  Destination Port: ${packet.destinationPort}');
      buffer.writeln('  Protocol: ${packet.protocol.name}');
      buffer.writeln('  Size: ${packet.size} bytes');
      buffer.writeln('  Raw Data: ${packet.rawData}');
      buffer.writeln('');
    }
    return buffer.toString();
  }
}
