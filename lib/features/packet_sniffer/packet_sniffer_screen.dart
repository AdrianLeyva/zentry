import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:zentry/components/packet_sniffer_card.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/modules/packet_sniffer/models/packet.dart';
import 'package:zentry/modules/packet_sniffer/services/packet_sniffer.dart';

class PacketSnifferScreen extends StatefulWidget {
  const PacketSnifferScreen({super.key});

  @override
  State<PacketSnifferScreen> createState() => _PacketSnifferScreenState();
}

class _PacketSnifferScreenState extends State<PacketSnifferScreen> {
  final PacketSniffer _sniffer = PacketSniffer();
  bool _isSniffing = false;
  final List<Packet> _packets = [];

  bool get sniffingAvailable {
    if (kIsWeb) return false;
    if (Platform.isAndroid) return true;
    return false;
  }

  void _start() async {
    await _sniffer.start();
    setState(() => _isSniffing = true);
    _sniffer.sniffPackets().listen((packet) {
      setState(() {
        _packets.insert(0, packet);
        if (_packets.length > 100) _packets.removeLast();
      });
    });
  }

  void _stop() async {
    await _sniffer.stop();
    setState(() => _isSniffing = false);
  }

  @override
  Widget build(BuildContext context) {
    return GenericScaffold(
      title: "Packet Sniffer",
      body: _packets.isEmpty
          ? SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!sniffingAvailable)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Packet sniffing not available on this platform.",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      if (sniffingAvailable)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: _isSniffing ? _stop : _start,
                            child: Text(_isSniffing
                                ? "Stop Sniffing"
                                : "Start Sniffing"),
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Text("No packets captured yet."),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _isSniffing ? _stop : _start,
                    child:
                        Text(_isSniffing ? "Stop Sniffing" : "Start Sniffing"),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _packets.length,
                    itemBuilder: (context, index) {
                      final packet = _packets[index];
                      return PacketSnifferCard(packet: packet);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
