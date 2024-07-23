import 'package:cardiocare/services/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

enum MessageStatus { sent, loading, failed }

class ChatMessage {
  int? id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  MessageStatus status;

  ChatMessage({
    this.id,
    required this.text,
    required this.isFromUser,
    required this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map[idColumn] as int?,
      text: map[messageColumn] as String,
      isFromUser: (map[isFromUserColumn] as int) == 1,
      status: MessageStatus.values[map[statusColumn] as int],
      timestamp: DateTime.parse(map[timestampColumn] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      messageColumn: text,
      isFromUserColumn: isFromUser ? 1 : 0,
      statusColumn: status.index,
      timestampColumn: timestamp.toIso8601String(),
    };
  }

  Content toContent() => Content.text(text);

  @override
  String toString() {
    return 'ChatMessage(id: $id, text: $text, isFromUser: $isFromUser, status: $status, timestamp: $timestamp)';
  }
}
