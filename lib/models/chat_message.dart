import 'dart:async';

import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final ChatMessageRole role;
  final ChatMessageType type;
  String text;
  bool isStreaming;
  final GlobalKey key;
  final StreamController<String>? stream;
  ChatMessage({required this.role, this.text = "", this.stream, this.isStreaming = true, this.type = ChatMessageType.message, })
      : id = UniqueKey().toString(), key = GlobalKey();
}

enum ChatMessageRole{
  user, assistant
}

enum ChatMessageType{
  loading, analyze, message, explore
}