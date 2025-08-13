import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/models/vulnerability.dart';

class NetworkScannerState {
  final List<Host> hosts;
  final List<Vulnerability> vulnerabilities;
  final bool isScanning;
  final bool isAnalyzingWithAi;
  final bool hasScanned;
  final String? aiAnalysisResult;
  final Map<String, dynamic>? aiAnalysisMetadata;

  const NetworkScannerState({
    this.hosts = const [],
    this.vulnerabilities = const [],
    this.isScanning = false,
    this.isAnalyzingWithAi = false,
    this.hasScanned = false,
    this.aiAnalysisResult,
    this.aiAnalysisMetadata,
  });

  NetworkScannerState copyWith({
    List<Host>? hosts,
    List<Vulnerability>? vulnerabilities,
    bool? isScanning,
    bool? isAnalyzingWithAi,
    bool? hasScanned,
    String? aiAnalysisResult,
    Map<String, dynamic>? aiAnalysisMetadata,
  }) {
    return NetworkScannerState(
      hosts: hosts ?? this.hosts,
      vulnerabilities: vulnerabilities ?? this.vulnerabilities,
      isScanning: isScanning ?? this.isScanning,
      isAnalyzingWithAi: isAnalyzingWithAi ?? this.isAnalyzingWithAi,
      hasScanned: hasScanned ?? this.hasScanned,
      aiAnalysisResult: aiAnalysisResult ?? this.aiAnalysisResult,
      aiAnalysisMetadata: aiAnalysisMetadata ?? this.aiAnalysisMetadata,
    );
  }
}
