import 'dart:io';

class NetworkScanner {
  Future<List<String>> scanSubnet(String subnet) async {
    List<String> aliveHosts = [];

    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      final reachable = await _isReachable(ip);
      if (reachable) {
        aliveHosts.add(ip);
      }
    }

    return aliveHosts;
  }

  Future<bool> _isReachable(String ip) async {
    try {
      final socket =
          await Socket.connect(ip, 80, timeout: Duration(milliseconds: 200));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
