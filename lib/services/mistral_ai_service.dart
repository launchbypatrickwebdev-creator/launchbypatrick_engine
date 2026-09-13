// lib/services/mistral_ai_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ai_buddy_config.dart';

class MistralAIService {
  // Your Supabase project URL
  static const String _edgeFunctionUrl =
      'https://jjlmgoxcnvedwbqzrero.supabase.co/functions/v1/ai-chat';

  // Your Supabase Anon Key (public key - safe to use in frontend)
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpqbG1nb3hjbnZlZHdicXpyZXJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MjQ5NzEsImV4cCI6MjEwNDIwMDk3MX0.Oi0198XyetkfANmd37dAKsOenUBtrnEKCE6JjX9fogs'; // ← Put your real anon key here

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
          'Authorization': 'Bearer $_supabaseAnonKey',
          'apikey': _supabaseAnonKey,
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

      // Show real error
      return "AI Error (${response.statusCode}): ${data['error'] ?? body}";
    } catch (e) {
      return "Connection failed: $e";
    }
  }
}