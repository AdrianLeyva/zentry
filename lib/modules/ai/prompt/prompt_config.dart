import 'package:zentry/modules/ai/prompt/prompt_processing_result.dart';

import 'prompt_rule.dart';

class PromptConfig {
  final List<PromptRule> rules;

  PromptConfig({required this.rules});

  PromptProcessingResult process(String original) {
    String current = original;
    for (final rule in rules) {
      final result = rule.apply(current);
      if (!result.callApi) {
        return result;
      }
      current = result.prompt;
    }
    return PromptProcessingResult(callApi: true, prompt: current);
  }
}
