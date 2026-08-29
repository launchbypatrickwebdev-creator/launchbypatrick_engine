// lib/widgets/shared_site_footer.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tech_app_theme.dart';
import 'site_logo.dart';

class SharedSiteFooter extends StatelessWidget {
  const SharedSiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentPath = GoRouterState.of(context).uri.toString();
    final bool isSentinel = currentPath.startsWith('/sentinel');

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    final Color activeAccent = isSentinel ? TechAppTheme.iotAccent : const Color(0xFF00E5FF);
    final String brandTitle = isSentinel ? "ECHOLEVEL SENTINEL" : "LAUNCH BY PATRICK";
    final String subText = isSentinel
        ? "INDUSTRIAL TELEMETRY ENGINE"
        : "ARCHITECTING TRUST. ENGINEERING STABILITY\nGlobal Operations Hub";

    return Semantics(
      container: true,
      label: isSentinel ? "Sentinel System Telemetry Footer" : "LaunchByPatrick Software Node Footer",
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0B0E14), // 🧠 Updated background color to match the premium focus bar mask
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: isMobile ? 24 : (isSentinel ? 32 : 48),
        ),
        child: isMobile
            ? _buildMobileLayout(context, isSentinel, activeAccent, brandTitle, subText)
            : _buildDesktopLayout(context, isSentinel, activeAccent, brandTitle, subText),
      ),
    );
  }

  // --- 🛰️ DESKTOP ENVIRONMENT LAYOUT PANEL ---
  Widget _buildDesktopLayout(
      BuildContext context,
      bool isSentinel,
      Color activeAccent,
      String brandTitle,
      String subText,
      ) {
    // 🏛️ PROFILE A: LAUNCH BY PATRICK UNIFIED CONSOLE
    if (!isSentinel) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📊 TOP TIER: High-Density Engineering Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dataPoint("ENGINE OPTIMIZED", "SEO • AEO • GEO Ready", activeAccent, false),
              _dataPoint("GLOBAL-FIRST i18n", "Borderless Architecture", activeAccent, false),
              _dataPoint("<100ms TTFB LATENCY", "Edge-Cached Performance", activeAccent, false),
              _dataPoint("99.99% UPTIME", "Fault-Tolerant Systems", activeAccent, false),
              _dataPoint("DECOUPLED DESIGN", "Modular Core Engineering", activeAccent, false),
            ],
          ),
          const SizedBox(height: 36),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 24),

          // 🔑 BOTTOM TIER: 3-Column Split (Left, Center Coordinates, Right Legal)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, // Clean midline horizontal balancing
            children: [
              // Column 1: Left Alignment (Brand Identity & Status Token)
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          brandTitle,
                          style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                        ),
                        const SizedBox(width: 15),
                        Container(width: 5, height: 5, decoration: BoxDecoration(color: activeAccent, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(
                          "", // 🧠 Restored active console state token
                          style: GoogleFonts.robotoMono(color: activeAccent, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subText, style: GoogleFonts.robotoMono(color: TechAppTheme.dimText, fontSize: 9, letterSpacing: 1.0, height: 1.3)),
                  ],
                ),
              ),

              // Column 2: Dead Center Alignment (System Coordinates Panel)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SYSTEM COORDINATES",
                      style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Ibadan R&D Hub\nLagos Ops | Remote",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoMono(color: TechAppTheme.dimText, fontSize: 9, letterSpacing: 0.5, height: 1.4),
                    ),
                  ],
                ),
              ),

              // Column 3: Right Alignment (Legal Signature Panel)
              Expanded(
                flex: 4,
                child: Text(
                  "© 2026 LAUNCHBYPATRICK. SUSTAINABLE WEB & SOFTWARE ARCHITECTURE.",
                  textAlign: TextAlign.end,
                  style: GoogleFonts.robotoMono(color: Colors.white24, fontSize: 8.5, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // 📡 PROFILE B: ECHOLEVEL SENTINEL ORIGINAL COMPACT ROW
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  brandTitle,
                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                ),
                const SizedBox(width: 15),
                Container(width: 5, height: 5, decoration: BoxDecoration(color: activeAccent, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text("CORE_SYS_ACTIVE", style: GoogleFonts.robotoMono(color: activeAccent, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
              ],
            ),
            const SizedBox(height: 6),
            Text(subText, style: GoogleFonts.robotoMono(color: TechAppTheme.dimText, fontSize: 9, letterSpacing: 1.0)),
          ],
        ),
        Row(
          children: _getSentinelLinks(context),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "© 2026 ECHOLEVEL SENTINEL. INDUSTRIAL HARDWARE LAYER.",
              style: GoogleFonts.robotoMono(color: Colors.white24, fontSize: 8.5, letterSpacing: 1.0),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("POWERED BY", style: GoogleFonts.robotoMono(color: Colors.white10, fontSize: 7.5, letterSpacing: 1.0)),
                const SizedBox(width: 6),
                Opacity(opacity: 0.25, child: LaunchByPatrickLogo(height: 14)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- 🛰️ MOBILE ENVIRONMENT LAYOUT PANEL ---
  Widget _buildMobileLayout(
      BuildContext context,
      bool isSentinel,
      Color activeAccent,
      String brandTitle,
      String subText,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isSentinel) ...[
          // Mobile Metrics Stack
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _dataPoint("ENGINE OPTIMIZED", "SEO • AEO • GEO", activeAccent, true),
              _dataPoint("GLOBAL-FIRST i18n", "Borderless Core", activeAccent, true),
              _dataPoint("<100ms LATENCY", "Edge Cached", activeAccent, true),
              _dataPoint("99.99% UPTIME", "Fault-Tolerant", activeAccent, true),
              _dataPoint("DECOUPLED DESIGN", "Modular System", activeAccent, true),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
        ],
        Text(
          brandTitle,
          style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        Text(
          subText,
          style: GoogleFonts.robotoMono(color: TechAppTheme.dimText, fontSize: 8, letterSpacing: 1.0, height: 1.3),
        ),

        // 🧠 Integrated Mobile Coordinates Element
        if (!isSentinel) ...[
          const SizedBox(height: 12),
          Text(
            "COORDINATES: Ibadan R&D Hub // Lagos Ops // Remote",
            style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 8, letterSpacing: 0.5),
          ),
        ],

        if (isSentinel) ...[
          const Divider(color: Colors.white10, height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: _getSentinelLinks(context),
          ),
        ],
        const Divider(color: Colors.white10, height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isSentinel ? "© 2026 ECHOLEVEL SENTINEL." : "© 2026 LAUNCHBYPATRICK.",
                style: GoogleFonts.robotoMono(color: Colors.white24, fontSize: 7, letterSpacing: 0.5),
              ),
            ),
            if (isSentinel)
              Opacity(opacity: 0.25, child: LaunchByPatrickLogo(height: 10)),
          ],
        ),
      ],
    );
  }

  // --- 🛠️ SUB-COMPONENTS & UTILS ---
  Widget _dataPoint(String val, String label, Color highlightColor, bool isMobile) {
    return SizedBox(
      width: isMobile ? 140 : 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            val,
            style: GoogleFonts.robotoMono(
              color: highlightColor,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 11 : 12.5,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.robotoMono(
              color: Colors.white38,
              fontSize: 8.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getSentinelLinks(BuildContext context) {
    return [
      _buildFooterLink("HARDWARE SPECS", () => context.go('/sentinel/specs')),
      _buildSpacing(),
      _buildFooterLink("PROOF OF ACTIVITY", () => context.go('/sentinel/activity')),
      _buildSpacing(),
      _buildFooterLink("TELEMETRY LABS", () => context.go('/sentinel/labs')),
      _buildSpacing(),
      _buildFooterLink("RETURN TO COMMAND", () => context.go('/')),
    ];
  }

  Widget _buildSpacing() => const SizedBox(width: 16);

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: "Footer Navigation link to $text",
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            text,
            style: GoogleFonts.robotoMono(
              color: TechAppTheme.dimText,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}