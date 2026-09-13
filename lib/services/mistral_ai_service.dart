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
        },
        body: jsonEncode({
          'systemPrompt': config.systemPrompt,
          'messages': conversationHistory ?? [],
          'userMessage': userMessage,
        }),
      )
          .timeout(const Duration(seconds: 35));

      final body = response.body;
      print('EDGE FUNCTION STATUS: ${response.statusCode}');
      print('EDGE FUNCTION BODY: $body');

      final data = jsonDecode(body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return (data['reply'] as String).trim();
      }

      // Show the real error coming from the Edge Function
      return "AI Error (${response.statusCode}): ${data['error'] ?? body}";
    } catch (e) {
      return "Connection failed: $e";
    }
  }
}