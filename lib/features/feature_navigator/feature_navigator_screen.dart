import 'package:flutter/material.dart';
import 'package:zentry/components/feature_card.dart';
import 'package:zentry/components/feature_item.dart';
import 'package:zentry/features/ai_assistant/ai_assistant_screen.dart';
import 'package:zentry/features/network_scanner/network_scanner_screen.dart';
import 'package:zentry/features/packet_sniffer/packet_sniffer_screen.dart';

class FeatureNavigatorScreen extends StatelessWidget {
  const FeatureNavigatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      FeatureItem(
        title: "Network Scanner",
        description:
            "Scan your local network for connected devices and open ports.",
        icon: Icons.network_check,
        screenBuilder: () => const NetworkScannerScreen(),
      ),
      FeatureItem(
        title: "Packet Sniffer",
        description: "Monitor incoming and outgoing packets (Android only).",
        icon: Icons.shield,
        screenBuilder: () => PacketSnifferScreen(),
      ),
      FeatureItem(
        title: "AI Assistant",
        description: "Chat and interact with an AI assistant in real time.",
        icon: Icons.smart_toy,
        screenBuilder: () => const AiAssistantScreen(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: features.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final feature = features[index];
            return FeatureCard(
              title: feature.title,
              description: feature.description,
              icon: feature.icon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => feature.screenBuilder()),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
