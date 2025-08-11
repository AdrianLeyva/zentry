import 'package:zentry/modules/network_scanner/models/host.dart';

extension HostExtensions on List<Host> {
  String toSummaryString() {
    if (isEmpty) return 'No hosts discovered.';

    final buffer = StringBuffer();
    buffer.writeln('Discovered Hosts Summary:');
    for (final host in this) {
      buffer.writeln('- IP: ${host.ip}');
      if (host.hostname != null) buffer.writeln('  Hostname: ${host.hostname}');
      if (host.macAddress != null) buffer.writeln('  MAC: ${host.macAddress}');
      if (host.vendor != null) buffer.writeln('  Vendor: ${host.vendor}');
      buffer.writeln('  Reachable: ${host.isReachable}');
      if (host.latencyMs != null)
        buffer.writeln('  Latency: ${host.latencyMs} ms');
      if (host.openPorts.isNotEmpty) {
        final ports = host.openPorts.map((p) => p.port).join(', ');
        buffer.writeln('  Open ports: $ports');
      } else {
        buffer.writeln('  Open ports: None');
      }
      buffer.writeln('');
    }
    return buffer.toString();
  }
}
