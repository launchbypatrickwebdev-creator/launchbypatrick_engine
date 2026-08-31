// lib/pages/sentinel/rd_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/ops_background_engine.dart';
import '../../shared/launch_tactile_engine.dart';
import '../../shared/launch_section_container.dart';
import '../../widgets/sentinel_nav_bar.dart';
import '../../widgets/shared_site_footer.dart';
import '../../widgets/connection_form.dart';

class RDPage extends StatefulWidget {
  const RDPage({super.key});

  @override
  State<RDPage> createState() => _RDPageState();
}

class _RDPageState extends State<RDPage> {

  static const Color _amber  = Color(0xFFFFEA00);
  static const Color _green  = Color(0xFF00C853);
  static const Color _cardBg = Color(0xFF0A1A0F);
  static const Color _pageBg = Color(0xFF07080C);

  // Page-level focus node — passed to LaunchTactileEngine and ConnectionForm
  final FocusNode _pageFocusNode = FocusNode();

  // Clearance state
  int  _clearanceLevel  = 0;
  bool _clearanceLoaded = false;

  // Gateway expansion
  bool _showConnectionForm = false;

  // Research nodes
  static const List<Map<String, String>> _researchNodes = [
    {
      'title': 'Temperature Compensation Algorithm v1.0',
      'date': 'Q2 2026',
      'status': 'UNDER REVIEW',
      'summary': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadClearanceLevel();
  }

  Future<void> _loadClearanceLevel() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _clearanceLevel  = prefs.getInt('sentinel_clearance') ?? 0;
      _clearanceLoaded = true;
    });
  }

  Future<void> _elevateToLevel1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sentinel_clearance', 1);
    if (!mounted) return;
    setState(() => _clearanceLevel = 1);
  }

  // Admin-triggered — not called internally; exposed for programmatic use
  // ignore: unused_element
  Future<void> _elevateToLevel2() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sentinel_clearance', 2);
    if (!mounted) return;
    setState(() => _clearanceLevel = 2);
  }

  Future<void> _pageRefresh(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    await _loadClearanceLevel();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _amber,
      duration: const Duration(seconds: 1),
      content: Text("R&D FEED REFRESHED",
          style: GoogleFonts.robotoMono(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
    ));
  }

  @override
  void dispose() {
    _pageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (!_clearanceLoaded) {
      return Scaffold(
        backgroundColor: _pageBg,
        body: Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(
                color: _amber, strokeWidth: 1.5),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/videos/sentinel_rd_loop.mp4',
            ),
          ),
          LaunchTactileEngine(
            focusNode: _pageFocusNode,
            onRefresh: () => _pageRefresh(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SentinelNavBar(),

                // PUBLIC ZONE
                _buildHero(isMobile),
                _buildMVV(isMobile),
                _buildCortexCore(isMobile),
                _buildResearchNodes(isMobile),

                // GATEWAY
                _buildGatewayZone(isMobile),

                // PRIVATE ZONE — clearance 2 only
                if (_clearanceLevel == 2) _buildPrivateZone(isMobile),

                const SizedBox(height: 120),
                const StickyFooterSpacer(),
                const SharedSiteFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HERO
  // =========================================================================
  Widget _buildHero(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Semantics(
            label: 'EchoLevel Sentinel R&D — deep-dive hardware research and development.',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: _amber.withValues(alpha: 0.15),
              child: Text("",
                  style: GoogleFonts.robotoMono(color: _amber,
                      fontSize: isMobile ? 8 : 10,
                      fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            label: 'Deep-dive hardware research and development at EchoLevel Sentinel.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DEEP DIVE HARDWARE',
                    style: TextStyle(fontSize: isMobile ? 32 : 54,
                        fontWeight: FontWeight.bold, color: Colors.white,
                        letterSpacing: 1.5, height: 1.1)),
                Text('RESEARCH & DEVELOPMENT.',
                    style: TextStyle(fontSize: isMobile ? 32 : 54,
                        fontWeight: FontWeight.bold, color: _amber,
                        letterSpacing: 1.5, height: 1.1)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Technical breakdowns, engineering schematics, firmware registers, and physical asset logistics breakthrough nodes. Published research is open. Active research is gated.',
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Text(
                'Technical breakdowns, engineering schematics, firmware registers, and physical asset logistics breakthrough nodes. Published research is open. Active research is gated.',
                style: GoogleFonts.poppins(color: Colors.white70,
                    fontSize: isMobile ? 12 : 16, height: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // =========================================================================
  // MISSION, VISION, VALUES
  // UPDATED: mission reflects full sovereign vision, not just industrial
  // UPDATED: vision has two clear horizons — 2035 and 2040
  // =========================================================================
  // =========================================================================
// MISSION, VISION, VALUES
// UPDATED: Solid dark background (hides background video) + 6 Core Values
// =========================================================================
  Widget _buildMVV(bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF06080E), // Solid dark background hides background video
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              label: 'Who we are — EchoLevel Sentinel mission, vision, and values.',
              child: Text("",
                  style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                      fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            ),
            const SizedBox(height: 48),

            // Mission + Vision side by side on desktop
            isMobile
                ? Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMissionBlock(isMobile),
                  const SizedBox(height: 48),
                  _buildVisionBlock(isMobile),
                ])
                : Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildMissionBlock(isMobile)),
                  const SizedBox(width: 40),
                  Expanded(flex: 7, child: _buildVisionBlock(isMobile)),
                ]),

            const SizedBox(height: 72),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 64),

            Semantics(
              header: true,
              label: 'Our core values.',
              child: Text("VALUES & OPERATING PRINCIPLES",
                  style: GoogleFonts.robotoMono(color: Colors.white38,
                      fontSize: 11, fontWeight: FontWeight.bold,
                      letterSpacing: 2.0)),
            ),
            const SizedBox(height: 32),

            // 6 Core Values Grid
            isMobile
                ? Column(children: [
              _buildValueCard(
                category: 'STRATEGIC PRIORITY',
                number: '01',
                title: 'SOVEREIGNTY FIRST, EXECUTION SECOND, LEGACY ALWAYS',
                body: 'Every system, piece of land, software line, and hardware architecture we build must protect local integrity and control above short-term convenience.',
              ),
              const SizedBox(height: 16),
              _buildValueCard(
                category: 'CULTURE & OPERATIONS',
                number: '02',
                title: 'TRUST MAKES EVERYTHING SIMPLE',
                body: 'Clear, unassailable trust between leadership, team members, and the local community is what keeps deep-level operations secure and nimble.',
              ),
              const SizedBox(height: 16),
              _buildValueCard(
                category: 'CULTURE & OPERATIONS',
                number: '03',
                title: 'ADAPTABILITY IS SURVIVAL',
                body: 'Technology, security environments, and market conditions shift rapidly. We embrace change as the only constant and design flexible, modular systems.',
              ),
              const SizedBox(height: 16),
              _buildValueCard(
                category: 'MINDSET & EXECUTION',
                number: '04',
                title: 'IF NOT NOW, WHEN? IF NOT ME, WHO?',
                body: 'Every team member takes absolute ownership of their domain. We do not wait for external rescue or approval to solve critical problems.',
              ),
              const SizedBox(height: 16),
              _buildValueCard(
                category: 'MINDSET & EXECUTION',
                number: '05',
                title: "TODAY'S BEST PERFORMANCE IS TOMORROW'S BASELINE.",
                body: 'Continuous refinement is our standard. What was considered a breakthrough yesterday becomes the starting foundation for what we build today.',
              ),
              const SizedBox(height: 16),
              _buildValueCard(
                category: 'MINDSET & EXECUTION',
                number: '06',
                title: 'LIVE SERIOUSLY, WORK PURPOSEFULLY.',
                body: 'Building foundational infrastructure requires deep discipline, personal integrity, and total pride in the mission we share.',
              ),
            ])
                : Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(children: [
                    _buildValueCard(
                      category: 'STRATEGIC PRIORITY',
                      number: '01',
                      title: 'SOVEREIGNTY FIRST, EXECUTION SECOND, LEGACY ALWAYS',
                      body: 'Every system, piece of land, software line, and hardware architecture we build must protect local integrity and control above short-term convenience.',
                    ),
                    const SizedBox(height: 16),
                    _buildValueCard(
                      category: 'CULTURE & OPERATIONS',
                      number: '03',
                      title: 'ADAPTABILITY IS SURVIVAL',
                      body: 'Technology, security environments, and market conditions shift rapidly. We embrace change as the only constant and design flexible, modular systems.',
                    ),
                    const SizedBox(height: 16),
                    _buildValueCard(
                      category: 'MINDSET & EXECUTION',
                      number: '05',
                      title: "TODAY'S BEST PERFORMANCE IS TOMORROW'S BASELINE.",
                      body: 'Continuous refinement is our standard. What was considered a breakthrough yesterday becomes the starting foundation for what we build today.',
                    ),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(children: [
                    _buildValueCard(
                      category: 'CULTURE & OPERATIONS',
                      number: '02',
                      title: 'TRUST MAKES EVERYTHING SIMPLE',
                      body: 'Clear, unassailable trust between leadership, team members, and the local community is what keeps deep-level operations secure and nimble.',
                    ),
                    const SizedBox(height: 16),
                    _buildValueCard(
                      category: 'MINDSET & EXECUTION',
                      number: '04',
                      title: 'IF NOT NOW, WHEN? IF NOT ME, WHO?',
                      body: 'Every team member takes absolute ownership of their domain. We do not wait for external rescue or approval to solve critical problems.',
                    ),
                    const SizedBox(height: 16),
                    _buildValueCard(
                      category: 'MINDSET & EXECUTION',
                      number: '06',
                      title: 'LIVE SERIOUSLY, WORK PURPOSEFULLY.',
                      body: 'Building foundational infrastructure requires deep discipline, personal integrity, and total pride in the mission we share.',
                    ),
                  ])),
                ]),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

// MISSION BLOCK
  Widget _buildMissionBlock(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MISSION', style: GoogleFonts.robotoMono(
            color: Colors.white38, fontSize: 10,
            fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        const SizedBox(height: 20),
        Semantics(
          label: 'Mission: EchoLevel Sentinel exists to make every Nigerian asset, business, and person verifiable.',
          child: Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFFFFEA00), width: 2))),
            child: Text(
              'To establish sovereign technological independence and security for Africa digital and physical future.\n\n',
              style: TextStyle(color: Colors.white,
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.bold, height: 1.55, letterSpacing: -0.2),
            ),
          ),
        ),
      ],
    );
  }

// VISION BLOCK (Exact 5-Year Structure)
  Widget _buildVisionBlock(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VISION', style: GoogleFonts.robotoMono(
            color: Colors.white38, fontSize: 10,
            fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0F17),
            border: Border.all(color: _amber.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The 5 Years Vision (By 2031)",
                style: GoogleFonts.robotoMono(
                  color: _amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We do not pursue power or scale for its own sake; we aspire to build a resilient, self-sustaining industrial anchor that lasts for over a century.",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              isMobile
                  ? Column(
                children: [
                  _buildHorizonPhaseCard(
                    horizon: "[ YEAR 1 - 2 ]",
                    title: "Commercial B2B Anchor",
                    points: [
                      "Fuel & Asset Telemetry",
                      "Industrial Asset Protection",
                      "CBN Sandbox Validation",
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(Icons.arrow_downward, color: _amber, size: 20),
                  ),
                  _buildHorizonPhaseCard(
                    horizon: "[ YEAR 3 - 5 ]",
                    title: "National Trust Layer",
                    points: [
                      "Asset Trust Score to Banks",
                      "Individual Citizen Trust Identity",
                      "Making Citizens Credit Worthy",
                    ],
                  ),
                ],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildHorizonPhaseCard(
                      horizon: "[ YEAR 1 - 2 ]",
                      title: "Commercial B2B Anchor",
                      points: [
                        "Fuel & Asset Telemetry",
                        "Industrial Asset Protection",
                        "CBN Sandbox Validation",
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 36),
                    child: Text(
                      "──►",
                      style: TextStyle(
                        color: _amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildHorizonPhaseCard(
                      horizon: "[ YEAR 3 - 5 ]",
                      title: "National Trust Layer",
                      points: [
                        "Asset Trust Score to Banks",
                        "Individual Citizen Trust Identity",
                        "Making Citizens Credit Worthy",
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizonPhaseCard({
    required String horizon,
    required String title,
    required List<String> points,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07080C),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            horizon,
            style: GoogleFonts.robotoMono(
              color: _amber,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...points.map(
                (pt) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(color: _amber, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      pt,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// VALUE CARD DESIGN WITH CATEGORY & SOLID DARK CONTAINER
  Widget _buildValueCard({
    required String category,
    required String number,
    required String title,
    required String body,
  }) {
    return Semantics(
      label: '$category — Value $number: $title. $body',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F17),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  number,
                  style: GoogleFonts.robotoMono(
                    color: _amber,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 1, width: 32, color: _amber.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              body,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
                height: 1.65,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // CORTEX CORE — updated diagram labels and body subtexts
  // =========================================================================
  Widget _buildCortexCore(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 80,
          horizontal: isMobile ? 24 : 0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              label: 'The architecture — Cortex Core, the 1 Head, 3 Bodies philosophy.',
              child: Text("CORTEX CORE™",
                  style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                      fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            ),
            const SizedBox(height: 16),
            Text("The 1 Head, 3 Bodies Philosophy",
                style: TextStyle(color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            isMobile
                ? _buildCortexBody(isMobile)
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildCortexBody(isMobile)),
                const SizedBox(width: 60),
                Expanded(flex: 7, child: _buildCortexDiagram()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCortexBody(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'At the heart of every Sentinel industrial solution is the Cortex Core — a proprietary offline-first IoT engine. It acts as the universal Head — a high-performance cognitive center that adapts to diverse operational bodies.',
          child: Text(
            "At the heart of every Sentinel industrial solution is the Cortex Core™. A proprietary, offline first IoT engine designed specifically for Africa's volatile power and data environments.\n\nThe Cortex Core™ acts as the universal Head, a high performance cognitive center that adapts to diverse Operational Bodies. We build a Proprietary Platform that converts physical entropy into Verifiable Truth, ensuring 99.9% uptime in the most hostile industrial corridors.",
            style: GoogleFonts.poppins(color: Colors.white70,
                fontSize: isMobile ? 13 : 15, height: 1.7),
          ),
        ),
        const SizedBox(height: 40),

        // BODY 01 — FIRMWARE (updated subtext)
        _buildBodyType("BODY 01", "FIRMWARE",
            "The intelligence layer. Embedded decision making that runs on device, offline first, and survives every power interruption Nigeria can throw at it."),
        const SizedBox(height: 16),

        // BODY 02 — HARDWARE (updated subtext)
        _buildBodyType("BODY 02", "HARDWARE",
            "The physical layer. Non invasive modules engineered for Nigeria and Africa conditions."),
        const SizedBox(height: 16),

        // BODY 03 — INFRASTRUCTURE (updated subtext — broader scope)
        _buildBodyType("BODY 03", "INFRASTRUCTURE",
            "The coverage layer. Starting with standby generators and logistics fleets sectors. Expanding to every critical asset class where trust, visibility, and accountability are missing."),
      ],
    );
  }

  Widget _buildBodyType(String tag, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg.withValues(alpha: 0.4),
        border: Border(left: BorderSide(color: _amber, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: GoogleFonts.robotoMono(
              color: _amber.withValues(alpha: 0.6), fontSize: 10,
              fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(
              color: Colors.white54, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  // UPDATED: diagram now shows FIRMWARE, HARDWARE, INFRASTRUCTURE
  Widget _buildCortexDiagram() {
    return SizedBox(
      height: 320,
      child: ExcludeSemantics(
        child: CustomPaint(painter: _CortexDiagramPainter()),
      ),
    );
  }

  // =========================================================================
  // RESEARCH NODES
  // =========================================================================
  Widget _buildResearchNodes(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            label: 'Published research nodes — EchoLevel Sentinel active and classified research tracks.',
            child: Text("",
                style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          ),
          const SizedBox(height: 12),
          Text("Active Research Tracks",
              style: TextStyle(color: Colors.white,
                  fontSize: isMobile ? 26 : 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Research outcomes are published here when ready for external review. Classified and under review nodes require full R&D access.",
              style: GoogleFonts.poppins(color: Colors.white54,
                  fontSize: isMobile ? 12 : 14, height: 1.5)),
          const SizedBox(height: 40),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _researchNodes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) =>
                _buildResearchNodeCard(_researchNodes[i], isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchNodeCard(Map<String, String> node, bool isMobile) {
    final String status   = node['status']!;
    final bool isPublished    = status == 'PUBLISHED';
    final bool isUnderReview  = status == 'UNDER REVIEW';
    Color statusColor = Colors.white24;
    if (isPublished)   statusColor = _green;
    if (isUnderReview) statusColor = _amber;

    return Semantics(
      label: 'Research node: ${node['title']}. Status: $status. Date: ${node['date']}.',
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        decoration: BoxDecoration(
          color: _cardBg.withValues(alpha: 0.2),
          border: Border.all(
            color: isPublished
                ? _green.withValues(alpha: 0.3)
                : isUnderReview
                ? _amber.withValues(alpha: 0.2)
                : Colors.white10,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: statusColor, shape: BoxShape.circle)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(node['title']!,
                      style: TextStyle(
                          color: isPublished ? Colors.white : Colors.white54,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      color: statusColor.withValues(alpha: 0.12),
                      child: Text(status, style: GoogleFonts.robotoMono(
                          color: statusColor, fontSize: 9,
                          fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                    const SizedBox(width: 12),
                    Text(node['date']!, style: GoogleFonts.robotoMono(
                        color: Colors.white24, fontSize: 10)),
                  ]),
                  if (isPublished && node['summary']!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(node['summary']!, style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 13, height: 1.5)),
                  ] else if (!isPublished) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.lock_outline,
                          color: Colors.white24, size: 12),
                      const SizedBox(width: 8),
                      Text("Full access required to view this node.",
                          style: GoogleFonts.robotoMono(
                              color: Colors.white24, fontSize: 10)),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // GATEWAY ZONE — clearance state machine + ConnectionForm wired
  // =========================================================================
  Widget _buildGatewayZone(bool isMobile) {
    if (_clearanceLevel == 2) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("",
                style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 48),
            if (_clearanceLevel == 0) _buildGuestGate(isMobile),
            if (_clearanceLevel == 1) _buildPendingGate(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestGate(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.lock_outline, color: Colors.white24, size: 20),
          const SizedBox(width: 12),
          Text("GUEST ACCESS // R&D LAYER RESTRICTED",
              style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ]),
        const SizedBox(height: 32),
        isMobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccessDescription(isMobile),
              const SizedBox(height: 40),
              _buildFormPanel(isMobile),
            ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 4, child: _buildAccessDescription(isMobile)),
          const SizedBox(width: 60),
          Expanded(flex: 6, child: _buildFormPanel(isMobile)),
        ]),
      ],
    );
  }

  Widget _buildAccessDescription(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Who This Is For",
            style: TextStyle(color: Colors.white,
                fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildAccessAudience("MISSION PARTNERS",
            "Institutional stakeholders, facility managers, fleet operators, investors, and regulators seeking full system access and deployment briefings."),
        const SizedBox(height: 16),
        _buildAccessAudience("SPECIALIZED OPERATIVES",
            "Engineers, PCB designers, firmware developers, and technical collaborators who want to contribute to active Sentinel research tracks."),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _amber.withValues(alpha: 0.05),
            border: Border(left: BorderSide(color: _amber, width: 2)),
          ),
          child: Text(
            "Access to our active R&D pipeline is reserved for verified partners and collaborators. The 2–4 week free pilot program is also initialized through this gateway.",
            style: GoogleFonts.poppins(color: Colors.white70,
                fontSize: 13, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessAudience(String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 6, height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: _amber, shape: BoxShape.circle)),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.robotoMono(color: _amber,
                fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: 4),
            Text(body, style: GoogleFonts.poppins(
                color: Colors.white54, fontSize: 13, height: 1.5)),
          ],
        )),
      ],
    );
  }

  Widget _buildFormPanel(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardBg.withValues(alpha: 0.3),
        border: Border.all(color: _amber.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("INITIALIZE CONNECTION",
              style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text("Select your protocol and submit your connection request.",
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white10),
          const SizedBox(height: 24),

          // Gateway toggle — show/hide ConnectionForm
          GestureDetector(
            onTap: () => setState(
                    () => _showConnectionForm = !_showConnectionForm),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _showConnectionForm
                    ? _amber.withValues(alpha: 0.08)
                    : Colors.transparent,
                border: Border.all(
                  color: _showConnectionForm
                      ? _amber.withValues(alpha: 0.4)
                      : Colors.white10,
                ),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    _showConnectionForm
                        ? "CLOSE CONNECTION FORM"
                        : "OPEN CONNECTION FORM",
                    style: GoogleFonts.robotoMono(
                        color: _showConnectionForm ? _amber : Colors.white54,
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  _showConnectionForm ? Icons.expand_less : Icons.expand_more,
                  color: _showConnectionForm ? _amber : Colors.white38,
                ),
              ]),
            ),
          ),

          // ConnectionForm — wired with pageFocusNode
          if (_showConnectionForm) ...[
            const SizedBox(height: 24),
            ConnectionForm(
              pageFocusNode: _pageFocusNode,
              initialProtocol: "Specialized Operative",
              onInitialize: (data) {
                _elevateToLevel1();
                setState(() => _showConnectionForm = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: _amber,
                  duration: const Duration(seconds: 3),
                  content: Text(
                      "CONNECTION REQUEST SUBMITTED — AWAITING VERIFICATION.",
                      style: GoogleFonts.robotoMono(
                          color: Colors.black,
                          fontWeight: FontWeight.bold, fontSize: 11)),
                ));
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingGate(bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 28 : 48),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.05),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              _PulsingShield(color: Colors.amber),
              const SizedBox(height: 32),
              Text("CLEARANCE LEVEL 1: PENDING",
                  style: GoogleFonts.robotoMono(color: Colors.amber,
                      fontWeight: FontWeight.bold, fontSize: 14,
                      letterSpacing: 2)),
              const SizedBox(height: 20),
              Text("Your connection request has been received. Our team is reviewing your classification and deployment parameters. Verification typically completes within 24 hours.\n\nYou will receive a direct communication at the email address you provided.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white70,
                      fontSize: isMobile ? 13 : 14, height: 1.6)),
              const SizedBox(height: 40),
              LinearProgressIndicator(
                  backgroundColor: Colors.white10,
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 2),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("STATUS: AUDIT_IN_PROGRESS",
                      style: GoogleFonts.robotoMono(
                          color: Colors.amber.withValues(alpha: 0.5),
                          fontSize: 9)),
                  Text("UPLINK ESTABLISHED",
                      style: GoogleFonts.robotoMono(
                          color: Colors.amber.withValues(alpha: 0.5),
                          fontSize: 9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // PRIVATE ZONE — clearance Level 2 only
  // =========================================================================
  Widget _buildPrivateZone(bool isMobile) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: _green.withValues(alpha: 0.1),
              child: Row(children: [
                Icon(Icons.verified_rounded, color: _green, size: 16),
                const SizedBox(width: 12),
                Text("CLEARANCE LEVEL 2 // FULL R&D ACCESS GRANTED",
                    style: GoogleFonts.robotoMono(color: _green, fontSize: 10,
                        fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ]),
            ),
            const SizedBox(height: 48),
            Text("ACTIVE RESEARCH TRACKS",
                style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 12),
            Text("Live R&D Pipeline",
                style: TextStyle(color: Colors.white,
                    fontSize: isMobile ? 26 : 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("What you see here is the active workshop. Schematic previews, firmware notes, thesis documents, and collaboration threads. Handle with integrity.",
                style: GoogleFonts.poppins(color: Colors.white54,
                    fontSize: isMobile ? 12 : 14, height: 1.5)),
            const SizedBox(height: 40),
            _buildPrivateNode("ULTRASONIC SENSING // ACTIVE BUILD",
                "ESP32 + HC-SR04 calibration matrices for Nigerian temperature range (28°C–45°C ambient).",
                isMobile),
            const SizedBox(height: 16),
            _buildPrivateNode("OFFLINE BLACK-BOX // FIRMWARE v0.3",
                "Flash write cycles, memory partitioning, and recovery protocol under power interruption.",
                isMobile),
            const SizedBox(height: 16),
            _buildPrivateNode("VALVE LOCK PROTOCOL // DESIGN PHASE",
                "Motorized valve actuation logic and fail-safe mechanical override specification.",
                isMobile),
            const SizedBox(height: 60),
            Semantics(
              label: 'Fortress statement: Sentinel Labs is more than a laboratory — it is a fortress of indigenous innovation. Stand with us in the gap.',
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(children: [
                    Text("ENGINEERING THE STANDARD FOR 2035",
                        style: GoogleFonts.robotoMono(color: _green,
                            fontSize: 12, fontWeight: FontWeight.bold,
                            letterSpacing: 2.0)),
                    const SizedBox(height: 20),
                    Text("Sentinel Labs is more than a laboratory; it is a fortress of Indigenous Innovation. We are domesticating the technology required to stabilize the continent's most critical infrastructure. Stand with us in the gap.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.white54,
                            fontSize: isMobile ? 13 : 15,
                            fontStyle: FontStyle.italic, height: 1.6)),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateNode(String title, String body, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: _cardBg.withValues(alpha: 0.4),
        border: Border.all(color: _amber.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 8, height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(color: _amber, shape: BoxShape.circle)),
          const SizedBox(width: 20),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.robotoMono(color: Colors.white,
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text(body, style: GoogleFonts.poppins(
                  color: Colors.white54, fontSize: 13, height: 1.5)),
            ],
          )),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: _amber.withValues(alpha: 0.12),
            child: Text("ACTIVE", style: GoogleFonts.robotoMono(
                color: _amber, fontSize: 9,
                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PULSING SHIELD — looping animation for Level 1 pending state
// =============================================================================
class _PulsingShield extends StatefulWidget {
  final Color color;
  const _PulsingShield({required this.color});

  @override
  State<_PulsingShield> createState() => _PulsingShieldState();
}

class _PulsingShieldState extends State<_PulsingShield>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Icon(Icons.security, color: widget.color, size: 52),
    );
  }
}

// =============================================================================
// CORTEX CORE DIAGRAM — updated labels: FIRMWARE, HARDWARE, INFRASTRUCTURE
// =============================================================================
class _CortexDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const Color amber = Color(0xFFFFEA00);
    const Color green = Color(0xFF00C853);
    const Color white = Colors.white;

    final Paint linePaint = Paint()
      ..color = amber.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double cx  = size.width / 2;
    final double headY = size.height * 0.18;
    final double bodyY = size.height * 0.72;

    // HEAD node — amber (Cortex Core)
    canvas.drawCircle(Offset(cx, headY), 22,
        Paint()..color = amber);

    // Three body x positions
    final List<double> bodyXPositions = [
      size.width * 0.12,
      cx,
      size.width * 0.88,
    ];

    // Connector lines from head to each body
    for (final bx in bodyXPositions) {
      canvas.drawLine(Offset(cx, headY + 22), Offset(bx, bodyY - 14), linePaint);
      canvas.drawCircle(Offset(bx, bodyY), 14,
          Paint()..color = green);
    }

    // Horizontal connector between bodies
    canvas.drawLine(
      Offset(bodyXPositions.first, bodyY),
      Offset(bodyXPositions.last, bodyY),
      Paint()..color = green.withValues(alpha: 0.2)..strokeWidth = 1.0,
    );

    // Labels
    _drawLabel(canvas, "CORTEX CORE™", Offset(cx, headY + 46), amber);
    _drawLabel(canvas, "FIRMWARE",     Offset(bodyXPositions[0], bodyY + 28), white);
    _drawLabel(canvas, "HARDWARE",     Offset(bodyXPositions[1], bodyY + 28), white);
    _drawLabel(canvas, "INFRA\nSTRUCTURE", Offset(bodyXPositions[2], bodyY + 28), white);
  }

  void _drawLabel(Canvas canvas, String text, Offset position, Color color) {
    final lines = text.split('\n');
    double yOffset = 0;
    for (final line in lines) {
      final tp = TextPainter(
        text: TextSpan(text: line,
            style: TextStyle(color: color, fontSize: 9,
                fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(position.dx - tp.width / 2, position.dy + yOffset));
      yOffset += tp.height + 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}