import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:zentry/modules/ai/models/ai_bool_request.dart';
import 'package:zentry/modules/ai/models/ai_bool_response.dart';
import 'package:zentry/modules/ai/models/ai_request.dart';
import 'package:zentry/modules/ai/models/ai_response.dart';

import 'ai_provider.dart';

class GeminiAiProvider implements AIProvider {
  final String apiKey;
  final String baseUrl;

  GeminiAiProvider(
    this.apiKey, {
    this.baseUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
  });

  @override
  Future<AIResponse> send(AIRequest request) async {
    debugPrint(
        "[GeminiProvider] Sending text request to Gemini with prompt: ${request.prompt}");

    final url = Uri.parse('$baseUrl?key=$apiKey');

    final body = {
      "contents": [
        {
          "parts": [
            {"text": request.prompt}
          ]
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "[GeminiProvider] Request failed with status: ${response.statusCode}, body: ${response.body}");
    }

    final decoded = jsonDecode(response.body);
    final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
        "No response from Gemini.";

    return AIResponse(text: text.trim());
  }

  @override
  Future<AIBoolResponse> evaluate(AIBoolRequest request) async {
    debugPrint(
        "[GeminiProvider] Sending boolean evaluation request to Gemini...");

    final formattedPrompt = """
You are a decision-making AI. Based on the following prompt, you must decide TRUE or FALSE.
Return your answer strictly in this format:
response: TRUE/FALSE,
reasoning: "Explain in detail why TRUE or FALSE."

Prompt: ${request.prompt}
""";

    debugPrint("[GeminiProvider] Formatted boolean prompt: $formattedPrompt");

    final url = Uri.parse('$baseUrl?key=$apiKey');

    final body = {
      "contents": [
        {
          "parts": [
            {"text": formattedPrompt}
          ]
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "[GeminiProvider] Boolean evaluation request failed with status: ${response.statusCode}, body: ${response.body}");
    }

    final decoded = jsonDecode(response.body);
    final rawText = decoded['candidates']?[0]?['content']?['parts']?[0]
            ?['text'] ??
        "response: FALSE, reasoning: \"No reasoning provided.\"";

    debugPrint("[GeminiProvider] Raw AI response: $rawText");

    return _parseBooleanResponse(rawText);
  }

  AIBoolResponse _parseBooleanResponse(String raw) {
    final lower = raw.toLowerCase();
    bool result = lower.contains("true") && !lower.contains("false,");

    final reasoningMatch =
        RegExp(r'reasoning:\s*"(.+)"', caseSensitive: false).firstMatch(raw);
    final reasoning = reasoningMatch != null
        ? reasoningMatch.group(1)!
        : "No reasoning provided.";

    return AIBoolResponse(result: result, reasoning: reasoning);
  }
}
