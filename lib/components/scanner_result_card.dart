import 'package:flutter/material.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';

class ScannerResultCard extends StatelessWidget {
  final Host host;

  const ScannerResultCard({super.key, required this.host});

  Widget _infoTile(String label, String? value, BuildContext context,
      {Color? valueColor}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: '$label: ',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        children: [
          TextSpan(
            text: value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final latencyText = host.latencyMs != null ? '${host.latencyMs} ms' : 'N/A';
    final reachabilityText = host.isReachable ? 'Reachable' : 'Unreachable';
    final reachabilityColor =
        host.isReachable ? Colors.green.shade700 : Colors.red.shade700;

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
              host.ip,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 16,
                mainAxisExtent: 22,
              ),
              children: [
                _infoTile('Hostname', host.hostname, context),
                _infoTile('MAC', host.macAddress, context),
                _infoTile('Vendor', host.vendor, context),
                _infoTile('Reachability', reachabilityText, context,
                    valueColor: reachabilityColor),
                _infoTile('Latency', latencyText, context),
              ].where((w) => w is! SizedBox).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Open Ports',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            if (host.openPorts.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: host.openPorts.map((port) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      port.port.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'No open ports found',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
