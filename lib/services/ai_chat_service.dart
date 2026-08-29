// lib/services/ai_chat_service.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/conversation.dart';
import '../models/chat_message.dart';
import '../models/ai_buddy_config.dart';
import 'mistral_ai_service.dart';
import 'conversation_storage_service.dart';

/// Main service for handling AI chat conversations
class AIChatService {
  final AIBuddyConfig config;
  late MistralAIService _mistralService;
  late ConversationStorageService _storageService;

  late Conversation _currentConversation;
  final _messageController = StreamController<Conversation>.broadcast();
  final _typingController = StreamController<bool>.broadcast();

  AIChatService({required this.config}) {
    _mistralService = MistralAIService(config: config);
    _storageService = ConversationStorageService();
  }

  /// Stream of current conversation updates
  Stream<Conversation> get conversationStream => _messageController.stream;

  /// Stream for typing indicator
  Stream<bool> get typingStream => _typingController.stream;

  /// Get current conversation
  Conversation get currentConversation => _currentConversation;

  /// Initialize with existing or new conversation
  Future<void> initialize({String? conversationId}) async {
    if (conversationId != null) {
      // Load existing conversation
      final conversation = await _storageService.getConversation(conversationId);
      if (conversation != null) {
        _currentConversation = conversation;
      } else {
        _createNewConversation();
      }
    } else {
      _createNewConversation();
    }
    _messageController.add(_currentConversation);
  }

  /// Create new conversation
  void _createNewConversation() {
    _currentConversation = Conversation(
      assistantName: config.assistantName,
      accentColorHex: _colorToHex(Colors.indigoAccent), // Placeholder, will use actual
    );
  }

  /// Send text message
  Future<void> sendMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    // Add user message
    var userMessage = ChatMessage(
      content: userInput,
      sender: MessageSender.user,
    );

    _currentConversation.messages.add(userMessage);
    _messageController.add(_currentConversation);
    await _storageService.saveConversation(_currentConversation);

    // Show typing indicator
    _typingController.add(true);

    try {
      // Get AI response
      final aiResponse = await _mistralService.getAIResponse(
        userInput,
        conversationHistory: _getConversationHistory(),
      );

      // Mark user message as read
      userMessage = userMessage.copyWith(isRead: true);

      // Update the message in the conversation
      final userMessageIndex = _currentConversation.messages.indexOf(userMessage);
      if (userMessageIndex != -1) {
        _currentConversation.messages[userMessageIndex] = userMessage;
      }

      // Add AI message with read receipt
      final aiMessage = ChatMessage(
        content: aiResponse,
        sender: MessageSender.ai,
        isRead: true,
      );

      _currentConversation.messages.add(aiMessage);
      _currentConversation = _currentConversation.copyWith(
        messages: _currentConversation.getLast50Messages(),
        lastMessageAt: DateTime.now(),
      );

      _messageController.add(_currentConversation);
      await _storageService.saveConversation(_currentConversation);
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        content: 'Error: ${e.toString()}',
        sender: MessageSender.ai,
      );
      _currentConversation.messages.add(errorMessage);
      _messageController.add(_currentConversation);
    } finally {
      _typingController.add(false);
    }
  }

  /// Send voice message
  Future<void> sendVoiceMessage(String voiceText) async {
    if (voiceText.trim().isEmpty) return;

    var userMessage = ChatMessage(
      content: voiceText,
      sender: MessageSender.user,
      voiceInputIndicator: '🎤 Voice Input',
    );

    _currentConversation.messages.add(userMessage);
    _messageController.add(_currentConversation);
    await _storageService.saveConversation(_currentConversation);

    _typingController.add(true);

    try {
      final aiResponse = await _mistralService.getAIResponse(
        voiceText,
        conversationHistory: _getConversationHistory(),
      );

      // Mark user message as read
      userMessage = userMessage.copyWith(isRead: true);

      // Update the message in the conversation
      final userMessageIndex = _currentConversation.messages.indexOf(userMessage);
      if (userMessageIndex != -1) {
        _currentConversation.messages[userMessageIndex] = userMessage;
      }

      final aiMessage = ChatMessage(
        content: aiResponse,
        sender: MessageSender.ai,
        isRead: true,
      );

      _currentConversation.messages.add(aiMessage);
      _currentConversation = _currentConversation.copyWith(
        messages: _currentConversation.getLast50Messages(),
        lastMessageAt: DateTime.now(),
      );

      _messageController.add(_currentConversation);
      await _storageService.saveConversation(_currentConversation);
    } catch (e) {
      final errorMessage = ChatMessage(
        content: 'Error: ${e.toString()}',
        sender: MessageSender.ai,
      );
      _currentConversation.messages.add(errorMessage);
      _messageController.add(_currentConversation);
    } finally {
      _typingController.add(false);
    }
  }

  /// Edit message
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      final messageIndex = _currentConversation.messages
          .indexWhere((m) => m.id == messageId);

      if (messageIndex != -1) {
        final oldMessage = _currentConversation.messages[messageIndex];
        final editedMessage = oldMessage.copyWith(
          content: newContent,
          isEdited: true,
          editedAt: DateTime.now().toIso8601String(),
        );

        _currentConversation.messages[messageIndex] = editedMessage;
        _messageController.add(_currentConversation);
        await _storageService.saveConversation(_currentConversation);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      _currentConversation.messages.removeWhere((m) => m.id == messageId);
      _messageController.add(_currentConversation);
      await _storageService.saveConversation(_currentConversation);
    } catch (e) {
      // Silently fail
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final messageIndex = _currentConversation.messages
          .indexWhere((m) => m.id == messageId);

      if (messageIndex != -1) {
        final message = _currentConversation.messages[messageIndex];
        final readMessage = message.copyWith(isRead: true);
        _currentConversation.messages[messageIndex] = readMessage;

        _messageController.add(_currentConversation);
        await _storageService.saveConversation(_currentConversation);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Get all conversations (for sidebar/history)
  Future<List<Conversation>> getAllConversations() async {
    return _storageService.getAllConversations();
  }

  /// Get conversations grouped by date
  Future<Map<String, List<Conversation>>> getConversationsGroupedByDate() async {
    return _storageService.getConversationsGroupedByDate();
  }

  /// Switch to different conversation
  Future<void> switchConversation(String conversationId) async {
    final conversation = await _storageService.getConversation(conversationId);
    if (conversation != null) {
      _currentConversation = conversation;
      _messageController.add(_currentConversation);
    }
  }

  /// Start new conversation
  Future<void> startNewConversation() async {
    final conversation = await _storageService.createConversation(
      assistantName: config.assistantName,
      accentColorHex: _colorToHex(Colors.indigoAccent), // Will use actual accent
    );
    _currentConversation = conversation;
    _messageController.add(_currentConversation);
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    await _storageService.deleteConversation(conversationId);
    if (_currentConversation.id == conversationId) {
      await startNewConversation();
    }
  }

  /// Get conversation history for API context
  List<Map<String, String>> _getConversationHistory() {
    return _currentConversation.getLast50Messages().map((msg) {
      return {
        'role': msg.sender == MessageSender.user ? 'user' : 'assistant',
        'content': msg.content,
      };
    }).toList();
  }

  /// Helper: Convert color to hex string
  String _colorToHex(dynamic color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  void dispose() {
    _messageController.close();
    _typingController.close();
  }
}