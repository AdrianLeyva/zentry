import 'package:flutter/material.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';

import '../core/ui/generic_card.dart';

class ScannerResultCard extends StatelessWidget {
  final Host host;

  const ScannerResultCard({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    return GenericCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            host.ip,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (host.openPorts.isNotEmpty)
            Text(
              "Open ports: ${host.openPorts.map((p) => p.port).join(', ')}",
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Text("No open ports found"),
        ],
      ),
    );
  }
}
