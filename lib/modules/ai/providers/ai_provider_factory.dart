import 'package:zentry/core/providers/environment_variables_provider.dart';
import 'package:zentry/modules/ai/providers/gemini_ai_provider.dart';

class AiProviderFactory {
  static GeminiAiProvider createGeminiProvider() {
    return GeminiAiProvider(EnvironmentVariablesProvider.instance.geminiApiKey);
  }
}
