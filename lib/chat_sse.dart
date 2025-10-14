import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';

class KidsGPTChatPage extends StatefulWidget {
  const KidsGPTChatPage({super.key});

  @override
  State<KidsGPTChatPage> createState() => _KidsGPTChatPageState();
}

class _KidsGPTChatPageState extends State<KidsGPTChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _initGreeting();
  }

  void _initGreeting() {
    Future.delayed(const Duration(milliseconds: 400), () {
      _fakeStreamResponse(
        "Xin chào! Em là **Kids GPT**, trợ lý AI chuyên tư vấn mẹ và bé từ **Con Cưng**.\n\n"
            "Em đồng hành cùng ba mẹ trong việc lựa chọn mọi sản phẩm lý tưởng cho bé "
            "và giải đáp mọi thắc mắc một cách chu đáo, hiệu quả.",
      );
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(role: "user", content: text));
    });
    _input.clear();
    _fakeStreamResponse("Đây là phản hồi ví dụ cho câu hỏi: **$text**");
  }

  void _fakeStreamResponse(String fullText) {
    final msg = ChatMessage(role: "assistant", content: "", isStreaming: true);
    setState(() => _messages.add(msg));

    int i = 0;
    final timer = Timer.periodic(const Duration(milliseconds: 35), (t) {
      if (i < fullText.length) {
        setState(() => msg.content = fullText.substring(0, i + 1));
        _scrollToEnd();
        i++;
      } else {
        t.cancel();
        setState(() => msg.isStreaming = false);
      }
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildBubble(_messages[i]),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: const AssetImage("assets/kidsgpt.png"),
            radius: 18,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Kids GPT",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              Text("Trợ lý AI", style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          )
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.edit_note_rounded, color: Colors.black54),
        )
      ],
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.role == "user";
    final bubbleColor = isUser ? Colors.grey[100] : Colors.white;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        child: msg.role == "user"
            ? Text(msg.content, style: const TextStyle(fontSize: 15))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 300),
              child:
              StreamingTextMarkdown(
               text:  msg.content + '<span style="opacity:0.4">hahaha </span>',
                animationsEnabled: true,
                fadeInEnabled: true,
                markdownEnabled: true,
                // preset: LLMAnimationPresets.chatGPT,
                // fadeInCurve: Curves.fastOutSlowIn,
                // fadeInEnabled: true,
                // fadeInDuration: Duration(milliseconds: 300),
              )


            ),
            const SizedBox(height: 8),
            if (!msg.isStreaming)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.copy, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Icon(Icons.thumb_down_alt_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Icon(Icons.refresh_rounded, size: 20, color: Colors.grey[600]),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                decoration: InputDecoration(
                  hintText: "Hỏi bất cứ điều gì",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => _sendMessage(_input.text),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String role;
  String content;
  bool isStreaming;

  ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
  });
}

