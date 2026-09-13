// lib/services/mistral_ai_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ai_buddy_config.dart';

class MistralAIService {
  // Change this to your actual Supabase project URL
  static const String _edgeFunctionUrl =
      'https://jjlmgoxcnvedwbqzrero.supabase.co/functions/v1/ai-chat';

  final AIBuddyConfig config;

  MistralAIService({required this.config});

  Future<String> getAIResponse(
      String userMessage, {
        List<Map<String, String>>? conversationHistory,
      }) async {
    try {
      final response = await http
          .post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          // Optional: if you have anon key protection
          // 'Authorization': 'Bearer YOUR_SUPABASE_ANON_KEY',
        },
        body: jsonEncode({
          'systemPrompt': config.systemPrompt,
          'messages': conversationHistory ?? [],
          'userMessage': userMessage,
        }),
      )
          .timeout(const Duration(seconds: 35));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return (data['reply'] as String).trim();
      }

      // Handle rate limit cleanly
      if (response.statusCode == 429) {
        return "I'm receiving too many requests right now. Please wait a few seconds and try again.";
      }

      return data['error']?.toString() ??
          "Sorry, I could not get a response from the AI service.";
    } catch (e) {
      return "Connection error. Please check your internet and try again.\n\nDetails: $e";
    }
  }
}