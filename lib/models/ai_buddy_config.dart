// lib/models/ai_buddy_config.dart

import 'package:flutter/material.dart';

class AIBuddyConfig {
  final String assistantName;
  final String greetingMessage;
  final String systemPrompt;
  final Color accentColor;
  final String zoomLink;
  // FIX: each brand declares its own storage namespace
  final String storageKey;

  const AIBuddyConfig({
    required this.assistantName,
    required this.greetingMessage,
    required this.systemPrompt,
    required this.accentColor,
    required this.zoomLink,
    this.storageKey = 'lbp_conversations', // LBP is the default
  });
}