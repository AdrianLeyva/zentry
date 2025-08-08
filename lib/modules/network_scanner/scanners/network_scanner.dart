import 'dart:io';

import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/models/port.dart';
import 'package:zentry/modules/network_scanner/utils/mac_vendor_lookup.dart';

class NetworkScanner {
  final List<int> portsToScan;

  NetworkScanner({
    this.portsToScan = const [
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
      8080,
    ],
  });

  Future<List<Host>> scanSubnet(String subnet) async {
    final futures = <Future<Host?>>[];

    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      futures.add(_scanHost(ip));
    }

    final results = await Future.wait(futures);
    return results.whereType<Host>().toList();
  }

  Future<Host?> _scanHost(String ip) async {
    final isReachable = await _isHostReachable(ip);
    if (!isReachable) return null;

    final openPorts = await _scanOpenPorts(ip);
    final hostname = await _getHostname(ip);
    final macAddress = await _getMacAddress(ip);
    final vendor =
        macAddress != null ? MacVendorLookup.lookupVendor(macAddress) : null;
    final latency = await _getPingLatency(ip);

    return Host(
      ip: ip,
      hostname: hostname,
      macAddress: macAddress,
      vendor: vendor,
      isReachable: true,
      latencyMs: latency,
      openPorts: openPorts.map((p) => Port(port: p, isOpen: true)).toList(),
    );
  }

  Future<bool> _isHostReachable(String ip) async {
    if (Platform.isAndroid || Platform.isLinux || Platform.isMacOS) {
      if (await _pingHost(ip)) return true;
    }

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

  Future<bool> _pingHost(String ip) async {
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<int?> _getPingLatency(String ip) async {
    try {
      final result = await Process.run('ping', ['-c', '1', ip]);
      if (result.exitCode != 0) return null;

      final output = result.stdout.toString();
      final match = RegExp(r'time[=<]([0-9]+\.?[0-9]*)').firstMatch(output);
      if (match != null) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null) return value.round();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<int>> _scanOpenPorts(String ip) async {
    final openPorts = <int>[];
    for (final port in portsToScan) {
      try {
        final socket = await Socket.connect(ip, port,
            timeout: Duration(milliseconds: 200));
        socket.destroy();
        openPorts.add(port);
      } catch (_) {}
    }
    return openPorts;
  }

  Future<String?> _getHostname(String ip) async {
    try {
      final result = await Process.run('nslookup', [ip]);
      if (result.exitCode != 0) return null;

      final output = result.stdout.toString();
      final match =
          RegExp(r'(name|Name)\s*=\s*([^\s\.]+)').firstMatch(output) ??
              RegExp(r'Name:\s*(\S+)').firstMatch(output);
      if (match != null) return match.group(2) ?? match.group(1);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getMacAddress(String ip) async {
    if (!(Platform.isAndroid || Platform.isLinux)) return null;

    await _pingHost(ip);

    try {
      final result = await Process.run('ip', ['neigh', 'show', ip]);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp(r'lladdr ([0-9a-f:]{17})').firstMatch(output);
        if (match != null) return match.group(1)?.toUpperCase();
      }

      final arpResult = await Process.run('arp', ['-n', ip]);
      if (arpResult.exitCode == 0) {
        final arpOutput = arpResult.stdout.toString().toLowerCase();
        final match =
            RegExp(r'(([0-9a-f]{2}:){5}[0-9a-f]{2})').firstMatch(arpOutput);
        if (match != null) return match.group(1)?.toUpperCase();
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
