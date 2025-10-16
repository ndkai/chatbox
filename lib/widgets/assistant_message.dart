import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_demo/widgets/chat_actions.dart';
import 'package:chat_demo/widgets/loading_widget.dart';
import 'package:chat_demo/widgets/product_count_badge.dart';
import 'package:chat_demo/widgets/streaming_text.dart';
import 'package:flutter/material.dart';

import '../models/sse_event.dart';
import 'followup_suggestion.dart';

class AssistantMessage extends StatefulWidget {
  const AssistantMessage({super.key});

  @override
  State<AssistantMessage> createState() => _AssistantMessageState();
}

class _AssistantMessageState extends State<AssistantMessage> {
  final String baseUrl = "https://chatbot-api-uat.concung.vn/sse/chat";
  bool showLoading = true;
  bool showAnnalist = false;
  bool showProductsBadge = false;
  bool showSuggestion = false;
  List<String> suggestions = [];
  List<String> productRelevance = [];
  double annalistDuration = 0;
  StreamController<String> greeting = StreamController<String>();
  StreamController<String> message = StreamController<String>();

  Future<void> _startSSE() async {
    final uri = Uri.parse(
      "$baseUrl?message=message_2&user_id=user_01&thread_id=user_01_01",
    );

    final request = http.Request("GET", uri);
    request.headers.addAll({
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    });

    final response = await request.send();
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      showLoading = false;
      showAnnalist = true;
    });
    if (response.statusCode == 200) {
      String? currentEvent;

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        for (final line in LineSplitter.split(chunk)) {
          if (line.startsWith('event:')) {
            currentEvent = line;
          } else if (line.startsWith('data:') && currentEvent != null) {
            final event = SSEEvent.fromRaw(currentEvent!, line);

            switch (event.event) {
              case 'stream_token':
                final token = event.data?['token'] ?? '';
                message.add(token);
                await Future.delayed(const Duration(milliseconds: 1000));
                break;

              case 'pre_analysis':
                final splits = event.data?['content'].toString().split(" ");
                String content = "";
                for(int i = 0; i < splits!.length; i+=5){
                  content = "${splits.skip(i).take(5).join(" ")} ";
                  greeting.add(content);
                  await Future.delayed(const Duration(milliseconds: 1000));
                }
                greeting.close();
                break;

              case 'exploring_request':
                if(event.data?["status"] == "completed"){
                  setState(() {
                    showAnnalist = false;
                    annalistDuration = event.data?["duration"];
                  });
                }

                break;

              case 'search_results':
                print("🔍 Search results: ${event.data}");
                break;

              case 'enrich_response':
                setState(() {
                  showProductsBadge = true;
                  showSuggestion = true;
                });
                print("✨ Suggestions: ${event.data?['suggestions']}");
                print("🛒 Products: ${event.data?['product_relevance']}");
                break;

              case 'stream_end':
                print("✅ Stream ended for session ${event.data?['session_id']}");
                break;

              default:
                print("📨 Unknown event ${event.event}: ${event.data}");
            }
          }
        }
      }

    } else {
      debugPrint("❌ SSE failed: ${response.statusCode}");
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startSSE();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(child: LoadingWidget(), visible: showLoading,),
        _buildMessage(greeting),
        _buildExplore(),
        _buildExploreDone(),
        _buildMessage(message),
        _buildProductCountPage(),
        _buildChatAction(),
        _buildSuggestion(),
      ],
    );
  }

  Widget _buildChatAction(){
    return Visibility(child: ChatActions(), visible: showSuggestion,);
  }

  Widget _buildSuggestion(){
    return Visibility(child: FollowUpSuggestions(suggestions: [
      "Thực đơn tăng cường miễn dịch cho bé",
      "Tăng cường miễn dịch tự nhiên",
    ],), visible: showSuggestion,);
  }


  Widget _buildProductCountPage(){
    return Visibility(child: ProductCountBadge(imageUrls: [
      "https://cdn1.concung.com/2024/10/50130-114467-large_mobile/sua-frisolac-gold-pro-so-1-800g-0-6-thang.png",
      "https://cdn1.concung.com/2024/10/50130-114467-large_mobile/sua-frisolac-gold-pro-so-1-800g-0-6-thang.png",
      "https://cdn1.concung.com/2024/10/50130-114467-large_mobile/sua-frisolac-gold-pro-so-1-800g-0-6-thang.png",
      "https://cdn1.concung.com/2024/10/50130-114467-large_mobile/sua-frisolac-gold-pro-so-1-800g-0-6-thang.png",
    ], totalCount: 3,), visible: showProductsBadge,);
  }

  Widget _buildMessage(StreamController<String> streamController){
    return  Align(
      alignment: Alignment.centerLeft,
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9),
          child: MarkdownFadingStreamer(
            tokenStream: streamController,
            fadeDuration: const Duration(milliseconds: 800),
            chunkDebounce: const Duration(milliseconds: 300),
            isStreaming: true,
            onChanged: (String value) {

            },
          )
      ),
    );
  }

  Widget _buildExplore(){
    return Visibility(visible: showAnnalist,child: Align(
      alignment:
      Alignment.centerLeft,
      child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9),
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.withOpacity(.3))
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.black,
                  ),
                ),
                Text("   Khám phá yêu cầu", style: TextStyle(fontSize: 13),)
              ],
            ),
          )
      ),
    ),);
  }

  Widget _buildExploreDone(){
    return Visibility(visible: annalistDuration > 0,child: Align(
      alignment:
      Alignment.centerLeft,
      child: Container(
          margin: const EdgeInsets.only(left: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.withOpacity(.3))
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset("assets/ai.png", width: 20,),
                Text(" Suy nghĩ trong ${annalistDuration} giây", style: TextStyle(fontSize: 13))
              ],
            ),
          )
      ),
    ),);
  }
}
