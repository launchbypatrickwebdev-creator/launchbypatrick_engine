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

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

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
          color: Color(0xFF0B0E14),
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: isMobile ? 28 : 40,
        ),
        child: isMobile
            ? _buildMobileLayout(context, isSentinel, activeAccent, brandTitle, subText)
            : _buildDesktopLayout(context, isSentinel, activeAccent, brandTitle, subText),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DESKTOP LAYOUT
  // ─────────────────────────────────────────────
  Widget _buildDesktopLayout(
      BuildContext context,
      bool isSentinel,
      Color activeAccent,
      String brandTitle,
      String subText,
      ) {
    // ========== LAUNCH BY PATRICK ==========
    if (!isSentinel) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Metrics
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

          // Bottom 3-column
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          brandTitle,
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(color: activeAccent, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subText,
                      style: GoogleFonts.robotoMono(
                        color: TechAppTheme.dimText,
                        fontSize: 9,
                        letterSpacing: 1.0,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "SYSTEM COORDINATES",
                      style: GoogleFonts.robotoMono(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Ibadan R&D Hub\nLagos Ops | Remote",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoMono(
                        color: TechAppTheme.dimText,
                        fontSize: 9,
                        letterSpacing: 0.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  "© 2026 LAUNCHBYPATRICK. SUSTAINABLE WEB & SOFTWARE ARCHITECTURE.",
                  textAlign: TextAlign.end,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white24,
                    fontSize: 8.5,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // ========== ECHOLEVEL SENTINEL ==========
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Status Metrics
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dataPoint("LIVE TELEMETRY", "Real-time Asset Feed", activeAccent, false),
            _dataPoint("HARDWARE READY", "Pilot Deployment Active", activeAccent, false),
            _dataPoint("24/7 MONITORING", "Continuous Oversight", activeAccent, false),
            _dataPoint("ASSET TRACKING", "Infrastructure Asset ", activeAccent, false),
            _dataPoint("ZERO BLINDSPOTS", "Full Visibility Layer", activeAccent, false),
          ],
        ),
        const SizedBox(height: 32),
        const Divider(color: Colors.white10, height: 1),
        const SizedBox(height: 28),

        // Main Content Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Column
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        brandTitle,
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: activeAccent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "",
                        style: GoogleFonts.robotoMono(
                          color: activeAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subText,
                    style: GoogleFonts.robotoMono(
                      color: TechAppTheme.dimText,
                      fontSize: 9,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Links
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "QUICK LINKS",
                    style: GoogleFonts.robotoMono(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _footerLink(context, "Home", "/sentinel"),
                  _footerLink(context, "How It Works", "/sentinel/how-it-works"),
                  _footerLink(context, "Pilot Program", "/sentinel/connect"),
                  _footerLink(context, "About Us", "/sentinel/about"),
                  _footerLink(context, "Contact", "/sentinel/contact"),
                ],
              ),
            ),

            // Headquarters + Support
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "HEADQUARTERS",
                    style: GoogleFonts.robotoMono(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ibadan, Oyo State\nNigeria",
                    style: GoogleFonts.robotoMono(
                      color: TechAppTheme.dimText,
                      fontSize: 9,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "SUPPORT",
                    style: GoogleFonts.robotoMono(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "+234 704 994 5833", // ← Replace with real number
                    style: GoogleFonts.robotoMono(
                      color: TechAppTheme.dimText,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "echolevelsentinel@outlook.com",
                    style: GoogleFonts.robotoMono(
                      color: TechAppTheme.dimText,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        const Divider(color: Colors.white10, height: 1),
        const SizedBox(height: 18),

        // Legal + Credit
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "© 2026 ECHOLEVEL SENTINEL LTD  •  RC: 9572266  •  Privacy Policy  •  Terms of Service",
              style: GoogleFonts.robotoMono(
                color: Colors.white24,
                fontSize: 8,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: [
                Text(
                  "POWERED BY",
                  style: GoogleFonts.robotoMono(
                    color: Colors.white10,
                    fontSize: 7.5,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Opacity(
                  opacity: 0.3,
                  child: LaunchByPatrickLogo(height: 13),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MOBILE LAYOUT
  // ─────────────────────────────────────────────
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
        // Brand
        Row(
          children: [
            Text(
              brandTitle,
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            if (isSentinel) ...[
              const SizedBox(width: 10),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: activeAccent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                "",
                style: GoogleFonts.robotoMono(
                  color: activeAccent,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subText,
          style: GoogleFonts.robotoMono(
            color: TechAppTheme.dimText,
            fontSize: 8,
            letterSpacing: 0.8,
          ),
        ),

        if (isSentinel) ...[
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),

          // Quick Links
          Text(
            "QUICK LINKS",
            style: GoogleFonts.robotoMono(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _footerLink(context, "Home", "/sentinel"),
              _footerLink(context, "How It Works", "/sentinel/how-it-works"),
              _footerLink(context, "Pilot Program", "/sentinel/connect"),
              _footerLink(context, "About Us", "/sentinel/rd"),
              _footerLink(context, "Contact", "/sentinel/connect"),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),

          // HQ + Support
          Text(
            "HEADQUARTERS",
            style: GoogleFonts.robotoMono(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Ibadan, Oyo State, Nigeria",
            style: GoogleFonts.robotoMono(color: TechAppTheme.dimText, fontSize: 9),
          ),
          const SizedBox(height: 12),
          Text(
            "SUPPORT",
            style: GoogleFonts.robotoMono(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "+234 704 994 5833",
            style: GoogleFonts.robotoMono(color: TechAppTheme.dimText, fontSize: 9),
          ),
          Text(
            "echolevelsentinel@outlook.com",
            style: GoogleFonts.robotoMono(color: TechAppTheme.dimText, fontSize: 9),
          ),
        ],

        const SizedBox(height: 20),
        const Divider(color: Colors.white10),
        const SizedBox(height: 12),

        // Legal
        Text(
          isSentinel
              ? "© 2026 ECHOLEVEL SENTINEL LTD  •  RC: 9572266"
              : "© 2026 LAUNCHBYPATRICK.",
          style: GoogleFonts.robotoMono(
            color: Colors.white24,
            fontSize: 7.5,
          ),
        ),
        if (isSentinel) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "POWERED BY",
                style: GoogleFonts.robotoMono(color: Colors.white10, fontSize: 7),
              ),
              const SizedBox(width: 6),
              Opacity(opacity: 0.3, child: LaunchByPatrickLogo(height: 11)),
            ],
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  Widget _dataPoint(String val, String label, Color highlightColor, bool isMobile) {
    return SizedBox(
      width: isMobile ? 140 : 170,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            val,
            style: GoogleFonts.robotoMono(
              color: highlightColor,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 11 : 12,
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

  Widget _footerLink(BuildContext context, String text, String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => context.go(path),
        mouseCursor: SystemMouseCursors.click,
        child: Text(
          text,
          style: GoogleFonts.robotoMono(
            color: TechAppTheme.dimText,
            fontSize: 9.5,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}