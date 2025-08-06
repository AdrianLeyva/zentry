import 'dart:io';

class PortScanner {
  final List<int> defaultPorts = [
    21,
    22,
    23,
    25,
    53,
    80,
    110,
    139,
    143,
    443,
    445,
    3306,
    3389
  ];

  Future<List<int>> scanOpenPorts(String ip, {List<int>? ports}) async {
    List<int> openPorts = [];
    final toScan = ports ?? defaultPorts;

    for (final port in toScan) {
      final isOpen = await _isPortOpen(ip, port);
      if (isOpen) openPorts.add(port);
    }

    return openPorts;
  }

  Future<bool> _isPortOpen(String ip, int port) async {
    try {
      final socket =
          await Socket.connect(ip, port, timeout: Duration(milliseconds: 200));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
