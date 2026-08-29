// main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // 1. URL Strategy
import 'dart:ui'; // 3. Scroll behavior (PointerDeviceKind)

// 2. Routing Configuration
import 'core/app_router.dart';
// Theme Alignment Token Layer
import 'theme/tech_app_theme.dart';

void main() {
  // 1. App Core Initialization
  usePathUrlStrategy(); // Strips the ugly '#' from browser URLs
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const LaunchEngineApp());
}

class LaunchEngineApp extends StatelessWidget {
  const LaunchEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Global Navigation & Routing Engine
    return MaterialApp.router(
      // 4. SEO Meta Title
      title: 'LaunchByPatrick | Hybrid Software Architect',
      debugShowCheckedModeBanner: false,

      // Hooks up your declarative routing configuration
      routerConfig: appRouter,

      // 3. Desktop & Mobile Hybrid UX Parameters
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: true,
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),

      // 4 & 5. Global Typography & Branding Palette Alignment
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // 🛠️ 60% Space Base Canvas Alignment
        scaffoldBackgroundColor: TechAppTheme.darkBackground,

        // Font Engine forced to Poppins globally with your 30% primary text hierarchy
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme.apply(
            bodyColor: TechAppTheme.lightText,
            displayColor: TechAppTheme.lightText,
          ),
        ),

        // Custom Slim Scrollbar mapped cleanly to your Software Architecture Layer
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(
            TechAppTheme.architectureAccent.withValues(alpha: 0.3),
          ),
          thickness: WidgetStateProperty.all(4.0),
          radius: Radius.zero,
        ),

        // 🛠️ CRITICAL FIX: Explicit ColorScheme mapping to eliminate default purple overrides
        colorScheme: const ColorScheme.dark(
          primary: TechAppTheme.architectureAccent, // Dynamic 10% base focus accent
          surface: TechAppTheme.darkBackground,     // 60% Space Base
          onPrimary: TechAppTheme.darkBackground,   // High contrast background for crisp text over buttons
          onSurface: TechAppTheme.lightText,        // Primary font clarity
        ),

        // Global Component Theme Cleanups to match your unselected/selected design requirements
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: TechAppTheme.dimText, // Links default cleanly to 30% neutral dim layout
          ),
        ),
      ),
    );
  }
}