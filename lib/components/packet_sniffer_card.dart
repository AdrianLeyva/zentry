import 'package:flutter/material.dart';
import 'package:zentry/modules/packet_sniffer/models/packet.dart';

class PacketSnifferCard extends StatelessWidget {
  final Packet packet;

  const PacketSnifferCard({super.key, required this.packet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shadowColor: Colors.white.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${packet.protocol.name.toUpperCase()} Packet",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _protocolColor(packet.protocol.name),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "From: ${packet.sourceIP}:${packet.sourcePort}",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "To: ${packet.destinationIP}:${packet.destinationPort}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              "Size: ${packet.size} bytes",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              "Timestamp: ${packet.timestamp.toLocal()}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _protocolColor(String protocol) {
    switch (protocol.toLowerCase()) {
      case 'tcp':
        return Colors.blue.shade700;
      case 'udp':
        return Colors.green.shade700;
      case 'icmp':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
