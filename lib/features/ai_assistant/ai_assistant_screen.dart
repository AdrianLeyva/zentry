import 'package:flutter/material.dart';
import 'package:zentry/core/ui/generic_scaffold.dart';
import 'package:zentry/core/ui/utils.dart';
import 'package:zentry/features/ai_assistant/models/ai_message_ui.dart';
import 'package:zentry/modules/ai/providers/ai_provider_factory.dart';
import 'package:zentry/modules/ai/services/ai_service.dart';
import 'package:zentry/modules/ai/services/ai_service_factory.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<AIMessageUI> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late final AIService _aiService;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _aiService = AiServiceFactory.networkSecurityAiService(
        AiProviderFactory.createGeminiProvider());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, AIMessageUI(role: 'user', content: text));
      _isLoading = true;
    });
    _controller.clear();

    _scrollToTop();

    final aiResponse = await _aiService.processPrompt(text);

    setState(() {
      _messages.insert(0, AIMessageUI(role: 'ai', content: aiResponse.text));
      _isLoading = false;
    });

    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(AIMessageUI message, bool isLast) {
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
              indent: 0,
              endIndent: 0,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GenericScaffold(
      title: 'AI Assistant',
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.only(top: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(
                  _messages[index], index == _messages.length - 1),
            ),
          ),
          if (_isLoading)
            LinearProgressIndicator(
              color: theme.colorScheme.primary,
              minHeight: 3,
            ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: theme.colorScheme.primary,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: theme.colorScheme.onPrimary,
                      onPressed: _sendMessage,
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
  }
}
