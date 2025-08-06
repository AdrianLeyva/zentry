import 'package:zentry/modules/packet_sniffer/models/packet.dart';
import 'package:zentry/modules/packet_sniffer/utils/packet_parser.dart';

import 'sniffer_native_bridge.dart';

class PacketSniffer {
  final _nativeBridge = SnifferNativeBridge();

  Stream<Packet> sniffPackets() {
    return _nativeBridge.packetStream.map((raw) => PacketParser.parse(raw));
  }

  Future<void> start() => _nativeBridge.startSniffer();

  Future<void> stop() => _nativeBridge.stopSniffer();
}
