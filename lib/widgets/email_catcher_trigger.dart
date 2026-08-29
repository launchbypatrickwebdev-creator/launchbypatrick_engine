// lib/widgets/email_catcher_trigger.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tech_app_theme.dart';
import 'email_popup_catcher.dart';

class EmailCatcherTrigger extends StatelessWidget {
  final String pageType; // 'home' or 'sentinel'
  final bool isAutoTriggered; // true if this is the auto-popup

  const EmailCatcherTrigger({
    super.key,
    required this.pageType,
    this.isAutoTriggered = false,
  });

  void _openEmailPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EmailPopupCatcher(
        pageType: pageType,
        isAutoTriggered: isAutoTriggered,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSentinel = pageType == 'sentinel';
    final Color accentColor = isSentinel
        ? TechAppTheme.iotAccent
        : const Color(0xFF00E5FF);

    return OutlinedButton(
      onPressed: () => _openEmailPopup(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: BorderSide(color: accentColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Text(
        isSentinel ? 'SUBSCRIBE TO UPDATES' : 'GET UPDATES',
        style: GoogleFonts.robotoMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}