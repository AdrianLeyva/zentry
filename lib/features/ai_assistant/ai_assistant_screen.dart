import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/core/ui/utils.dart';
import 'package:zentry/features/ai_assistant/models/ai_message_ui.dart';

import 'bloc/ai_assistant_bloc.dart';
import 'bloc/ai_assistant_event.dart';
import 'bloc/ai_assistant_state.dart';

class AiAssistantScreen extends StatelessWidget {
  AiAssistantScreen({super.key});

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(BuildContext context, AIMessageUI message, bool isLast) {
    final theme = Theme.of(context);
    final isUser = message.role == 'user';

    final bgColor = isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;

    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
      bottomRight: isUser ? Radius.zero : const Radius.circular(16),
    );

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isUser ? 50 : 12,
            right: isUser ? 12 : 50,
            top: 8,
            bottom: 4,
          ),
          child: Text(
            isUser ? 'You' : 'AI Assistant',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
            ),
          ),
        ),
        Align(
          alignment: align,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: SelectableText.rich(
              parseRichText(message.content,
                  theme.textTheme.bodyMedium!.copyWith(color: textColor)),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 50 : 12,
              right: isUser ? 12 : 50,
              bottom: 4,
            ),
            child: Divider(
              thickness: 0.5,
              color: theme.colorScheme.onBackground
                  .withAlpha((0.15 * 255).round()),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => AiAssistantBloc(),
      child: BlocBuilder<AiAssistantBloc, AiAssistantState>(
        builder: (context, state) {
          return GenericScaffold(
            title: 'AI Assistant',
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) => _buildMessage(
                        context,
                        state.messages[index],
                        index == state.messages.length - 1),
                  ),
                ),
                if (state.isLoading)
                  LinearProgressIndicator(
                    color: theme.colorScheme.primary,
                    minHeight: 3,
                  ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              hintText: 'Type your message...',
                              labelStyle: TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: theme.colorScheme.secondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                            ),
                            onSubmitted: (_) {
                              context
                                  .read<AiAssistantBloc>()
                                  .add(SendMessageEvent(_controller.text));
                              _controller.clear();
                              _scrollToTop();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            color: theme.colorScheme.onPrimary,
                            onPressed: () {
                              context
                                  .read<AiAssistantBloc>()
                                  .add(SendMessageEvent(_controller.text));
                              _controller.clear();
                              _scrollToTop();
                            },
                            tooltip: 'Send message',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
