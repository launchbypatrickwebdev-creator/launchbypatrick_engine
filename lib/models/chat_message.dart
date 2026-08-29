// lib/models/chat_message.dart
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Represents a single message in a conversation
class ChatMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final String? voiceInputIndicator;
  final bool isRead;
  final bool isEdited;
  final String? editedAt;

  ChatMessage({
    String? id,
    required this.content,
    required this.sender,
    DateTime? timestamp,
    this.voiceInputIndicator,
    this.isRead = false,
    this.isEdited = false,
    this.editedAt,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Format time for display
  String getFormattedTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday ${DateFormat('h:mm a').format(timestamp)}";
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  /// Create a copy with updated fields (for editing)
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    String? voiceInputIndicator,
    bool? isRead,
    bool? isEdited,
    String? editedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      voiceInputIndicator: voiceInputIndicator ?? this.voiceInputIndicator,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.toString(),
      'timestamp': timestamp.toIso8601String(),
      'voiceInputIndicator': voiceInputIndicator,
      'isRead': isRead,
      'isEdited': isEdited,
      'editedAt': editedAt,
    };
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: json['sender'] == 'MessageSender.ai'
          ? MessageSender.ai
          : MessageSender.user,
      timestamp: DateTime.parse(json['timestamp'] as String),
      voiceInputIndicator: json['voiceInputIndicator'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] as String?,
    );
  }
}

enum MessageSender {
  user,
  ai,
}