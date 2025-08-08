import 'package:zentry/modules/ai/models/ai_bool_response.dart';

class PromptProcessingResult {
  final bool callApi;
  final String prompt;
  final String? overrideText;
  final AIBoolResponse? overrideBoolResponse;

  PromptProcessingResult({
    required this.callApi,
    required this.prompt,
    this.overrideText,
    this.overrideBoolResponse,
  });
}
