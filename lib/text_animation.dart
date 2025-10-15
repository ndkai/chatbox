import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownFadingStreamer extends StatefulWidget {
  final StreamController<String> tokenStream;
  final Duration fadeDuration;
  final Duration chunkDebounce;
  final ValueChanged<String> onChanged;
   String text;
   bool isStreaming;

   MarkdownFadingStreamer({
    super.key,
     this.text = "",
     required this.tokenStream,
     this.isStreaming = false,
    this.fadeDuration = const Duration(milliseconds: 3000),
    this.chunkDebounce = const Duration(milliseconds: 1200), required this.onChanged,
  });

  @override
  State<MarkdownFadingStreamer> createState() => _MarkdownFadingStreamerState();
}

class _MarkdownFadingStreamerState extends State<MarkdownFadingStreamer>
    with TickerProviderStateMixin {
  late final StreamSubscription<String> _sub;
  final StringBuffer _stable = StringBuffer(); // text đã render xong
  final StringBuffer _pending = StringBuffer(); // text chờ render
  String _animating = '';
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  Timer? _debounce;


  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: widget.fadeDuration);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    if(widget.isStreaming){
      try{
        _sub = widget.tokenStream.stream.listen((token) {
          _pending.write(token);
          _debounce?.cancel();
          _debounce = Timer(widget.chunkDebounce, _startFade);
        }, onDone: (){
          widget.onChanged(_stable.toString());
          _sub.cancel();

        });
      } catch(e){

      }
    } else {
      _stable.write(widget.text);
    }

  }

  void _startFade() {
    if (_pending.isEmpty) return;

    final temp = _stable.toString() + _pending.toString();

    // ✅ Kiểm tra markdown có hợp lệ không trước khi fade
    if (_isValidMarkdown(temp)) {
      setState(() {
        _animating = _pending.toString();
        _pending.clear();
      });

      _fadeCtrl.forward(from: 0).whenComplete(() {
        setState(() {
          _stable.write(_animating);
          _animating = '';
        });
      });
    } else {
      // ❌ Nếu chưa hợp lệ: giữ _pending lại để cộng thêm chunk sau
      // không render
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _fadeCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _fadeAnim,
      builder: (context, _) {
        // Markdown được ghép từ phần đã ổn định + phần đang fade
        final visible = _stable.toString() + _animating;

        return Stack(
          children: [
            MarkdownBody(
              data: _stable.toString(), // phần text đã xong (opacity 1)
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(p: const TextStyle(fontSize: 13, height: 1.4)),
            ),
            // phần mới đến: fade-in dần
            if (_animating.isNotEmpty)
              Opacity(
                opacity: _fadeAnim.value,
                child: MarkdownBody(
                  data: visible,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                    p: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _isValidMarkdown(String text) {
    try {
      // 1️⃣ Check markdown syntax basic — đóng đủ dấu `**`, `*`, `#`, ```
      final boldOpened = RegExp(r'\*\*').allMatches(text).length % 2 == 0;
      final italicOpened = RegExp(r'(?<!\*)\*(?!\*)').allMatches(text).length % 2 == 0;
      final codeBlockOpened = RegExp(r'```').allMatches(text).length % 2 == 0;

      if (!boldOpened || !italicOpened || !codeBlockOpened) return false;

      // 2️⃣ Test parsing bằng cách dựng MarkdownBody "ẩn"
      final widget = MarkdownBody(data: text);

      return true;
    } catch (e) {
      // 3️⃣ Nếu parser throw error, markdown chưa hợp lệ
      return false;
    }
  }


}
