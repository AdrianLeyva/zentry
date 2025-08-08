import 'package:zentry/modules/ai/models/ai_bool_request.dart';
import 'package:zentry/modules/ai/models/ai_bool_response.dart';
import 'package:zentry/modules/ai/models/ai_request.dart';
import 'package:zentry/modules/ai/models/ai_response.dart';

abstract class AIProvider {
  Future<AIResponse> send(AIRequest request);
  Future<AIBoolResponse> evaluate(AIBoolRequest request);
}
