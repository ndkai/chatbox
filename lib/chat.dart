import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [
    {"role": "assistant", "content": "Hello 👋 I'm **ChatGPT**, how can I help you today?"}
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "content": text});
    });

    _scrollToBottom();

    // simulate streaming ChatGPT response
    _fakeChatGPTResponse(
      "Sure! Here's an example of streaming response that renders three words at a time like ChatGPT typing effect.",
    );
  }

  Future<void> _fakeChatGPTResponse(String fullText) async {
    setState(() => _isTyping = true);
    final words = fullText.split(' ');
    String currentText = "";

    setState(() {
      _messages.add({"role": "assistant", "content": ""});
    });

    for (int i = 0; i < words.length; i += 3) {
      final chunk = words.skip(i).take(3).join(' ');
      await Future.delayed(const Duration(milliseconds: 100));
      currentText += (currentText.isEmpty ? '' : ' ') + chunk;
      setState(() {
        _messages.last["content"] = currentText;
      });
      _scrollToBottom();
    }

    setState(() => _isTyping = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("ChatGPT Demo"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TypingIndicator(),
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg["role"] == "user";

                // User message → use MessageBubble
                if (isUser) {
                  return MessageBubble(
                    isUser: true,
                    message: msg["content"],
                  );
                }

                // Assistant message → plain Markdown
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MarkdownBody(
                        data: msg["content"],
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildChatGPTStyleInput(context),
        ],
      ),
    );
  }

  /// ChatGPT-style rounded input box with mic/send icon
  Widget _buildChatGPTStyleInput(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: StatefulBuilder(
          builder: (context, setInnerState) {
            final focusNode = FocusNode();
            bool isFocused = false;

            focusNode.addListener(() {
              setInnerState(() => isFocused = focusNode.hasFocus);
            });

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isFocused ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isFocused
                      ? theme.colorScheme.primary
                      : Colors.grey.shade300,
                  width: isFocused ? 1.5 : 1,
                ),
                boxShadow: isFocused
                    ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
                    : [],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.grey, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: _controller,
                      maxLines: null,
                      style: const TextStyle(fontSize: 16),
                      onChanged: (_) => setInnerState(() {}),
                      decoration: const InputDecoration(
                        hintText: "Ask anything",
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: _controller.text.isEmpty
                        ? GestureDetector(
                      key: const ValueKey("mic"),
                      onTap: () {},
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic,
                            color: Colors.white, size: 18),
                      ),
                    )
                        : GestureDetector(
                      key: const ValueKey("send"),
                      onTap: _sendMessage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Small three-dot typing animation (like ChatGPT)
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        int dotCount = (3 * _controller.value).floor() + 1;
        return Text(
          '.' * dotCount,
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
