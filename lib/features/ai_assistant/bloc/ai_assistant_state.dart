import 'package:equatable/equatable.dart';
import 'package:zentry/features/ai_assistant/models/ai_message_ui.dart';

class AiAssistantState extends Equatable {
  final List<AIMessageUI> messages;
  final bool isLoading;

  const AiAssistantState({
    this.messages = const [],
    this.isLoading = false,
  });

  AiAssistantState copyWith({
    List<AIMessageUI>? messages,
    bool? isLoading,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading];
}
