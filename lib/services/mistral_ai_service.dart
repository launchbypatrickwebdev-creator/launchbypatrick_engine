// lib/services/mistral_ai_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ai_buddy_config.dart';

/// Service to communicate with Mistral AI API
class MistralAIService {
  static const String _apiKey = 'wS8TJDsEmoytJy8F6u70yF64eITVlhug'; // ← Put your real key here
  static const String _apiBaseUrl = 'https://api.mistral.ai/v1/chat/completions';

  final AIBuddyConfig config;

  MistralAIService({required this.config});

  /// Get AI response from Mistral AI
  Future<String> getAIResponse(
      String userMessage, {
        List<Map<String, String>>? conversationHistory,
      }) async {
    try {
      final List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': config.systemPrompt,
        },
        if (conversationHistory != null) ...conversationHistory,
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      final response = await http.post(
        Uri.parse(_apiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'mistral-small-latest',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 600,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('API request timeout'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = decoded['choices'] as List;
        final message = choices[0]['message']['content'] as String;
        return message.trim();
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your Mistral API credentials.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limited. Please try again later.');
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      return 'Network error: ${e.message}. Please check your connection and try again.';
    } catch (e) {
      return 'Sorry, I could not reach the AI service right now. Please try again in a moment.\n\nDetails: $e';
    }
  }

  /// Stream AI response (optional)
  Stream<String> streamAIResponse(
      String userMessage, {
        List<Map<String, String>>? conversationHistory,
      }) async* {
    try {
      final response = await getAIResponse(
        userMessage,
        conversationHistory: conversationHistory,
      );
      yield response;
    } catch (e) {
      yield 'Error: ${e.toString()}';
    }
  }
}