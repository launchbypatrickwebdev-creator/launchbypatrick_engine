// lib/widgets/floating_ai_buddy.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/ai_theme_profiles.dart';
import '../models/ai_buddy_config.dart';
import 'chat_modal_sheet.dart';
import 'desktop_chat_panel.dart';

class FloatingAIBuddy extends StatefulWidget {
  const FloatingAIBuddy({super.key});

  @override
  State<FloatingAIBuddy> createState() => _FloatingAIBuddyState();
}

class _FloatingAIBuddyState extends State<FloatingAIBuddy>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openChatModal(AIBuddyConfig config) {
    _animationController.reset();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChatModalSheet(config: config),
    ).then((_) {
      _animationController.forward();
      setState(() => _isChatOpen = false);
    });
  }

  void _toggleDesktopChat(AIBuddyConfig config) {
    setState(() => _isChatOpen = !_isChatOpen);
    if (_isChatOpen) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentPath = GoRouterState.of(context).uri.toString();
    final AIBuddyConfig aiConfig = AIBuddyProfiles.getProfile(currentPath);
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Positioned(
        bottom: 120,
        right: 20,
        child: Semantics(
          button: true,
          enabled: true,
          label: "${aiConfig.assistantName} Chat Button",
          onTap: () => _openChatModal(aiConfig),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: GestureDetector(
                onTap: () => _openChatModal(aiConfig),
                child: _buildFloatingButton(aiConfig),
              ),
            ),
          ),
        ),
      );
    }

    // ── DESKTOP ──────────────────────────────────────────────────────────
    // 🛰️ FIXED: previously used Positioned(top:0, bottom:0) which forced
    // the panel to stretch the full viewport height regardless of the
    // panelHeight set inside DesktopChatPanel. Now anchored bottom-right
    // with an explicit height so there is visible page above and below.
    if (_isChatOpen) {
      return Positioned(
        right: 20,
        // Panel sits 20px from the bottom — same gap as the floating button
        bottom: 20,
        child: DesktopChatPanel(
          config: aiConfig,
          onClose: () => setState(() => _isChatOpen = false),
        ),
      );
    }

    // Floating button when panel is closed
    return Positioned(
      bottom: 120,
      right: 20,
      child: GestureDetector(
        onTap: () => _toggleDesktopChat(aiConfig),
        child: _buildFloatingButton(aiConfig),
      ),
    );
  }

  Widget _buildFloatingButton(AIBuddyConfig config) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: config.accentColor.withValues(alpha: 0.15),
        border: Border.all(
          color: config.accentColor,
          width: 2,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: config.accentColor.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.chat_rounded,
          color: config.accentColor,
          size: 28,
        ),
      ),
    );
  }
}