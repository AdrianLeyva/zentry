import 'package:zentry/modules/ai/prompt/prompt_processing_result.dart';

abstract class PromptRule {
  PromptProcessingResult apply(String original);
}
