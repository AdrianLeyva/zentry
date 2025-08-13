import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/features/ai_assistant/models/ai_message_ui.dart';
import 'package:zentry/modules/ai/providers/ai_provider_factory.dart';
import 'package:zentry/modules/ai/services/ai_service.dart';
import 'package:zentry/modules/ai/services/ai_service_factory.dart';

import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  final AIService _aiService;

  AiAssistantBloc()
      : _aiService = AiServiceFactory.networkSecurityAiService(
          AiProviderFactory.createGeminiProvider(),
        ),
        super(const AiAssistantState()) {
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<AiAssistantState> emit) async {
    if (event.message.trim().isEmpty) return;

    final updatedMessages = [
      AIMessageUI(role: 'user', content: event.message),
      ...state.messages
    ];
    emit(state.copyWith(messages: updatedMessages, isLoading: true));

    final aiResponse = await _aiService.processPrompt(event.message);

    final newMessages = [
      AIMessageUI(role: 'ai', content: aiResponse.text),
      ...updatedMessages
    ];

    emit(state.copyWith(messages: newMessages, isLoading: false));
  }
}
