import 'dart:async';
import 'dart:math';
import 'package:chat_demo/text_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(const ChatGPTMockApp());

class ChatGPTMockApp extends StatelessWidget {
  const ChatGPTMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ChatGPT Mock Demo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const ChatGPTMockPage(),
    );
  }
}

class ChatGPTMockPage extends StatefulWidget {
  const ChatGPTMockPage({super.key});

  @override
  State<ChatGPTMockPage> createState() => _ChatGPTMockPageState();
}

class _ChatGPTMockPageState extends State<ChatGPTMockPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(role: "user", text: text));
    });
    _input.clear();
    _mockAIResponse(text);
  }

  /// 🔹 Giả lập phản hồi của ChatGPT (stream từng chunk)
  void _mockAIResponse(String question) {
    final streamCtrl = StreamController<String>();
    final message = ChatMessage(role: "assistant", stream: streamCtrl);
    setState(() => _messages.add(message));

    // 🔹 Nội dung markdown dài (~1000 từ)
    final fullText = """
# 🍼 Các loại sữa tốt nhất hiện nay (2025)

Xin chào! Dưới đây là **phân tích chi tiết và toàn diện** về các loại sữa bột, sữa công thức tốt nhất trên thị trường Việt Nam hiện nay.  
Mình sẽ giúp bạn hiểu rõ về **thành phần dinh dưỡng**, **ưu điểm từng thương hiệu**, và **gợi ý lựa chọn phù hợp** nhất cho bé.

---

## 🧭 Tiêu chí đánh giá “sữa tốt”
Một loại sữa được coi là “tốt” không chỉ vì thương hiệu mà còn vì:

1. **Phù hợp độ tuổi**  
   Mỗi giai đoạn phát triển của bé cần tỷ lệ đạm, chất béo và vi chất khác nhau.  
   - 0–6 tháng: tập trung DHA, đạm whey, chất béo MCT.  
   - 6–12 tháng: thêm chất xơ FOS, canxi, sắt, vitamin D.  
   - Trên 1 tuổi: bổ sung thêm năng lượng, vitamin A, kẽm, omega 3–6.

2. **Công thức dễ tiêu hóa**  
   Một sữa tốt cần hỗ trợ tiêu hóa, hấp thu tốt và **ít gây táo bón**.  
   Các thành phần như **GOS, FOS, HMO, Probiotic, Prebiotic** là dấu hiệu tốt.

3. **Nguồn gốc rõ ràng, an toàn**  
   Ưu tiên sữa **nhập khẩu chính hãng hoặc sản xuất nội địa có chứng nhận ISO, HACCP, GMP**.  
   Tránh sữa xách tay trôi nổi, không nhãn phụ tiếng Việt.

---

## 🧩 Top 5 thương hiệu sữa nổi bật

### 1. **Meiji – Nhật Bản**
- Meiji Infant (0–12M) và Meiji Step (1–3 tuổi) là 2 dòng được yêu thích nhất.  
- Vị sữa nhạt, dễ uống, công thức “mát”, ít gây táo bón.  
- Chứa DHA, ARA, taurine, nucleotides, vitamin và khoáng chất đầy đủ.  
- **Ưu điểm:** Rất “hiền” với hệ tiêu hóa, hợp với thể trạng trẻ châu Á.  
- **Nhược điểm:** Giá cao, cần mua đúng hàng chính hãng.

---

### 2. **Similac / Abbott – Mỹ**
- Dòng **Similac 5G** hoặc **Similac IQ Plus HMO** nổi bật nhờ bổ sung **2'-FL HMO**, giúp tăng cường miễn dịch tự nhiên.  
- Ngoài ra, Abbott có các dòng đặc biệt như *Similac Total Comfort* (dễ tiêu hóa) và *Similac GainPlus* (tăng cân).  
- **Ưu điểm:** Công nghệ tiên tiến, nghiên cứu khoa học lâu năm.  
- **Nhược điểm:** Giá thành cao, vị hơi ngọt.

---

### 3. **Friso Gold – Hà Lan**
- Công nghệ **LockNutri™** giữ trọn vẹn dưỡng chất tự nhiên của sữa tươi.  
- Chứa **Synbiotic (Probiotic + Prebiotic)** giúp hệ tiêu hóa khỏe mạnh.  
- Vị sữa thanh, dễ hòa tan, bé dễ làm quen.  
- **Ưu điểm:** Giúp bé tiêu hóa tốt, hiếm khi bị táo bón.  
- **Nhược điểm:** Không phù hợp với trẻ dị ứng đạm bò.

---

### 4. **Vinamilk – Việt Nam**
- Các dòng nổi bật: **Optimum Gold**, **Dielac Alpha**, **Colosbaby**.  
- Tăng cường kháng thể IgG, bổ sung DHA, ARA, lysine và chất xơ hòa tan.  
- **Ưu điểm:** Giá hợp lý, phù hợp thể trạng trẻ Việt, dễ mua.  
- **Nhược điểm:** Chưa có nhiều phiên bản chuyên biệt (ví dụ: không lactose, đạm thủy phân).

Ví dụ công thức sữa Vinamilk Optimum Gold:
""";
    final responses = fullText.split(" ");
    int i = 0;
    final random = Random();
    Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (i < responses.length) {
        final take = random.nextInt(10) + 1;
        final chunk = responses.skip(i).take(take).join(" ");
        streamCtrl.add(chunk + " ");
        i += take;
        _scrollToBottom();
      } else {
        streamCtrl.close();
        t.cancel();

      }
    });


}



  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            // 🔹 Avatar
            SvgPicture.asset("assets/logo.svg",),
            const SizedBox(width: 8),
            // 🔹 Title
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kids GPT",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                Text(
                  "Trợ lý AI",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔹 Message list
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              addAutomaticKeepAlives: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                print("_messages[i].isStreaming ${_messages[i].isStreaming}");
                final msg = _messages[i];
                final isUser = msg.role == "user";
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[50] : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft:
                        isUser ? const Radius.circular(12) : const Radius.circular(0),
                        bottomRight:
                        isUser ? const Radius.circular(0) : const Radius.circular(12),
                      ),
                    ),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9),
                    child: isUser
                        ? Text(
                      msg.text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    )
                        : MarkdownFadingStreamer(
                      tokenStream: msg.stream!,
                      fadeDuration: const Duration(milliseconds: 400),
                      chunkDebounce: const Duration(milliseconds: 150),
                        isStreaming: msg.isStreaming,
                      text: _messages[i].text,
                      onChanged: (String value) {
                        _messages[i].text = value;
                        _messages[i].isStreaming = false;
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 Input bar
          _buildInputBar()
        ],
      ),
    );

  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // 🔹 Input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _input,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Hỏi bất cứ điều gì",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 🔹 Send button
            InkWell(
              onTap: () => _sendMessage(_input.text),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/// ------------------------------------------------------------
/// Chat message model
/// ------------------------------------------------------------
class ChatMessage {
  final String id;
  final String role; // "user" or "assistant"
   String text;
   bool isStreaming;
  final StreamController<String>? stream;
  ChatMessage({required this.role, this.text = "", this.stream, this.isStreaming = true})
      : id = UniqueKey().toString();
}

/// ------------------------------------------------------------
/// Markdown fading streamer widget
/// ------------------------------------------------------------
// class MarkdownFadingStreamer extends StatefulWidget {
//   final Stream<String> tokenStream;
//   final Duration fadeDuration;
//   final Duration chunkDebounce;
//
//   const MarkdownFadingStreamer({
//     super.key,
//     required this.tokenStream,
//     this.fadeDuration = const Duration(milliseconds: 250),
//     this.chunkDebounce = const Duration(milliseconds: 100),
//   });
//
//   @override
//   State<MarkdownFadingStreamer> createState() => _MarkdownFadingStreamerState();
// }
//
// class _MarkdownFadingStreamerState extends State<MarkdownFadingStreamer>
//     with TickerProviderStateMixin {
//   late final StreamSubscription<String> _sub;
//   final StringBuffer _stable = StringBuffer();
//   final StringBuffer _pending = StringBuffer();
//   String _animating = '';
//
//   late final AnimationController _fadeCtrl;
//   late final Animation<double> _fadeAnim;
//   Timer? _debounce;
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeCtrl = AnimationController(vsync: this, duration: widget.fadeDuration);
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
//
//     _sub = widget.tokenStream.listen((token) {
//       _pending.write(token);
//       _debounce?.cancel();
//       _debounce = Timer(widget.chunkDebounce, _flushPending);
//     });
//   }
//
//   void _flushPending() {
//     if (_pending.isEmpty) return;
//     setState(() {
//       _animating = _pending.toString();
//       _pending.clear();
//     });
//
//     _fadeCtrl.forward(from: 0).whenComplete(() {
//       setState(() {
//         _stable.write(_animating);
//         _animating = '';
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _sub.cancel();
//     _fadeCtrl.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _fadeAnim,
//       builder: (context, _) {
//         final visibleText = _stable.toString() +
//             (_animating.isNotEmpty ? _animating : '');
//         return Opacity(
//           opacity: _fadeAnim.value,
//           child: MarkdownBody(
//             data: visibleText,
//             styleSheet:
//             MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
//               p: const TextStyle(fontSize: 15, height: 1.4),
//               codeblockDecoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
