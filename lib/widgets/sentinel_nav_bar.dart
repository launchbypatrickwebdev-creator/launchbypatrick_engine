// lib/widgets/sentinel_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tech_app_theme.dart';

class SentinelNavBar extends StatelessWidget {
  const SentinelNavBar({super.key});

  void _openSentinelMobileMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Sentinel Menu',
      barrierColor: const Color(0xFF031B3B).withValues(alpha: 0.95),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SENTINEL OS MATRIX",
                        style: GoogleFonts.robotoMono(
                          color: TechAppTheme.iotAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    children: [
                      _mobileItem(context, "Overview", "/sentinel"),
                      _mobileItem(context, "Leakage Diagnostic", "/sentinel/growth-engine"),
                      _mobileItem(context, "R&D Labs", "/sentinel/rd"),
                      _mobileItem(context, "Connect & FAQs", "/sentinel/connect"),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 20),
                      _mobileItem(context, "← BACK TO LAUNCHBYPATRICK", "/"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim1, curve: Curves.fastOutSlowIn)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 1200;

    return Container(
      width: double.infinity,
      height: isMobile ? 80 : 100,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            button: true,
            label: "Sentinel Home",
            child: InkWell(
              onTap: () => context.go('/sentinel'),
              mouseCursor: SystemMouseCursors.click,
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, color: TechAppTheme.iotAccent, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "ECHOLEVEL SENTINEL",
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.w900,
                          fontSize: isMobile ? 14 : 16,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "INDUSTRIAL IOT & LOGISTICS",
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 8,
                          letterSpacing: 1.2,
                          color: TechAppTheme.iotAccent.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            _desktopItem(context, "GROWTH ENGINE", "/sentinel/growth-engine"),
            _desktopItem(context, "R&D LABS", "/sentinel/rd"),
            _desktopItem(context, "CONNECT", "/sentinel/connect"),
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                "RETURN TO COMMAND",
                style: GoogleFonts.robotoMono(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.menu_open_rounded, color: TechAppTheme.iotAccent, size: 32),
              onPressed: () => _openSentinelMobileMenu(context),
            ),
        ],
      ),
    );
  }

  Widget _desktopItem(BuildContext context, String title, String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () => context.go(path),
        style: TextButton.styleFrom(foregroundColor: Colors.white70),
        child: Text(
          title,
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.w500, fontSize: 10, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _mobileItem(BuildContext context, String title, String path) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pop();
        context.go(path);
      },
      title: Text(
        title.toUpperCase(),
        style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 13, letterSpacing: 1.5),
      ),
    );
  }
}