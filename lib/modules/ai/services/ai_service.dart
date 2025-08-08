import 'package:zentry/modules/ai/models/ai_bool_request.dart';
import 'package:zentry/modules/ai/models/ai_bool_response.dart';
import 'package:zentry/modules/ai/models/ai_request.dart';
import 'package:zentry/modules/ai/models/ai_response.dart';
import 'package:zentry/modules/ai/prompt/prompt_config.dart';
import 'package:zentry/modules/ai/prompt/prompt_processing_result.dart';
import 'package:zentry/modules/ai/providers/ai_provider.dart';

class AIService {
  final AIProvider provider;
  final PromptConfig? promptConfig;

  AIService(this.provider, {this.promptConfig});

  Future<AIResponse> processPrompt(String prompt,
      {Map<String, dynamic>? options}) async {
    final processed = promptConfig?.process(prompt) ??
        PromptProcessingResult(callApi: true, prompt: prompt);
    if (!processed.callApi) {
      return AIResponse(text: processed.overrideText ?? '');
    }
    final request = AIRequest(prompt: processed.prompt, options: options);
    return provider.send(request);
  }

  Future<AIBoolResponse> processBooleanDecision(String prompt) async {
    final processed = promptConfig?.process(prompt) ??
        PromptProcessingResult(callApi: true, prompt: prompt);
    if (!processed.callApi) {
      return processed.overrideBoolResponse ??
          AIBoolResponse(result: false, reasoning: 'Out of scope.');
    }
    final request = AIBoolRequest(prompt: processed.prompt);
    return provider.evaluate(request);
  }
}
