import 'dart:convert';

import 'package:zentry/modules/packet_sniffer/models/packet.dart';
import 'package:zentry/modules/packet_sniffer/models/protocol_type.dart';

class PacketParser {
  static Packet parse(String rawJson) {
    final data = jsonDecode(rawJson);

    return Packet(
      timestamp: DateTime.parse(data['timestamp']),
      sourceIP: data['sourceIP'],
      destinationIP: data['destinationIP'],
      sourcePort: data['sourcePort'],
      destinationPort: data['destinationPort'],
      protocol: _parseProtocol(data['protocol']),
      size: data['size'],
      rawData: data['raw'],
    );
  }

  static ProtocolType _parseProtocol(String name) {
    switch (name.toLowerCase()) {
      case 'tcp':
        return ProtocolType.tcp;
      case 'udp':
        return ProtocolType.udp;
      case 'icmp':
        return ProtocolType.icmp;
      case 'http':
        return ProtocolType.http;
      case 'https':
        return ProtocolType.https;
      case 'dns':
        return ProtocolType.dns;
      default:
        return ProtocolType.other;
    }
  }
}
