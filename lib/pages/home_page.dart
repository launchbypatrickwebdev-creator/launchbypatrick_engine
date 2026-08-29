// lib/pages/home_page.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/ops_background_engine.dart';
import '../shared/launch_tactile_engine.dart';
import '../shared/launch_section_container.dart';
import '../widgets/email_popup_catcher.dart';
import '../widgets/live_telemetry_matrix.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/shared_site_footer.dart';
import '../widgets/floating_ai_buddy.dart';
import '../widgets/email_catcher_trigger.dart';
import '../services/email_popup_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEmailPopupOnFirstVisit();
    });
  }

  void _showEmailPopupOnFirstVisit() {
    final popupService = EmailPopupService();
    if (popupService.shouldShowPopup('home')) {
      popupService.markPopupShown('home');
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const EmailPopupCatcher(
          pageType: 'home',
          isAutoTriggered: true,
        ),
      );
    }
  }

  Future<void> _refreshProtocol(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;
    const Color accentCyan = Color(0xFF00E5FF);
    const Color terminalGreen = Color(0xFF39FF14);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      body: Stack(
        children: [
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/videos/industrial_core_loop.mp4',
            ),
          ),
          LaunchTactileEngine(
            onRefresh: () => _refreshProtocol(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopNavBar(),
                const SizedBox(height: 40),
                _buildHeroSection(isMobile, accentCyan),
                _buildFocusBar(isMobile, screenWidth),
                _buildSystemsGridSection(isMobile, accentCyan, terminalGreen),
                _buildExpertiseSection(context, isMobile),
                _buildServicesSection(isMobile, accentCyan),
                _buildMissionClosingSection(isMobile, accentCyan),
                const StickyFooterSpacer(),
                const SharedSiteFooter(),
              ],
            ),
          ),
          const FloatingAIBuddy(),
        ],
      ),
    );
  }

  // =========================================================================
  // 01. HERO — Semantics added to headline + subtext + CTA
  // =========================================================================
  Widget _buildHeroSection(bool isMobile, Color accent) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADLINE ────────────────────────────────────────────────────
          Semantics(
            header: true,
            label:
            'Launch by Patrick — If you can think it, we will build it and scale it.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IF YOU CAN THINK IT,',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 52,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    height: 1.1,
                  ),
                ),
                Text(
                  "WE'LL BUILD IT AND SCALE IT.",
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 50,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: 1.2,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── SUBTEXT ─────────────────────────────────────────────────────
          Semantics(
            label:
            'Launch by Patrick engineers sovereign, production-ready digital systems for founders who refuse to build ordinary things. Every system we ship moves Africa closer to the infrastructure it should have built and owned.',
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: const Text(
                "Launch by Patrick engineers sovereign, production ready digital systems for founders who refuse to build ordinary things. Every system we ship moves Africa closer to the infrastructure it should have built and owned.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.65,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // ── PRIMARY CTA ─────────────────────────────────────────────────
          Semantics(
            button: true,
            label: 'Engage production launch track — go to intake form',
            child: ElevatedButton(
              onPressed: () => context.go('/growth_intakeform'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: const Color(0xFF0A0B10),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 40,
                  vertical: isMobile ? 18 : 24,
                ),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: const Text(
                'ENGAGE PRODUCTION LAUNCH TRACK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          EmailCatcherTrigger(pageType: 'home'),
          const SizedBox(height: 56),

          if (MediaQuery.of(context).size.width >= 900)
            LiveTelemetryMatrix(accentColor: accent),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // =========================================================================
  // 02. FOCUS BAR — no Semantics needed, decorative strip
  // =========================================================================
  Widget _buildFocusBar(bool isMobile, double screenWidth) {
    if (isMobile) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E14),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1300),
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Focus",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                        height: 2,
                        width: 26,
                        color: const Color(0xFFFF3B3B)),
                  ],
                ),
                const SizedBox(width: 64),
                _focusItem("Ecosystem\nArchitecture",
                    Icons.account_tree_outlined),
                _focusItem(
                    "Platform\nOrchestration", Icons.layers_outlined),
                _focusItem("Embedded\nFintech",
                    Icons.account_balance_wallet_outlined),
                _focusItem(
                    "Distributed\nSystems", Icons.lan_outlined),
                _focusItem("AI &\nML", Icons.psychology_outlined),
                _focusItem(
                    "High-Scale\nEngineering", Icons.devices_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _focusItem(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 03. WHAT WE BUILD — Semantics on section header + each card title
  // =========================================================================
  Widget _buildSystemsGridSection(
      bool isMobile, Color cyan, Color green) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image:
          AssetImage('assets/backgrounds/system_matrix_bg.webp'),
          fit: BoxFit.cover,
          opacity: 0.06,
        ),
      ),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── section header ───────────────────────────────────────
            Semantics(
              header: true,
              label:
              'What we build — sovereign digital systems including super app ecosystems, marketplaces, creator economy platforms, and gamification systems.',
              child: const Text(
                "WHAT WE BUILD",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),

            GridView.count(
              crossAxisCount: isMobile ? 1 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isMobile ? 1.1 : 1.25,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: [
                _buildSystemGridNode(
                  title:
                  "1. Super App Ecosystems & Embedded Fintech",
                  semanticLabel:
                  'Super App Ecosystems and Embedded Fintech — inspired by WeChat, Alipay, KakaoTalk, Grab, Mercado Libre. Built with Flutter and Android Studio.',
                  inspiration:
                  "WeChat · Alipay · KakaoTalk · Grab · Mercado Libre",
                  techStack: "Flutter + Android Studio",
                  accentColor: cyan,
                  illustration: const _SuperAppPainter(),
                ),
                _buildSystemGridNode(
                  title:
                  "2. Hyper Local Marketplaces & Distributed Commerce",
                  semanticLabel:
                  'Hyper-Local Marketplaces and Distributed Commerce — inspired by Uber, Craigslist, Shopify, Walmart, Temu. Built with Python Ecosystem and GIS.',
                  inspiration:
                  "Uber · Craigslist · Shopify · Jet.com · Walmart · Temu",
                  techStack: "Python Ecosystem + GIS",
                  accentColor: cyan,
                  illustration: const _MarketplacePainter(),
                ),
                _buildSystemGridNode(
                  title:
                  "3. Content to Commerce & Creator Economies",
                  semanticLabel:
                  'Content to Commerce and Creator Economies — inspired by YouTube, TikTok, Audiomack, Patreon, Substack. Built with React and Tailwind CSS.',
                  inspiration:
                  "YouTube · TikTok · Audiomack · Patreon · Substack",
                  techStack: "React + Tailwind CSS",
                  accentColor: cyan,
                  illustration: const _CreatorEconomyPainter(),
                ),
                _buildSystemGridNode(
                  title:
                  "4. High Retention Gamification & Digital Vaults",
                  semanticLabel:
                  'High-Retention Gamification and Digital Vaults — inspired by Duolingo, Steam, Epic Games, Roblox, Microsoft. Built with Python Ecosystem and Core Engine.',
                  inspiration:
                  "Duolingo · Steam · Epic Games · Roblox · Microsoft",
                  techStack: "Python Ecosystem + Core Engine",
                  accentColor: cyan,
                  illustration: const _GamificationPainter(),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemGridNode({
    required String title,
    required String semanticLabel,
    required String inspiration,
    required String techStack,
    required Color accentColor,
    required Widget illustration,
  }) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0B10).withValues(alpha: 0.4),
          border:
          Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.3),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: illustration,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white10, height: 12),
                const SizedBox(height: 4),
                Text(
                  "INSPIRED BY: $inspiration",
                  style: TextStyle(
                      color: accentColor.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2),
                ),
                const SizedBox(height: 6),
                Text(
                  techStack,
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 04. HOW WE BUILD IT — Semantics on each block headline + body
  // =========================================================================
  Widget _buildExpertiseSection(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      padding: EdgeInsets.only(
        left: isMobile ? 0 : 80,
        right: isMobile ? 0 : 80,
        top: 40,
        bottom: 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isMobile ? 16 : 0),

          _buildExpertiseBlock(
            context: context,
            isMobile: isMobile,
            imageAsset: "assets/images/ecosystem_graph.webp",
            imageOnLeft: true,
            headline: "ECOSYSTEM ARCHITECTURE & SYSTEM DESIGN",
            body:
            "We don't add features to existing patterns. We design the pattern, the identity layer, and the monetization rails from the ground up. Every ecosystem we architect is built to own its market, not rent space in someone else's.",
            semanticLabel:
            'Ecosystem Architecture and System Design — we design the pattern, the identity layer, and the monetization rails from the ground up. Every ecosystem we architect is built to own its market.',
          ),

          SizedBox(height: isMobile ? 20 : 40),

          _buildExpertiseBlock(
            context: context,
            isMobile: isMobile,
            imageAsset: "assets/images/engineering_layers.webp",
            imageOnLeft: false,
            headline: "PRODUCTION-READY ENGINEERING PATTERNS",
            body:
            "Clean architecture isn't aesthetic preference. It's what keeps your system alive at 3am under load. We build the engineering layer once, correctly, so it never becomes the reason your product stops scaling.",
            semanticLabel:
            'Production-Ready Engineering Patterns — clean architecture keeps your system alive at 3am under load. We build the engineering layer once, correctly, so it never becomes the reason your product stops scaling.',
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseBlock({
    required BuildContext context,
    required bool isMobile,
    required String imageAsset,
    required bool imageOnLeft,
    required String headline,
    required String body,
    required String semanticLabel,
  }) {
    // ── text column with Semantics wrapper ────────────────────────────
    final Widget textWidget = Expanded(
      flex: 5,
      child: Semantics(
        label: semanticLabel,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 15,
                  height: 1.75,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final Widget imageWidget = Expanded(
      flex: 5,
      child: ExcludeSemantics(
        // ── illustrations are decorative; exclude from tree ──────────
        child: Center(
          child: Image.asset(
            imageAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              height: 300,
              color: Colors.white.withValues(alpha: 0.03),
              child: const Center(
                child: Icon(Icons.developer_board_rounded,
                    color: Color(0xFF00E5FF), size: 48),
              ),
            ),
          ),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withValues(alpha: 0.03),
                  child: const Center(
                    child: Icon(Icons.developer_board_rounded,
                        color: Color(0xFF00E5FF), size: 40),
                  ),
                ),
              ),
            ),
          ),
          Semantics(
            label: semanticLabel,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    body,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        height: 1.7,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 500),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: imageOnLeft
            ? [imageWidget, textWidget]
            : [textWidget, imageWidget],
      ),
    );
  }

  // =========================================================================
  // 05. SOLUTIONS — Semantics on header + each service row title
  // =========================================================================
  Widget _buildServicesSection(bool isMobile, Color accent) {
    return Container(
      color: const Color(0xFF000000),
      padding: EdgeInsets.only(
        left: isMobile ? 24 : 80,
        right: isMobile ? 24 : 80,
        top: 60,
        bottom: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            label:
            'What we actually build and what it does for your business — services include high-velocity architecture and MVP scoping, infrastructure audits and system remediation, and strategic architectural leadership.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "WHAT WE ACTUALLY BUILD",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5),
                ),
                Text(
                  "AND WHAT IT DOES FOR YOUR BUSINESS",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.white38,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          if (!isMobile) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "SYSTEM CAPABILITY",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontFamily: 'monospace',
                          fontSize: 12,
                          letterSpacing: 1.0),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 24, bottom: 16),
                    child: Text(
                      "DEPLOYMENT WORKFLOW",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontFamily: 'monospace',
                          fontSize: 12,
                          letterSpacing: 1.0),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 24, bottom: 16),
                    child: Text(
                      "EXPECTED OUTCOME",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontFamily: 'monospace',
                          fontSize: 12,
                          letterSpacing: 1.0),
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 1, color: Colors.white24),
          ],

          _buildServiceRow(
            title: "High Velocity Architecture & MVP Scoping",
            workflow:
            "Streamlining complex system requirements down to their highest leverage product cores, allowing founders to deploy optimized, production ready infrastructure to market in weeks.",
            value:
            "Accelerated time to market, maximized runway capital, and a clean baseline codebase engineered to scale without immediate refactoring.",
            isMobile: isMobile,
            accent: accent,
          ),
          _buildServiceRow(
            title: "Infrastructure Audits & System Remediation",
            workflow:
            "Deep dive telemetry and architectural reviews of high entropy, junior built, or AI generated codebases to isolate database bottlenecks, plug memory leaks, and optimize network throughput.",
            value:
            "Drastically reduced monthly cloud compute overhead and bulletproof system stability during high concurrency traffic spikes.",
            isMobile: isMobile,
            accent: accent,
          ),
          _buildServiceRow(
            title: "Strategic Architectural Leadership",
            workflow:
            "Providing technical sovereignty to founders and executive teams on multi tenant ecosystem scaling, stack selection, data isolation protocols, and decoupled modular migration paths.",
            value:
            "Mitigated technology risk and engineering execution tracks that align seamlessly with long term valuation goals and investment protocols.",
            isMobile: isMobile,
            accent: accent,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildServiceRow({
    required String title,
    required String workflow,
    required String value,
    required bool isMobile,
    required Color accent,
  }) {
    if (isMobile) {
      return Semantics(
        label: '$title. $workflow. Expected outcome: $value',
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0E12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(workflow,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w300)),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.white10),
              const SizedBox(height: 16),
              Text("EXPECTED OUTCOME",
                  style: TextStyle(
                      color: accent.withValues(alpha: 0.5),
                      fontFamily: 'monospace',
                      fontSize: 11,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: '$title. $workflow. Expected outcome: $value',
      child: Container(
        decoration: const BoxDecoration(
            border:
            Border(bottom: BorderSide(color: Colors.white10))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 44, bottom: 44, right: 24),
                  decoration: const BoxDecoration(
                      border: Border(
                          right:
                          BorderSide(color: Colors.white10))),
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 44, bottom: 44, left: 24, right: 24),
                  decoration: const BoxDecoration(
                      border: Border(
                          right:
                          BorderSide(color: Colors.white10))),
                  child: Text(workflow,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w300)),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 44, bottom: 44, left: 24),
                  child: Text(value,
                      style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w400)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 06. CLOSING MISSION — Semantics on both text blocks
  // =========================================================================
  Widget _buildMissionClosingSection(bool isMobile, Color cyan) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          Container(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  label:
                  'Mission: We exist for the founder who sees what does not exist yet and refuses to wait for someone else to build it.',
                  child: Text(
                    "We exist for the founder who sees what doesn't exist yet and refuses to wait for someone else to build it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 20 : 28,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Semantics(
                  label:
                  'Every system we ship is proof that world-class software engineering lives here, on this continent, and always did.',
                  child: Text(
                    "Every system we ship is proof that world class software engineering lives here, on this continent, and always did.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: isMobile ? 15 : 17,
                      height: 1.7,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 48 : 64),

          isMobile
              ? Column(
            children: [
              Semantics(
                button: true,
                label:
                'Tell us what you are building — go to intake form',
                child: _buildPrimaryCtaButton(
                  label: "TELL US WHAT YOU'RE BUILDING",
                  backgroundColor: cyan,
                  foregroundColor: const Color(0xFF0A0B10),
                  onPressed: () =>
                      context.go('/growth_intakeform'),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: 'Book a 30 minute call on Calendly',
                child: _buildSecondaryCtaButton(
                  label: "BOOK A 30-MIN CALL",
                  borderColor: cyan,
                  foregroundColor: cyan,
                  onPressed: () async {
                    final uri = Uri.parse(
                        'https://calendly.com/grok6457/30min');
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri,
                          mode:
                          LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                button: true,
                label:
                'Tell us what you are building — go to intake form',
                child: _buildPrimaryCtaButton(
                  label: "TELL US WHAT YOU'RE BUILDING",
                  backgroundColor: cyan,
                  foregroundColor: const Color(0xFF0A0B10),
                  onPressed: () =>
                      context.go('/growth_intakeform'),
                ),
              ),
              const SizedBox(width: 20),
              Semantics(
                button: true,
                label: 'Book a 30 minute call on Calendly',
                child: _buildSecondaryCtaButton(
                  label: "BOOK A 30-MIN CALL",
                  borderColor: cyan,
                  foregroundColor: cyan,
                  onPressed: () async {
                    final uri = Uri.parse(
                        'https://calendly.com/grok6457/30min');
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri,
                          mode:
                          LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // =========================================================================
  // SHARED BUTTON BUILDERS — unchanged
  // =========================================================================
  Widget _buildPrimaryCtaButton({
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding:
        const EdgeInsets.symmetric(horizontal: 36, vertical: 26),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
            fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildSecondaryCtaButton({
    required String label,
    required Color borderColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: borderColor, width: 1.5),
        padding:
        const EdgeInsets.symmetric(horizontal: 36, vertical: 26),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
            fontFamily: 'monospace'),
      ),
    );
  }
}

// =============================================================================
// CARD ILLUSTRATIONS — ExcludeSemantics on all painters (decorative)
// =============================================================================

class _SuperAppPainter extends StatelessWidget {
  const _SuperAppPainter();
  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(painter: _SuperAppCanvasPainter()),
    );
  }
}

class _SuperAppCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.42;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 1; i <= 3; i++) {
      ringPaint.color =
          const Color(0xFF00E5FF).withValues(alpha: 0.12 * (4 - i));
      canvas.drawCircle(center, maxR * i / 3, ringPaint);
    }
    canvas.drawCircle(
        center, 6, Paint()..color = const Color(0xFF00E5FF));
    const nodeAngles = [0.0, 60.0, 120.0, 180.0, 240.0, 300.0];
    for (final deg in nodeAngles) {
      final rad = deg * math.pi / 180;
      final nodePos = Offset(center.dx + maxR * math.cos(rad),
          center.dy + maxR * math.sin(rad));
      canvas.drawLine(
          center,
          nodePos,
          Paint()
            ..color =
            const Color(0xFF00E5FF).withValues(alpha: 0.2)
            ..strokeWidth = 0.8);
      canvas.drawCircle(nodePos, 4,
          Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.8));
    }
    const midAngles = [30.0, 90.0, 150.0, 210.0, 270.0, 330.0];
    for (final deg in midAngles) {
      final rad = deg * math.pi / 180;
      final nodePos = Offset(
          center.dx + (maxR * 2 / 3) * math.cos(rad),
          center.dy + (maxR * 2 / 3) * math.sin(rad));
      canvas.drawCircle(nodePos, 2.5,
          Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MarketplacePainter extends StatelessWidget {
  const _MarketplacePainter();
  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(painter: _MarketplaceCanvasPainter()),
    );
  }
}

class _MarketplaceCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.15)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final nodePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.7);
    const cols = 7;
    const rows = 5;
    final colStep = size.width / (cols + 1);
    final rowStep = size.height / (rows + 1);
    final List<Offset> points = [];
    for (int r = 1; r <= rows; r++) {
      for (int c = 1; c <= cols; c++) {
        final offset = (r % 2 == 0) ? colStep * 0.5 : 0.0;
        points.add(Offset(c * colStep + offset, r * rowStep));
      }
    }
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final dist = (points[i] - points[j]).distance;
        if (dist < colStep * 1.4) {
          canvas.drawLine(points[i], points[j], linePaint);
        }
      }
    }
    final hotIndices = {4, 11, 18};
    for (int i = 0; i < points.length; i++) {
      if (hotIndices.contains(i)) {
        canvas.drawCircle(
            points[i], 5, Paint()..color = const Color(0xFF00E5FF));
        canvas.drawCircle(
            points[i],
            9,
            Paint()
              ..color =
              const Color(0xFF00E5FF).withValues(alpha: 0.15)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      } else {
        canvas.drawCircle(points[i], 2.5, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CreatorEconomyPainter extends StatelessWidget {
  const _CreatorEconomyPainter();
  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(painter: _CreatorEconomyCanvasPainter()),
    );
  }
}

class _CreatorEconomyCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (int wave = 0; wave < 3; wave++) {
      final path = Path();
      final amplitude = h * 0.10;
      final baseY = h * (0.28 + wave * 0.18);
      final phaseShift = wave * math.pi / 3;
      final opacity = 0.5 - wave * 0.12;
      path.moveTo(0, baseY);
      for (double x = 0; x <= w; x += 2) {
        final y = baseY +
            amplitude *
                math.sin((x / w) * math.pi * 3 + phaseShift);
        path.lineTo(x, y);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color =
            const Color(0xFF00E5FF).withValues(alpha: opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
    final barY = h * 0.78;
    canvas.drawLine(
        Offset(w * 0.1, barY),
        Offset(w * 0.9, barY),
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)
          ..strokeWidth = 2);
    final dropPoints = [w * 0.2, w * 0.45, w * 0.70];
    for (final x in dropPoints) {
      canvas.drawLine(
          Offset(x, h * 0.55),
          Offset(x, barY),
          Paint()
            ..color =
            const Color(0xFF00E5FF).withValues(alpha: 0.25)
            ..strokeWidth = 0.8);
      canvas.drawCircle(
          Offset(x, barY), 4, Paint()..color = const Color(0xFF00E5FF));
    }
    for (final x in dropPoints) {
      canvas.drawCircle(
          Offset(x, h * 0.15),
          5,
          Paint()
            ..color =
            const Color(0xFF00E5FF).withValues(alpha: 0.6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GamificationPainter extends StatelessWidget {
  const _GamificationPainter();
  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(painter: _GamificationCanvasPainter()),
    );
  }
}

class _GamificationCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.4;
    final path = Path();
    bool first = true;
    for (double angle = 0;
    angle <= math.pi * 6;
    angle += 0.05) {
      final r = maxR * (1 - angle / (math.pi * 7));
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    final milestoneAngles = [
      0.0,
      math.pi,
      math.pi * 2,
      math.pi * 3
    ];
    for (final angle in milestoneAngles) {
      final r = maxR * (1 - angle / (math.pi * 7));
      final pos = Offset(center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle));
      canvas.drawCircle(
          pos,
          4,
          Paint()
            ..color =
            const Color(0xFF00E5FF).withValues(alpha: 0.85));
    }
    canvas.drawCircle(
        center, 6, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(
        center,
        12,
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}