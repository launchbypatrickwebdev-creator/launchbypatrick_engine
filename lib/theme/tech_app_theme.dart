// lib/theme/tech_app_theme.dart

import 'package:flutter/material.dart';

class TechAppTheme {
  // Shared base layout tokens (The Achromatic / Neutral Group)
  static const Color darkBackground = Color(0xFF0B0F19); // 60% Space Base
  static const Color cardSurface = Color(0xFF131B2E);    // Container Fill
  static const Color lightText = Color(0xFFE2E8F0);       // 30% Typography
  static const Color dimText = Color(0xFF94A3B8);         // Secondary Labels

  // The 10% Dynamic Kinetic Accents
  static const Color architectureAccent = Color(0xFF6366F1); // Layer 1: Indigo Blue
  static const Color iotAccent = Color(0xFF10B981);          // Layer 2: Emerald Green

  /// Inspects the current route state and returns the target branding color
  static Color getActiveAccent(String? currentPath) {
    if (currentPath != null && currentPath.startsWith('/sentinel')) {
      return iotAccent; // Swaps to active physical hardware layer
    }
    return architectureAccent; // Default software architecture layer
  }
}