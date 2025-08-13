import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/features/ai_assistant/ai_assistant_screen.dart';
import 'package:zentry/features/feature_navigator/models/feature_item_ui.dart';
import 'package:zentry/features/network_scanner/network_scanner_screen.dart';
import 'package:zentry/features/packet_sniffer/packet_sniffer_screen.dart';

import 'feature_navigator_event.dart';
import 'feature_navigator_state.dart';

class FeatureNavigatorBloc
    extends Bloc<FeatureNavigatorEvent, FeatureNavigatorState> {
  FeatureNavigatorBloc() : super(FeatureNavigatorLoading()) {
    on<LoadFeatures>(_onLoadFeatures);
  }

  void _onLoadFeatures(
      LoadFeatures event, Emitter<FeatureNavigatorState> emit) {
    final features = [
      FeatureItemUi(
        title: "Network Scanner",
        description:
            "Scan your local network for connected devices and open ports.",
        icon: Icons.network_check,
        screenBuilder: () => const NetworkScannerScreen(),
      ),
      FeatureItemUi(
        title: "Packet Sniffer",
        description: "Monitor incoming and outgoing packets (Android only).",
        icon: Icons.shield,
        screenBuilder: () => PacketSnifferScreen(),
      ),
      FeatureItemUi(
        title: "AI Assistant",
        description: "Chat and interact with an AI assistant in real time.",
        icon: Icons.smart_toy,
        screenBuilder: () => AiAssistantScreen(),
      )
    ];

    emit(FeatureNavigatorLoaded(features));
  }
}
