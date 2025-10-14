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

  // === Streaming controls ===
  static const int subChunkSize = 12; // ký tự / sub-chunk (mịn hơn: 5–15)
  static const int subChunkDelayMs = 60; // ms giữa các sub-chunk
  static const int deltaDelayMs = 800; // ms giữa các "message_delta" lớn

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "content": text});
    });
    _scrollToBottom();

    // Fake streaming: dùng data chia nhỏ giống ChatGPT
    _fakeChatGPTResponse(_sampleStreamData);
  }

  Future<void> _fakeChatGPTResponse(List<dynamic> data) async {
    setState(() => _isTyping = true);

    // Thêm 1 message assistant rỗng để append dần
    setState(() {
      _messages.add({"role": "assistant", "content": ""});
    });

    String currentText = "";

    for (final event in data) {
      if (event["type"] == "message_delta") {
        final delta = event["delta"];
        if (delta != null && delta["content"] != null) {
          final contentList = delta["content"] as List<dynamic>;
          final bigChunk = contentList
              .where((e) => e["type"] == "text")
              .map((e) => e["text"])
              .join("");

          // (A) chờ nhẹ giữa các delta lớn (giống server gửi theo block)
          await Future.delayed(Duration(milliseconds: deltaDelayMs));

          // (B) chia nhỏ bigChunk thành nhiều sub-chunk để gõ mịn hơn
          for (final small in _splitBySize(bigChunk, subChunkSize)) {
            await Future.delayed(Duration(milliseconds: subChunkDelayMs));
            currentText += small;

            setState(() {
              _messages.last["content"] = currentText;
            });
            // _scrollToBottom();
          }
        }
      }
    }

    setState(() => _isTyping = false);
  }

  List<String> _splitBySize(String input, int size) {
    if (input.isEmpty || size <= 0) return [input];
    final list = <String>[];
    for (int i = 0; i < input.length; i += size) {
      list.add(input.substring(i, i + size > input.length ? input.length : i + size));
    }
    return list;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("ChatGPT Streaming Markdown"),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Align(alignment: Alignment.centerLeft, child: _TypingIndicator()),
                  );
                }

                final msg = _messages[index];
                final isUser = msg["role"] == "user";

                if (isUser) {
                  return MessageBubble(isUser: true, message: msg["content"]);
                }

                // Assistant bubble with Markdown
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .94),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:AnimatedMarkdownText(
                        fullText: msg["content"],
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
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: isFocused ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isFocused ? theme.colorScheme.primary : Colors.grey.shade300,
                  width: isFocused ? 1.5 : 1,
                ),
                boxShadow: isFocused
                    ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.18),
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
                      decoration: const InputDecoration(
                        hintText: "Ask anything",
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
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

// ======== Typing indicator ========
// (Giống 3 chấm đang gõ)
}

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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        int dotCount = (3 * _controller.value).floor() + 1;
        return Text(
          '.' * dotCount,
          style: TextStyle(fontSize: 20, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
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

// ================== SAMPLE STREAM DATA (đã chia nhỏ hợp lý) ==================
final List<Map<String, dynamic>> _sampleStreamData = [
  {
    "type": "message_start",
    "message": {"id": "msg_001", "role": "assistant", "model": "gpt-5", "content": []}
  },

  // title
  {
    "type": "message_delta",
    "delta": {
      "content": [
        {"type": "text", "text": "# 🥛 Top Các Loại Sữa Tốt Nhất Thế Giới (Cập Nhật 2025)\n\n"}
      ]
    }
  },

  // intro
  {
    "type": "message_delta",
    "delta": {
      "content": [
        {"type": "text", "text": "Sữa là nguồn cung cấp **canxi, protein, vitamin D, B12** và nhiều khoáng chất quan trọng.\n"}
      ]
    }
  },
  {
    "type": "message_delta",
    "delta": {
      "content": [
        {"type": "text", "text": "Dưới đây là danh sách **loại sữa & thương hiệu nổi bật** năm 2025.\n\n"}
      ]
    }
  },

  // section 1
  {
    "type": "message_delta",
    "delta": {
      "content": [
        {"type": "text", "text": "## 🧠 I. Phân Loại Sữa Phổ Biến\n\n### 1. 🐄 Sữa Bò (Cow’s Milk)\n"}
      ]
    }
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "- **Ưu điểm:** Giàu canxi, protein tự nhiên, vitamin A và D.\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "- **Nhược điểm:** Có lactose, dễ gây khó tiêu với người nhạy cảm.\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "- **Thương hiệu:** FrieslandCampina, Organic Valley, Meiji.\n\n"}]}
  },

  // section 2
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "### 2. 🌿 Sữa Hữu Cơ (Organic Milk)\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "- Nuôi tự nhiên, không hormone, không kháng sinh.\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "- Thương hiệu: Maple Hill, Horizon Organic.\n\n"}]}
  },

  // section 3
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "### 3. 🥥 Sữa Thực Vật (Plant-Based Milk)\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "- Gồm: Oat, Almond, Soy.\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "- Thương hiệu: Oatly, Alpro, Silk.\n\n"}]}
  },

  // table section
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "## 🏆 Top Thương Hiệu Sữa Toàn Cầu 2025\n\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {
      "content": [
        {
          "type": "text",
          "text":
          "| Hạng | Thương hiệu | Quốc gia |\n|:--:|:------------------|:----------|\n| 🥇 | FrieslandCampina | 🇳🇱 Hà Lan |\n| 🥈 | Lactalis | 🇫🇷 Pháp |\n| 🥉 | Nestlé | 🇨🇭 Thụy Sĩ |\n| 4️⃣ | Fonterra | 🇳🇿 New Zealand |\n| 5️⃣ | Danone | 🇫🇷 Pháp |\n\n"
        }
      ]
    }
  },

  // advice
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "## 💬 Lời Khuyên\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "> Hãy chọn loại sữa phù hợp nhu cầu của bạn.\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "Không dung nạp lactose → ưu tiên **sữa A2** hoặc **sữa thực vật**.\n\n"}]}
  },
  {
    "type": "message_delta",
    "delta": {"content": [{"type": "text", "text": "✨ *Sức khỏe bắt đầu từ ly sữa mỗi ngày!*\n"}]}
  },

  {"type": "message_stop"}
];

class AnimatedMarkdownText extends StatefulWidget {
  final String fullText;
  const AnimatedMarkdownText({super.key, required this.fullText});

  @override
  State<AnimatedMarkdownText> createState() => _AnimatedMarkdownTextState();
}

class _AnimatedMarkdownTextState extends State<AnimatedMarkdownText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  String _visibleText = ""; // text đã hiển thị ổn định
  String _fadingText = "";  // phần text mới đang fade-in

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _visibleText = widget.fullText;
  }

  @override
  void didUpdateWidget(covariant AnimatedMarkdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fullText != oldWidget.fullText) {
      final oldLen = oldWidget.fullText.length;
      if (widget.fullText.length > oldLen) {
        final newPart = widget.fullText.substring(oldLen);

        setState(() {
          _visibleText = oldWidget.fullText;
          _fadingText = newPart;
        });

        // bắt đầu fade-in
        _controller.forward(from: 0).whenComplete(() {
          // sau khi fade xong, ghép phần mới vào và clear
          setState(() {
            _visibleText = widget.fullText;
            _fadingText = "";
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MarkdownBody(
          data: _visibleText,
          selectable: true,
          styleSheet: _styleSheet,
        ),
        if (_fadingText.isNotEmpty)
          FadeTransition(
            opacity: _fade,
            child: MarkdownBody(
              data: _visibleText + _fadingText,
              selectable: true,
              styleSheet: _styleSheet,
            ),
          ),
      ],
    );
  }

  MarkdownStyleSheet get _styleSheet => MarkdownStyleSheet(
    p: const TextStyle(fontSize: 16, height: 1.4),
    codeblockDecoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
    ),
    blockquoteDecoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(6),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

