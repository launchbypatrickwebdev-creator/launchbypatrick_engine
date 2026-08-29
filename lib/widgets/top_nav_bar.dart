// lib/widgets/top_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tech_app_theme.dart'; // 🛰️ Inherits our new dual-layer theme tokens
import 'site_logo.dart'; // Points natively to your LaunchByPatrickLogo file

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  // --- MOBILE PANEL TRIGGER ENGINE ---
  void _openMobileMenu(BuildContext context, String currentPath) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Menu',
      barrierColor: const Color(0xFF0A0B10).withValues(alpha: 0.95), // Deep space dim overlay
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent, // Let barrier color show through
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top control bar for the mobile panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentPath.startsWith('/sentinel') ? "ECHOLEVEL GATEWAY" : "NAVIGATION MATRIX",
                        style: GoogleFonts.robotoMono(
                          color: currentPath.startsWith('/sentinel') ? TechAppTheme.iotAccent : TechAppTheme.lightText,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).pop(), // Closes overlay matrix
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),

                // Mobile Navigation Links Matrix
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    children: [
                      //_mobileNavItem(context, "Sentinel", "/sentinel", currentPath),
                      //_mobileNavItem(context, "Products", "/products", currentPath), // ✅ ADDED FOR STOREFRONT NODE
                      _mobileNavItem(context, "Growth Engine", "/growth-engine", currentPath),
                      _mobileNavItem(context, "Contact", "/contact", currentPath),

                      const SizedBox(height: 40),

                      // Full-Width Mobile Action Trigger
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          child: Text(
                            currentPath.startsWith('/sentinel') ? "INITIALIZE TELEMETRY" : "INITIALIZE PROJECT",
                            style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      // Smooth slide-down animation protocol
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1), // Slides in from the exact top
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.fastOutSlowIn)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🛰️ Real-time URL Path Interceptor
    final String currentPath = GoRouterState.of(context).uri.toString();

    // 🛰️ Resolve matching architecture vs. IoT accent color on compile loop
    final Color activeAccent = TechAppTheme.getActiveAccent(currentPath);

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 1200; // Micro-Responsive Breakpoint

    return Container(
      width: double.infinity,
      height: isMobile ? 80 : 100,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // 🛠️ LEFT SIDE: Logo & Brand Node
          Semantics(
            button: true,
            label: "Back to Home",
            child: InkWell(
              onTap: () => context.go('/'),
              mouseCursor: SystemMouseCursors.click, // Native PC hover feedback
              child: Row(
                children: [
                  LaunchByPatrickLogo(height: isMobile ? 45 : 60),

                  // If browsing the EchoLevel Sentinel system, attach sub-operating terminal flag
                  if (currentPath.startsWith('/sentinel')) ...[
                    const SizedBox(width: 12),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.white24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "SENTINEL",
                      style: GoogleFonts.robotoMono(
                        color: activeAccent, // Emerald Green hardware indicator
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Spacer(),

          // 🛠️ RIGHT SIDE: Navigation Matrix Layout
          if (!isMobile) ...[
            //_desktopNavItem(context, "Sentinel", "/sentinel"),
            //_desktopNavItem(context, "Products", "/products"), // ✅ ADDED FOR STOREFRONT NODE
            _desktopNavItem(context, "Growth Engine", "/growth-engine"),
            _desktopNavItem(context, "Contact", "/contact"),
            
            const SizedBox(width: 30),
            _initializeButton(context, currentPath, activeAccent),
          ] else
          // Mobile Menu Open Protocol with context variables passed safely down
            Semantics(
              button: true,
              label: "Open Navigation Menu",
              child: IconButton(
                icon: const Icon(Icons.menu_open_rounded, color: TechAppTheme.dimText, size: 32),
                onPressed: () => _openMobileMenu(context, currentPath),
              ),
            ),
        ],
      ),
    );
  }

  // --- DESKTOP UI COMPONENT HELPERS ---
  Widget _initializeButton(BuildContext context, String currentPath, Color activeAccent) {
    return Semantics(
      button: true,
      label: "Initialize Project Signup",
      child: OutlinedButton(
        onPressed: () => context.go('/'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(
          currentPath.startsWith('/sentinel') ? "INITIALIZE TELEMETRY" : "INITIALIZE PROJECT",
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0),
        ),
      ),
    );
  }

  Widget _desktopNavItem(BuildContext context, String title, String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Semantics(
        button: true,
        label: "Navigate to $title",
        child: TextButton(
          onPressed: () => context.go(path),
          style: TextButton.styleFrom(
            foregroundColor: TechAppTheme.dimText,
          ),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  // --- MOBILE PANEL UI COMPONENT HELPERS ---
  Widget _mobileNavItem(BuildContext context, String title, String path, String currentPath) {
    final bool isSentinelActive = path == '/sentinel' && currentPath.startsWith('/sentinel');

    return Semantics(
      button: true,
      label: "Navigate to $title",
      child: ListTile(
        onTap: () {
          Navigator.of(context).pop(); // Always pop menu layer first
          context.go(path);
        },
        title: Text(
          title.toUpperCase(),
          style: GoogleFonts.robotoMono(
            color: isSentinelActive ? TechAppTheme.iotAccent : TechAppTheme.dimText,
            fontSize: 14,
            fontWeight: isSentinelActive ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isSentinelActive ? TechAppTheme.iotAccent : Colors.white30,
          size: 20,
        ),
      ),
    );
  }
}