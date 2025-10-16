import 'dart:convert';

/// Represents a generic SSE event from KidsGPT backend.
class SSEEvent {
  final String event;
  final dynamic data;

  SSEEvent({required this.event, required this.data});

  /// Parses a raw SSE `event:` and `data:` pair
  factory SSEEvent.fromRaw(String rawEvent, String rawData) {
    final eventName = rawEvent.replaceFirst('event:', '').trim();
    final jsonString = rawData.replaceFirst('data:', '').trim();

    if (jsonString.isEmpty) {
      return SSEEvent(event: eventName, data: null);
    }

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return SSEEvent(event: eventName, data: _decodeUtf8Json(jsonMap));
    } catch (e) {
      print("⚠️ Failed to decode JSON: $jsonString");
      return SSEEvent(event: eventName, data: jsonString);
    }
  }

  /// Decodes all \uXXXX escaped characters in any nested JSON map
  static dynamic _decodeUtf8Json(dynamic value) {
    if (value is String) {
      try {
        return jsonDecode('"$value"');
      } catch (_) {
        return value;
      }
    } else if (value is List) {
      return value.map(_decodeUtf8Json).toList();
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k, _decodeUtf8Json(v)));
    }
    return value;
  }

  @override
  String toString() => 'SSEEvent(event: $event, data: $data)';
}
