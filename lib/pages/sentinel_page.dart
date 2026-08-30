// lib/pages/sentinel_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/ops_background_engine.dart';
import '../shared/launch_tactile_engine.dart';
import '../shared/launch_section_container.dart';
import '../widgets/email_popup_catcher.dart';
import '../widgets/sentinel_nav_bar.dart';
import '../widgets/shared_site_footer.dart';
import '../widgets/floating_ai_buddy.dart';
import '../widgets/email_catcher_trigger.dart';
import '../services/email_popup_service.dart';

class SentinelPage extends StatefulWidget {
  const SentinelPage({super.key});

  @override
  State<SentinelPage> createState() => _SentinelPageState();
}

class _SentinelPageState extends State<SentinelPage> {
  // =========================================================================
  // SENTINEL BRAND TOKENS
  // Dark green + charcoal industrial palette
  // =========================================================================
  static const Color _green     = Color(0xFF00C853); // primary accent
  static const Color _greenDim  = Color(0xFF1B4332); // border/card accent
  static const Color _cardBg    = Color(0xFF0A1A0F); // deep forest dark card
  static const Color _pageBg    = Color(0xFF07080C); // page background

  // ── route to intake form — update when your form route is confirmed ──────
  static const String _pilotRoute = '/connection_form';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEmailPopupOnFirstVisit();
    });
  }

  void _showEmailPopupOnFirstVisit() {
    final popupService = EmailPopupService();
    if (popupService.shouldShowPopup('sentinel')) {
      popupService.markPopupShown('sentinel');
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => const EmailPopupCatcher(
          pageType: 'sentinel',
          isAutoTriggered: true,
        ),
      );
    }
  }

  Future<void> _sentinelRefresh(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (context.mounted) context.go('/sentinel');
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/videos/sentinel_matrix_loop.mp4',
            ),
          ),
          LaunchTactileEngine(
            onRefresh: () => _sentinelRefresh(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SentinelNavBar(),
                _buildHero(isMobile),
                _buildQuietProblem(isMobile),
                _buildCapabilities(isMobile),
                _buildWhoWeServe(isMobile),
                _buildFeelSection(isMobile),
                _buildHowItWorks(isMobile),
                _buildPilotProgram(isMobile),
                _buildNigerianOps(isMobile),
                const SizedBox(height: 120),
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
  // SHARED BUTTON BUILDERS
  // =========================================================================

  // Primary filled — routes to intake form (Free Pilot)
  Widget _buildPilotButton(bool isMobile) {
    return Semantics(
      button: true,
      label: 'Request a free pilot — go to intake form',
      child: ElevatedButton(
        onPressed: () => context.go(_pilotRoute),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 36,
            vertical: isMobile ? 16 : 20,
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        child: Text(
          'REQUEST FREE PILOT',
          style: GoogleFonts.robotoMono(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // Secondary outlined — newsletter (Get Updates via EmailCatcherTrigger)
  // EmailCatcherTrigger already renders its own styled button.
  // We wrap it in a Semantics label to distinguish it from the pilot button.
  Widget _buildUpdatesButton() {
    return Semantics(
      button: true,
      label: 'Subscribe to updates — join newsletter',
      child: EmailCatcherTrigger(pageType: 'sentinel'),
    );
  }

  // =========================================================================
  // 01. HERO
  // =========================================================================
  Widget _buildHero(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // ── project tag ──────────────────────────────────────────────
          Semantics(
            label: 'EchoLevel Sentinel — Project sub-system, secure operations.',
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: _green.withValues(alpha: 0.15),
              child: Text(
                "",
                style: GoogleFonts.robotoMono(
                  color: _green,
                  fontSize: isMobile ? 8 : 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── headline ─────────────────────────────────────────────────
          Semantics(
            header: true,
            label: 'Stop losing fuel. Start seeing clearly.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOP LOSING FUEL.',
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 54,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    height: 1.1,
                  ),
                ),
                Text(
                  'START SEEING CLEARLY.',
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 54,
                    fontWeight: FontWeight.bold,
                    color: _green,
                    letterSpacing: 1.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // ── sub-headline ─────────────────────────────────────────────
          Semantics(
            label:
            'EchoLevel Sentinel provides real-time fuel integrity, theft detection, and operational visibility for standby generators and logistics fleets across Nigeria.',
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                'Provides real time fuel integrity, theft detection, and infrastructural trust platform',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: isMobile ? 13 : 16,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // ── dual CTA row ─────────────────────────────────────────────
          // Free Pilot → intake form   |   Get Updates → newsletter
          isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPilotButton(isMobile),
              const SizedBox(height: 16),
              _buildUpdatesButton(),
            ],
          )
              : Row(
            children: [
              _buildPilotButton(isMobile),
              const SizedBox(width: 20),
              _buildUpdatesButton(),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            "Zero Risk  •  2–4 Week Free Pilot Available",
            style: GoogleFonts.robotoMono(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // =========================================================================
// 02. THE QUIET PROBLEM
// =========================================================================
  Widget _buildQuietProblem(bool isMobile) {
    return Container(
      // Full-width solid dark background — completely covers the background video
      width: double.infinity,
      color: const Color(0xFF07080C), // Solid dark background (or Colors.black)
      child: LaunchSectionContainer(
        child: Container(
          padding: EdgeInsets.all(isMobile ? 28 : 48),
          decoration: BoxDecoration(
            color: _cardBg, // Solid card background (removed alpha transparency)
            border: Border.all(color: _green.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                label: 'Operational diagnostic — the quiet problem.',
                child: Text(
                  "",
                  style: GoogleFonts.robotoMono(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Manual Dipping Sticks & Guesswork Won't Stop the Loss.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                label:
                'Most organizations already try to manage fuel. They use manual dipping, driver reports, logbooks, and guesswork. Yet fuel still disappears, generators run dry unexpectedly, and fleet costs keep rising. The real issue is not a lack of effort — it is a lack of continuous, tamper-proof visibility.',
                child: Text(
                  "Most organizations already try to manage fuel. They use manual dipping, driver reports, logbooks, and guesswork. Yet fuel still disappears, generators run dry unexpectedly, and fleet costs keep rising.\n\nThe real issue isn't a lack of effort — it's a lack of continuous, tamper-proof visibility.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: isMobile ? 13 : 15,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 03. WHAT WE DO FOR YOU
  // =========================================================================
  Widget _buildCapabilities(bool isMobile) {
    const List<Map<String, String>> caps = [
      {
        'n': '01',
        'title': 'Real Time Fuel Tracking',
        'body':
        'Know your exact fuel level down to the liter at any given moment across all deployed assets.',
      },
      {
        'n': '02',
        'title': 'Instant Discrepancy Alerts',
        'body':
        'Get notified immediately if fuel drops unnaturally while an engine is off or actively running.',
      },
      {
        'n': '03',
        'title': 'Tamper Proof & Non Invasive',
        'body':
        'Mounted securely without voiding OEM equipment warranties or altering existing tank structures.',
      },
      {
        'n': '04',
        'title': 'Offline Integrity',
        'body':
        'Internally logs every drop and run hour even when regional cellular networks fail.',
      },
      {
        'n': '05',
        'title': 'Temperature Compensated Data',
        'body':
        'Accurate volumetric readings that account for heat expansion and severe weather changes.',
      },
    ];

    final Widget capList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          label:
          'System capabilities — what EchoLevel Sentinel does for you.',
          child: Text(
            "",
            style: GoogleFonts.robotoMono(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "What We Do For You",
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 26 : 38,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        ...caps.map(
                (c) => _buildCapTile(c['n']!, c['title']!, c['body']!, isMobile)),
      ],
    );

    final Widget dashboardSlot = Container(
      constraints: BoxConstraints(minHeight: isMobile ? 260 : 520),
      decoration: BoxDecoration(
        color: _cardBg.withValues(alpha: 0.4),
        border: Border.all(color: _greenDim),
      ),
      child: Image.asset(
        'assets/images/sentinel_dashboard.webp',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monitor_rounded,
                  color: _green.withValues(alpha: 0.3), size: 48),
              const SizedBox(height: 16),
              Text(
                "SENTINEL DASHBOARD\nPREVIEW",
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  color: _green.withValues(alpha: 0.4),
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return LaunchSectionContainer(
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          capList,
          const SizedBox(height: 48),
          dashboardSlot,
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: capList),
          const SizedBox(width: 56),
          Expanded(flex: 5, child: dashboardSlot),
        ],
      ),
    );
  }

  Widget _buildCapTile(
      String number, String title, String body, bool isMobile) {
    return Semantics(
      label: 'Capability $number: $title. $body',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: _cardBg.withValues(alpha: 0.25),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: GoogleFonts.robotoMono(
                color: _green,
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 15 : 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(body,
                      style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: isMobile ? 12 : 14,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 04. WHO WE SERVE
  // =========================================================================
  Widget _buildWhoWeServe(bool isMobile) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              label: 'Deployment sectors — who EchoLevel Sentinel serves.',
              child: Text(
                "",
                style: GoogleFonts.robotoMono(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Who We Serve",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 26 : 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            isMobile
                ? Column(
              children: [
                _buildSectorCard(
                  "STANDBY POWER INFRASTRUCTURE",
                  [
                    "Banks", "Hospitals", "Telecom Sites",
                    "Hotels", "Data Centers",
                    "Educational Institutions", "Manufacturing Plants"
                  ],
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildSectorCard(
                  "LOGISTICS & TRANSPORT FLEETS",
                  [
                    "Inter-state Buses", "Haulage Trucks",
                    "Delivery Fleets", "Commercial Vans"
                  ],
                  isMobile,
                ),
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSectorCard(
                    "STANDBY POWER INFRASTRUCTURE",
                    [
                      "Banks", "Hospitals", "Telecom Sites",
                      "Hotels", "Data Centers",
                      "Educational Institutions",
                      "Manufacturing Plants"
                    ],
                    isMobile,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildSectorCard(
                    "LOGISTICS & TRANSPORT FLEETS",
                    [
                      "Inter-state Buses", "Haulage Trucks",
                      "Delivery Fleets", "Commercial Vans"
                    ],
                    isMobile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorCard(
      String title, List<String> items, bool isMobile) {
    return Semantics(
      label: '$title: ${items.join(", ")}',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        decoration: BoxDecoration(
          color: _cardBg.withValues(alpha: 0.3),
          border: Border.all(color: _green.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((item) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:
                  _green.withValues(alpha: 0.06),
                  border: Border.all(
                      color: _green.withValues(alpha: 0.2)),
                ),
                child: Text(item,
                    style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12)),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 05. HOW IT FEELS TO USE
  // =========================================================================
  Widget _buildFeelSection(bool isMobile) {
    const List<String> painPoints = [
      "Rely on verbal reports or handwritten fuel receipts",
      "Wait for a generator to die unexpectedly in the middle of operations",
      "Argue with suppliers or drivers about missing fuel liters",
      "Guess next month's energy and logistics budget",
    ];

    return LaunchSectionContainer(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 28 : 48),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              label:
              'Operational shift — before and after EchoLevel Sentinel.',
              child: Text(
                "",
                style: GoogleFonts.robotoMono(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "What Changes When You Deploy Sentinel",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 22 : 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "You no longer have to:",
              style: GoogleFonts.robotoMono(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...painPoints.map((p) => _buildPainBullet(p)),
            const SizedBox(height: 32),
            Semantics(
              label:
              'Instead, you simply open a clear, unassailable record of what actually happened.',
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.07),
                  border: Border(
                      left: BorderSide(color: _green, width: 3)),
                ),
                child: Text(
                  "Instead, you simply open a clear, unassailable record of what actually happened.",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Semantics(
        label: 'Pain point: $text',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("✕ ",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold)),
            Expanded(
              child: Text(text,
                  style:
                  GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 06. HOW IT WORKS
  // =========================================================================
  Widget _buildHowItWorks(bool isMobile) {
    const List<Map<String, String>> steps = [
      {
        'n': '01',
        'title': 'MOUNT',
        'body':
        'A compact telemetry unit mounts non invasively on your generator or vehicle. No tank alteration, no warranty voiding.',
      },
      {
        'n': '02',
        'title': 'MONITOR',
        'body':
        'The unit quietly processes and secures fuel level, engine runtime, and diagnostic data locally with or without network connectivity.',
      },
      {
        'n': '03',
        'title': 'CONTROL',
        'body':
        'Receive instant theft alerts, weekly consumption trends, and verifiable asset health scores directly on your Sentinel dashboard.',
      },
    ];

    return Container(
      color: Colors.black.withValues(alpha: 0.2),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              label:
              'Deployment lifecycle — how EchoLevel Sentinel works in 3 steps.',
              child: Text(
                "",
                style: GoogleFonts.robotoMono(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "How It Works",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 26 : 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            isMobile
                ? Column(
              children: steps
                  .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildStepBox(
                    s['n']!, s['title']!, s['body']!, isMobile),
              ))
                  .toList(),
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps
                  .map((s) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: s['n'] != '03' ? 20 : 0),
                  child: _buildStepBox(s['n']!, s['title']!,
                      s['body']!, isMobile),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBox(
      String step, String title, String body, bool isMobile) {
    return Semantics(
      label: 'Step $step: $title. $body',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        decoration: BoxDecoration(
          color: _cardBg.withValues(alpha: 0.3),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(step,
                style: GoogleFonts.robotoMono(
                    color: _green,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(title,
                style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Text(body,
                style: GoogleFonts.poppins(
                    color: Colors.white60, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 07. FREE PILOT PROGRAM
  // =========================================================================
  Widget _buildPilotProgram(bool isMobile) {
    return LaunchSectionContainer(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 28 : 52),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.05),
          border: Border.all(color: _green, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── enterprise badge ──────────────────────────────────────
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: _green,
              child: Text(
                "ENTERPRISE PROOF OF CONCEPT",
                style: GoogleFonts.robotoMono(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Semantics(
              header: true,
              label: 'Free 2 to 4 week pilot program for EchoLevel Sentinel.',
              child: Text(
                "Free 2–4 Week Pilot Program",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Semantics(
              label:
              'See the proof on your own assets before spending a Naira. We install our telemetry unit on one generator or one commercial vehicle for 2 to 4 weeks at zero cost. You get full access to live reports and theft alerts to evaluate the system in real operating conditions.',
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  "See the proof on your own assets before spending a Naira.\n\nWe install our telemetry unit on one generator or one commercial vehicle for 2 to 4 weeks at zero cost. You get full access to live reports and theft alerts to evaluate the system in real operating conditions.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: isMobile ? 13 : 15,
                    height: 1.7,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── pilot CTA — routes to intake form ─────────────────────
            _buildPilotButton(isMobile),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 08. BUILT FOR NIGERIAN OPERATIONS
  // =========================================================================
  Widget _buildNigerianOps(bool isMobile) {
    const List<Map<String, String>> trustSignals = [
      {
        'title': 'Power Resilience',
        'body':
        'Engineered to survive NEPA outages, voltage spikes, and generator switchover\'s without data loss.',
      },
      {
        'title': 'Network Independence',
        'body':
        'Data transmits operates on device in full offline mode. Nothing is ever lost.',
      },
      {
        'title': 'Environmental Hardening',
        'body':
        'Built to operate across Nigeria\'s climate, from harmattan dust to delta humidity and extreme heat.',
      },
      {
        'title': 'Verifiable Asset History',
        'body':
        'Every verified fuel record becomes a data point that builds a tamper proof asset history. The foundation for future credit and insurance scoring.',
      },
    ];

    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: LaunchSectionContainer(
        child: Container(
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          decoration: BoxDecoration(
            color: _cardBg.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                label: 'Local resilience — built for Nigerian operations.',
                child: Text(
                  "",
                  style: GoogleFonts.robotoMono(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Built for Africa Operations",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                label:
                'EchoLevel Sentinel Limited is a Nigerian operational technology company. We engineer hardware and software specifically to endure local power fluctuations, network downtime, and harsh environmental conditions — helping organizations build long-term asset integrity and operational trust.',
                child: Text(
                  "Engineering sovereign hardware and software specifically to endure local power fluctuations, network downtime, and harsh environmental conditions for Africa.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: isMobile ? 13 : 15,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // ── 4 trust signal tiles ──────────────────────────────
              isMobile
                  ? Column(
                children: trustSignals
                    .map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTrustTile(
                      t['title']!, t['body']!, isMobile),
                ))
                    .toList(),
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: trustSignals
                    .map((t) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right:
                        t != trustSignals.last ? 16 : 0),
                    child: _buildTrustTile(
                        t['title']!, t['body']!, isMobile),
                  ),
                ))
                    .toList(),
              ),

              const SizedBox(height: 48),

              // ── mid-level vision pull quote ────────────────────────
              Semantics(
                label:
                'Vision: Every fuel record verified by Sentinel becomes part of a growing asset trust layer — enabling Nigerian businesses to build verifiable operational histories that unlock access to credit, insurance, and institutional partnerships.',
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.05),
                    border: Border(
                        left: BorderSide(color: _green, width: 2)),
                  ),
                  child: Text(
                    "Every fuel record verified by Sentinel becomes part of a growing future asset trust layer that will enable Nigerian businesses to build verifiable operational histories that unlock access to credit, insurance, and institutional partnerships.",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: isMobile ? 13 : 15,
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustTile(String title, String body, bool isMobile) {
    return Semantics(
      label: '$title: $body',
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(body,
                style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: 12, height: 1.5)),
          ],
        ),
      ),
    );
  }
}