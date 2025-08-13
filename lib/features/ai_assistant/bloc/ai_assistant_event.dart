import 'package:equatable/equatable.dart';

abstract class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends AiAssistantEvent {
  final String message;
  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}
