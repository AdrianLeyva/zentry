import 'package:flutter/cupertino.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/models/vulnerability.dart';
import 'package:zentry/modules/network_scanner/scanners/network_scanner.dart';
import 'package:zentry/modules/network_scanner/scanners/vulnerability_scanner.dart';
import 'package:zentry/modules/network_scanner/utils/network_utils.dart';

class NetworkScanService {
  final NetworkScanner _networkScanner;
  final VulnerabilityScanner _vulnScanner;

  NetworkScanService({
    NetworkScanner? networkScanner,
    VulnerabilityScanner? vulnerabilityScanner,
  })  : _networkScanner = networkScanner ?? NetworkScanner(),
        _vulnScanner = vulnerabilityScanner ?? VulnerabilityScanner();

  Future<List<Host>> fullScan() async {
    final localIp = await NetworkUtils.getLocalIp();
    if (localIp == null) {
      debugPrint('Could not obtain local IP');
      return [];
    }

    final subnet = NetworkUtils.getSubnet(localIp);
    if (subnet == null) {
      debugPrint('Could not determine subnet for $localIp');
      return [];
    }

    final hosts = await _networkScanner.scanSubnet(subnet);
    return hosts;
  }

  Future<List<Vulnerability>> analyzeVulnerabilities(List<Host> hosts) async {
    final findings = <Vulnerability>[];
    for (final host in hosts) {
      final vulns = _vulnScanner.analyze(
          host.ip, host.openPorts.map((e) => e.port).toList());
      findings.addAll(vulns);
    }
    return findings;
  }
}
