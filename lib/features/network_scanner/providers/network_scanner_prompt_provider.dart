import 'package:zentry/modules/network_scanner/extensions/host_extensions.dart';
import 'package:zentry/modules/network_scanner/extensions/vulnerability_extensions.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/models/vulnerability.dart';
import 'package:zentry/modules/packet_sniffer/extensions/packet_extensions.dart';
import 'package:zentry/modules/packet_sniffer/models/packet.dart';

class NetworkScannerPromptProvider {
  static String buildAnalysisNetworkScannerPrompt(
      List<Host> hosts, List<Vulnerability> vulnerabilities) {
    return '''
Analyze the discovered hosts and vulnerabilities. Respond **only** in the following three sections, nothing more and nothing less.  
Use simple language that anyone can understand.  

---
**1. General Analysis**  
Briefly describe the overall security situation based on the findings.

---
**2. Detected Vulnerabilities**  
List each vulnerability with:  
- A short, plain-language explanation of what it means.  
- The potential risk or impact.  
If no vulnerabilities or anomalies are detected, state: "No vulnerabilities or anomalies detected."

---
**3. Recommended Actions**  
Provide practical, prioritized steps to fix or reduce the risks.  
If no vulnerabilities or anomalies are detected, state: "All systems OK. No action required."

---
Format the response with clear headings and bullet points. Avoid unnecessary technical jargon or lengthy explanations.

${hosts.toSummaryString()}
${vulnerabilities.toSummaryString()}
''';
  }

  static String buildAnalysisPacketSnifferPrompt(List<Packet> packets) {
    return '''
Analyze the captured network packets. Respond **only** in the following three sections, nothing more and nothing less.  
Use simple language that anyone can understand.  

---
**1. General Analysis**  
Briefly describe the overall network activity, patterns, and notable behaviors observed in the captured packets.

---
**2. Potential Issues or Anomalies**  
Identify any suspicious packets, unusual traffic patterns, or potential security concerns.  
If no issues or anomalies are detected, state: "No suspicious packets or anomalies detected."

---
**3. Recommended Actions**  
Provide practical and prioritized steps to address any detected issues or improve network monitoring.  
If no issues or anomalies are detected, state: "All traffic appears normal. No action required."

---
Format the response with clear headings and bullet points. Avoid unnecessary technical jargon or lengthy explanations.

Packet summary:
${packets.toSummaryString()}
''';
  }
}
