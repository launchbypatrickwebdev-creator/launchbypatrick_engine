// lib/services/conversation_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/conversation.dart';

/// Service to manage conversation persistence (all conversations history)
class ConversationStorageService {
  static const String _storageKey = 'all_conversations';

  /// Get all conversations
  Future<List<Conversation>> getAllConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt)); // Newest first
    } catch (e) {
      return [];
    }
  }

  /// Get single conversation by ID
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      final conversations = await getAllConversations();
      return conversations.firstWhere(
            (c) => c.id == conversationId,
        orElse: () => throw Exception('Not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Save or update conversation
  Future<void> saveConversation(Conversation conversation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversations = await getAllConversations();

      // Remove old version if exists
      conversations.removeWhere((c) => c.id == conversation.id);

      // Add updated conversation
      conversations.insert(0, conversation);

      // Keep only last 20 conversations to avoid storage bloat
      if (conversations.length > 20) {
        conversations.removeRange(20, conversations.length);
      }

      final jsonList = conversations.map((c) => c.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      // Silently fail
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversations = await getAllConversations();
      conversations.removeWhere((c) => c.id == conversationId);

      final jsonList = conversations.map((c) => c.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      // Silently fail
    }
  }

  /// Create new conversation
  Future<Conversation> createConversation({
    required String assistantName,
    required String accentColorHex,
  }) async {
    final conversation = Conversation(
      assistantName: assistantName,
      accentColorHex: accentColorHex,
    );
    await saveConversation(conversation);
    return conversation;
  }

  /// Get conversations grouped by date
  Future<Map<String, List<Conversation>>> getConversationsGroupedByDate() async {
    try {
      final conversations = await getAllConversations();
      final grouped = <String, List<Conversation>>{};

      for (final conversation in conversations) {
        final dateLabel = conversation.getDateLabel();
        grouped.putIfAbsent(dateLabel, () => []);
        grouped[dateLabel]!.add(conversation);
      }

      return grouped;
    } catch (e) {
      return {};
    }
  }

  /// Clear all conversations (dangerous!)
  Future<void> clearAllConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      // Silently fail
    }
  }
}