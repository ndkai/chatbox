import 'dart:async';
import 'package:flutter/material.dart';
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

    // simulate response
    _fakeChatGPTResponse("Sure! Here's an example of streaming response that renders three words at a time like ChatGPT typing effect.");
  }

  Future<void> _fakeChatGPTResponse(String fullText) async {
    setState(() => _isTyping = true);
    final words = fullText.split(' ');
    String currentText = "";

    // Add empty assistant message first
    setState(() {
      _messages.add({"role": "assistant", "content": ""});
    });

    for (int i = 0; i < words.length; i += 3) {
      final chunk = words.skip(i).take(3).join(' ');
      await Future.delayed(const Duration(milliseconds: 200));
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
                return MessageBubble(
                  isUser: msg["role"] == "user",
                  message: msg["content"],
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Send a message...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
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
