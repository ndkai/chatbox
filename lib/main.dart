import 'dart:async';
import 'dart:math';
import 'package:chat_demo/widgets/assistant_message.dart';
import 'package:chat_demo/widgets/loading_widget.dart';
import 'package:chat_demo/widgets/streaming_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models/chat_message.dart';
import 'models/sse_event.dart';

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
      _messages.add(ChatMessage(role: ChatMessageRole.user, text: text));
    });
    _scrollToBottom();
    setState(() {
      _messages.add(ChatMessage(role: ChatMessageRole.assistant, text: text, type: ChatMessageType.loading));
    });
    _input.clear();

    // _mockAIResponse();
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

  void _scrollToMessage(ChatMessage target) {
    final ctx = target.key.currentContext;
    if (ctx == null || !_scroll.hasClients) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.1, // optional, controls where the item lands on screen
    );
  }


  AppBar _buildAppBar(){
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          // 🔹 Avatar
          Icon(Icons.arrow_back_ios, size: 20,),
          const SizedBox(width: 12),
          Image.asset("assets/logo.png",),
          const SizedBox(width: 6),
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
          Spacer(),
          Image.asset("assets/edit.png",)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Message list
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  addAutomaticKeepAlives: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length+1,
                  itemBuilder: (context, i) {
                    if(i  == _messages.length){
                      return Container(height: MediaQuery.of(context).size.height * 0.6, color: Colors.transparent,);
                    }
                    final msg = _messages[i];
                    final isUser = msg.role == ChatMessageRole.user;
                    if(msg.role == ChatMessageRole.user){
                      return Align(
                        alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[50] : Colors.transparent,
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
                            fadeDuration: const Duration(milliseconds: 800),
                            chunkDebounce: const Duration(milliseconds: 300),
                            isStreaming: msg.isStreaming,
                            text: _messages[i].text,
                            onChanged: (String value) {
                              _messages[i].text = value;
                              _messages[i].isStreaming = false;
                            },
                          ),
                        ),
                      );
                    }
                    return AssistantMessage();


                  },
                ),
              ),
              // 🔹 Input bar
              _buildInputBar()
            ],
          ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.13,
            child: InkWell(
              onTap: (){
                _scrollToBottom();
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18.5,
                  child: Center(
                    child: Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ),
              ),
            )
          )
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
