import 'package:flutter/cupertino.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/models/port.dart';
import 'package:zentry/modules/network_scanner/models/vulnerability.dart';
import 'package:zentry/modules/network_scanner/scanners/network_scanner.dart';
import 'package:zentry/modules/network_scanner/scanners/port_scanner.dart';
import 'package:zentry/modules/network_scanner/scanners/vulnerability_scanner.dart';
import 'package:zentry/modules/network_scanner/utils/network_utils.dart';

class NetworkScanService {
  final _networkScanner = NetworkScanner();
  final _portScanner = PortScanner();
  final _vulnScanner = VulnerabilityScanner();

  Future<List<Host>> fullScan() async {
    final localIp = await NetworkUtils.getLocalIp();
    if (localIp == null) {
      debugPrint('It was not able to return the IP');
      return [];
    }

    final subnet = NetworkUtils.getSubnet(localIp);
    if (subnet == null) {
      debugPrint('It was not able to return the subnet');
      return [];
    }

    final ips = await _networkScanner.scanSubnet(subnet);
    List<Host> hosts = [];

    for (final ip in ips) {
      final openPorts = await _portScanner.scanOpenPorts(ip);
      final ports = openPorts.map((p) => Port(port: p, isOpen: true)).toList();

      hosts.add(Host(ip: ip, isReachable: true, openPorts: ports));
    }

    return hosts;
  }

  Future<List<Vulnerability>> analyzeVulnerabilities(List<Host> hosts) async {
    List<Vulnerability> findings = [];

    for (final host in hosts) {
      final vulns = _vulnScanner.analyze(
          host.ip, host.openPorts.map((e) => e.port).toList());
      findings.addAll(vulns as Iterable<Vulnerability>);
    }

    return findings;
  }
}
