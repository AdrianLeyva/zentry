import 'dart:io';

class NetworkScanner {
  final List<int> portsToScan;

  NetworkScanner(
      {this.portsToScan = const [
        7,
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
        554,
        8000,
        8080
      ]});

  Future<List<String>> scanSubnet(String subnet) async {
    final futures = <Future<String?>>[];

    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      futures.add(_checkDevice(ip));
    }

    final results = await Future.wait(futures);
    return results.whereType<String>().toList();
  }

  Future<String?> _checkDevice(String ip) async {
    if (await _isDeviceOnline(ip)) return ip;
    if (Platform.isAndroid && await _pingDevice(ip)) return ip;
    return null;
  }

  Future<bool> _isDeviceOnline(String ip) async {
    for (final port in portsToScan) {
      try {
        final socket = await Socket.connect(ip, port,
            timeout: Duration(milliseconds: 200));
        socket.destroy();
        return true;
      } catch (_) {}
    }
    return false;
  }

  Future<bool> _pingDevice(String ip) async {
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> getArpTable() async {
    if (!Platform.isAndroid) return [];

    try {
      final result = await Process.run('ip', ['neigh']);
      final lines = result.stdout.toString().split('\n');
      final ips = <String>[];

      for (final line in lines) {
        final parts = line.split(' ');
        if (parts.isNotEmpty) {
          final ip = parts[0];
          if (RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(ip)) {
            ips.add(ip);
          }
        }
      }

      return ips;
    } catch (_) {
      return [];
    }
  }
}
