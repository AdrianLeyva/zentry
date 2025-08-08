import 'package:zentry/modules/ai/prompt/prompt_config.dart';
import 'package:zentry/modules/ai/providers/ai_provider.dart';
import 'package:zentry/modules/ai/rules/cybersecurity_rule.dart';
import 'package:zentry/modules/ai/services/ai_service.dart';

class AiServiceFactory {
  static AIService _create(AIProvider provider, PromptConfig config) {
    return AIService(provider, promptConfig: config);
  }

  static AIService networkSecurityAiService(AIProvider provider) {
    final promptConfig = PromptConfig(rules: [CyberSecurityRule()]);
    return _create(provider, promptConfig);
  }
}
