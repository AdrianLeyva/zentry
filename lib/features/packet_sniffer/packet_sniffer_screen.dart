import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/components/packet_sniffer_card.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_bloc.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_event.dart';
import 'package:zentry/features/packet_sniffer/bloc/packet_sniffer_state.dart';

class PacketSnifferScreen extends StatelessWidget {
  const PacketSnifferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PacketSnifferBloc(),
      child: BlocBuilder<PacketSnifferBloc, PacketSnifferState>(
        builder: (context, state) {
          final bloc = context.read<PacketSnifferBloc>();

          return GenericScaffold(
            title: "Packet Sniffer",
            body: state.packets.isEmpty
                ? SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!state.sniffingAvailable)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "Packet sniffing not available on this platform.",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            if (state.sniffingAvailable)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  onPressed: state.isSniffing
                                      ? () => bloc.add(StopSniffingEvent())
                                      : () => bloc.add(StartSniffingEvent()),
                                  child: Text(state.isSniffing
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
                          onPressed: state.isSniffing
                              ? () => bloc.add(StopSniffingEvent())
                              : () => bloc.add(StartSniffingEvent()),
                          child: Text(state.isSniffing
                              ? "Stop Sniffing"
                              : "Start Sniffing"),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
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
          );
        },
      ),
    );
  }
}
