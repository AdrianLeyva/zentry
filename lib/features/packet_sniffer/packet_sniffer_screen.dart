import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/components/packet_sniffer_card.dart';
import 'package:zentry/components/zentry_loader.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/core/ui/generic_text_dialog.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_bloc.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_event.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_state.dart';

class PacketSnifferScreen extends StatefulWidget {
  const PacketSnifferScreen({super.key});

  @override
  State<PacketSnifferScreen> createState() => _PacketSnifferScreenState();
}

class _PacketSnifferScreenState extends State<PacketSnifferScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PacketSnifferBloc(),
      child: BlocConsumer<PacketSnifferBloc, PacketSnifferState>(
        listener: (context, state) {
          if (state.aiAnalysisResult != null) {
            showDialog(
              context: context,
              builder: (_) => GenericTextDialog(
                title: 'AI Analysis Result',
                mainText: state.aiAnalysisResult!,
                jsonData: state.aiAnalysisMetadata,
                closeButtonText: 'Close',
              ),
            );
          }
          if (state.packets.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToLatest();
            });
          }
        },
        builder: (context, state) {
          final bloc = context.read<PacketSnifferBloc>();
          return GenericScaffold(
            title: "Packet Sniffer",
            body: Stack(
              children: [
                if (!state.isAnalyzingWithAi)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: state.isSniffing
                                    ? () => bloc.add(StopSniffingEvent())
                                    : () => bloc.add(StartSniffingEvent()),
                                icon: Icon(
                                  color: Colors.black87,
                                  state.isSniffing
                                      ? Icons.stop_circle
                                      : Icons.radar,
                                  size: 20,
                                ),
                                label: Text(state.isSniffing
                                    ? "Stop Sniffing"
                                    : "Start Sniffing"),
                              ),
                              const SizedBox(width: 12),
                              if (!state.isSniffing && state.totalPackets > 0)
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      bloc.add(AnalyzeWithAiEvent()),
                                  icon: const Icon(Icons.smart_toy,
                                      size: 20, color: Colors.black87),
                                  label: const Text("Analyze with AI"),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            "Packets captured: ${state.totalPackets}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: state.packets.isEmpty
                              ? const Center(
                                  child: Text("No packets captured yet."),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  itemCount: state.packets.length,
                                  itemBuilder: (context, index) {
                                    final packet = state.packets[index];
                                    return PacketSnifferCard(packet: packet);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                if (state.isAnalyzingWithAi)
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const ZentryLoader(
                        size: 180,
                        loadingText: 'ANALYZING WITH AI...',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
