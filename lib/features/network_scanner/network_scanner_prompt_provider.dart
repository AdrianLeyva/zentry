import 'package:zentry/modules/network_scanner/extensions/host_extensions.dart';
import 'package:zentry/modules/network_scanner/extensions/vulnerability_extensions.dart';
import 'package:zentry/modules/network_scanner/models/host.dart';
import 'package:zentry/modules/network_scanner/models/vulnerability.dart';

class NetworkScannerPromptProvider {
  static String buildAnalysisPrompt(
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
}
