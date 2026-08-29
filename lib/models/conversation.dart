// lib/models/conversation.dart
import 'package:uuid/uuid.dart';
import 'chat_message.dart';

/// Represents a complete conversation with multiple messages
class Conversation {
  final String id;
  final String assistantName;
  final String accentColorHex; // Store color as hex string
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;
  final bool isActive;

  Conversation({
    String? id,
    required this.assistantName,
    required this.accentColorHex,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<ChatMessage>? messages,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastMessageAt = lastMessageAt ?? DateTime.now(),
        messages = messages ?? [];

  /// Get last 50 messages
  List<ChatMessage> getLast50Messages() {
    if (messages.length <= 50) return messages;
    return messages.sublist(messages.length - 50);
  }

  /// Get conversation date label (e.g., "Today", "Yesterday", "Mar 15")
  String getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (messageDate == today) {
      return "Today";
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    } else {
      return "${createdAt.month}/${createdAt.day}/${createdAt.year}";
    }
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assistantName': assistantName,
      'accentColorHex': accentColorHex,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      assistantName: json['assistantName'] as String,
      accentColorHex: json['accentColorHex'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      messages: (json['messages'] as List?)
          ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Create a copy with updated fields
  Conversation copyWith({
    String? id,
    String? assistantName,
    String? accentColorHex,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<ChatMessage>? messages,
    bool? isActive,
  }) {
    return Conversation(
      id: id ?? this.id,
      assistantName: assistantName ?? this.assistantName,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
    );
  }
}