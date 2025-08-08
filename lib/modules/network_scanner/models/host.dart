import 'package:zentry/modules/network_scanner/models/port.dart';

class Host {
  final String ip;
  final String? hostname;
  final String? macAddress;
  final String? vendor;
  final bool isReachable;
  final int? latencyMs;
  final List<Port> openPorts;

  Host({
    required this.ip,
    this.hostname,
    this.macAddress,
    this.vendor,
    required this.isReachable,
    this.latencyMs,
    required this.openPorts,
  });
}
