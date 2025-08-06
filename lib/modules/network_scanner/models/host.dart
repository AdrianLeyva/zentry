import 'package:zentry/modules/network_scanner/models/port.dart';

class Host {
  final String ip;
  final bool isReachable;
  final List<Port> openPorts;

  Host({required this.ip, this.isReachable = false, this.openPorts = const []});
}
