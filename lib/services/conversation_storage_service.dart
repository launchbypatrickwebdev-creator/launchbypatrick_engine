// lib/services/conversation_storage_service.dart
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/conversation.dart';

/// Service to manage conversation persistence (all conversations history)
class ConversationStorageService {
  // FIX: each brand gets its own storage key
  // LBP uses 'lbp_conversations'
  // Sentinel uses 'sentinel_conversations'
  final String _storageKey;

  ConversationStorageService({String storageKey = 'lbp_conversations'})
      : _storageKey = storageKey;

  Future<List<Conversation>> getAllConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null) return [];
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    } catch (e) {
      return [];
    }
  }

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

  Future<void> saveConversation(Conversation conversation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversations = await getAllConversations();
      conversations.removeWhere((c) => c.id == conversation.id);
      conversations.insert(0, conversation);
      if (conversations.length > 20) {
        conversations.removeRange(20, conversations.length);
      }
      final jsonList = conversations.map((c) => c.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Storage error: $e');
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversations = await getAllConversations();
      conversations.removeWhere((c) => c.id == conversationId);
      final jsonList = conversations.map((c) => c.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Storage error: $e');
    }
  }

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

  Future<void> clearAllConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Storage error: $e');
    }
  }
}