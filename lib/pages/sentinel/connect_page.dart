// lib/pages/sentinel/connect_page.dart
// Changes: Card box backgrounds covered with their respective accent colors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../shared/ops_background_engine.dart';
import '../../shared/launch_tactile_engine.dart';
import '../../shared/launch_section_container.dart';
import '../../widgets/sentinel_nav_bar.dart';
import '../../widgets/shared_site_footer.dart';
import '../../widgets/connection_form.dart';

class SentinelFAQ {
  final String category;
  final String question;
  final String answer;
  const SentinelFAQ({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});
  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {

  static const Color _green  = Color(0xFF00C853);
  static const Color _amber  = Color(0xFFFFEA00);
  static const Color _pageBg = Color(0xFF07080C);
  static const Color _cardBg = Color(0xFF0A1A0F);
  static const String _formspreeEndpoint = 'https://formspree.io/f/xpqjyydl';

  // Page-level focus node — passed to LaunchTactileEngine and ConnectionForm
  final FocusNode _pageFocusNode = FocusNode();

  // Scroll anchors
  final GlobalKey _deployKey = GlobalKey();
  final GlobalKey _buildKey  = GlobalKey();
  final GlobalKey _faqKey    = GlobalKey();

  // FAQ search
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocus = _makeIsolatedFocus();
  String _searchQuery = '';

  // Deploy zone — dropdown state
  bool _deployFormExpanded = false;

  // Build zone — dropdown state
  bool _buildFormExpanded = false;

  // Lightweight form
  bool _isSubmittingInterest = false;
  bool _interestSubmitted    = false;
  final TextEditingController _interestNameController  = TextEditingController();
  final TextEditingController _interestEmailController = TextEditingController();
  final TextEditingController _interestWhyController   = TextEditingController();
  late final FocusNode _interestNameFocus  = _makeIsolatedFocus();
  late final FocusNode _interestEmailFocus = _makeIsolatedFocus();
  final FocusNode _interestWhyFocus = FocusNode(); // multiline — plain node

  String _selectedSkillArea = 'Hardware / Embedded Systems';
  static const List<String> _skillAreas = [
    'Hardware / Embedded Systems',
    'Firmware / C++ / ESP32',
    'Flutter / Mobile Development',
    'Backend / Cloud Infrastructure',
    'PCB Design / KiCad',
    'IoT / Sensor Systems',
    'Fuel / Energy Industry Expert',
    'Logistics / Fleet Industry Expert',
    'Banking / Financial Services',
    'Regulatory / Compliance',
    'Business Development',
    'Other',
  ];

  // =========================================================================
  // ISOLATED FOCUS — horizontal arrows + space only (matches LBP intake form)
  // =========================================================================
  FocusNode _makeIsolatedFocus() {
    return FocusNode(
      onKeyEvent: (node, event) {
        final bool isHorizontal =
            event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowRight;
        final bool isSpace =
            event.logicalKey == LogicalKeyboardKey.space;
        if (isHorizontal || isSpace) {
          return KeyEventResult.skipRemainingHandlers;
        }
        return KeyEventResult.ignored;
      },
    );
  }

  // =========================================================================
  // FAQ DATA
  // =========================================================================
  static const List<SentinelFAQ> _faqs = [
    SentinelFAQ(category: 'HOW IT WORKS',
      question: 'How does the EchoLevel Sentinel system work?',
      answer: 'The system is modular with two main parts. The Shell mounts on the generator or vehicle. The Head unit stays in a safe location such as an office or control room. It receives data from the Shell wirelessly, uploads everything to the cloud, and sends real time alerts to your dashboard or phone. Data is stored locally and synced to the cloud automatically.',
    ),
    SentinelFAQ(category: 'HOW IT WORKS',
      question: 'What is the difference between the Head and the Shell?',
      answer: 'The Head is the brain. It stays indoors, handles data processing, cloud upload, alerting, and dashboard communication. The Shell is the field unit. The Shell is rugged and designed for fuel vapor, heat, vibration, and dust. The separation means if one unit has an issue, the other continues operating independently.',
    ),
    SentinelFAQ(category: 'HOW IT WORKS',
      question: 'How do the Head and Shell communicate?',
      answer: 'They communicate wirelessly using a connectionless protocol that works without Wi-Fi infrastructure.',
    ),
    SentinelFAQ(category: 'MEASUREMENT & ACCURACY',
      question: 'How accurate is the fuel level measurement?',
      answer: 'On stationary generators, we target ±2–3% accuracy using a ultrasonic sensor with median and slosh compensation. Temperature compensation corrects for fuel expansion from ambient heat changes. On vehicles, dynamic filtering accounts for sloshing during movement.',
    ),
    SentinelFAQ(category: 'MEASUREMENT & ACCURACY',
      question: 'How do you detect fuel adulteration?',
      answer: 'We use an acoustic signal analysis. Different fuel compositions — pure diesel, diesel mixed with water, diesel mixed with kerosene, produce distinct acoustic signatures. Our algorithm compares the detected signature against a known pure diesel baseline and raises an alert on significant deviation. Non invasive, no sampling required.',
    ),
    SentinelFAQ(category: 'MEASUREMENT & ACCURACY',
      question: 'How do you prevent false theft alarms?',
      answer: 'Theft alerts use multi confirmation logic. An alert only triggers when: fuel level drops significantly, the vibration sensor confirms the engine is OFF, and no authorized refill has been logged. This cross validation dramatically reduces false positives versus single sensor systems.',
    ),
    SentinelFAQ(category: 'INSTALLATION & POWER',
      question: 'Do you need to drill into the fuel tank?',
      answer: 'No. Cortex Core is completely non invasive. The ultrasonic mounts externally using brackets, strong industrial tape, or existing access points. No drilling, no tank modification, no warranty voiding.',
    ),
    SentinelFAQ(category: 'INSTALLATION & POWER',
      question: 'How long does installation take?',
      answer: 'Standard standby generator: 20–50 minutes. Commercial vehicles: 30–60 minutes depending on tank accessibility. No specialist tools required.',
    ),
    SentinelFAQ(category: 'INSTALLATION & POWER',
      question: 'How do you power the device?',
      answer: 'The Shell runs on a dedicated rechargeable battery. Completely independent of the asset. No drain on the generator battery or vehicle electrical system. A small solar panel can be added for indefinite runtime.',
    ),
    SentinelFAQ(category: 'INSTALLATION & POWER',
      question: 'What is the battery life?',
      answer: 'Standard operation: 4–8 days on a single 3000mAh 18650 cell. With deep sleep mode and intelligent shell power cycling: 12–18 days. Solar panel eliminates battery life as a concern entirely.',
    ),
    SentinelFAQ(category: 'INSTALLATION & POWER',
      question: 'Can the system monitor during a generator power outage?',
      answer: 'Yes. The Shell runs on its own battery completely independent of the generator. It continues monitoring and sends theft alerts if fuel drops while the engine is off. Generator fuel theft most commonly happens during downtime.',
    ),
    SentinelFAQ(category: 'SECURITY & DATA',
      question: 'How do you prevent physical tampering?',
      answer: 'The Shell includes a physical tamper switch. If the casing is opened, repositioned, or removed, an immediate alert is sent. Future versions will include cryptographic device sealing via secure element chip.',
    ),
    SentinelFAQ(category: 'SECURITY & DATA',
      question: 'How do you protect customer data?',
      answer: 'All data is encrypted in transit and at rest in our database. Access to this data is role based, only authorized users for a specific organisation see that organisation\'s data. We are preparing for full NDPR compliance.',
    ),
    SentinelFAQ(category: 'SECURITY & DATA',
      question: 'How tamper proof is the data itself?',
      answer: 'Every telemetry record is timestamped and cryptographically signed at the device level. Records cannot be altered retroactively without detection. The offline Black Box carries the same integrity guarantees. Even data collected without connectivity holds a verifiable digital signature.',
    ),
    SentinelFAQ(category: 'SECURITY & DATA',
      question: 'How do you ensure NDPR compliance?',
      answer: 'NDPR compliance is built in from architecture level: explicit data collection consent during onboarding, documented retention policies, role based access controls, data portability on request, and right to deletion. We will publish a formal Data Processing Agreement before commercial launch.',
    ),
    SentinelFAQ(category: 'BUSINESS & SCALE',
      question: 'What is your pricing model?',
      answer: 'We are in pilot phase and deliberately not finalizing pricing until we have real deployment data. Target ROI: the recovered fuel pays for the system within 2–3 months of deployment.',
    ),
    SentinelFAQ(category: 'BUSINESS & SCALE',
      question: 'Can Sentinel integrate with existing telematics or monitoring systems?',
      answer: 'Yes. We can push data via API to platforms like Wialon and other fleet telematics systems, or deliver alerts to existing monitoring dashboards via webhook. API documentation will be available to pilot participants.',
    ),
    SentinelFAQ(category: 'BUSINESS & SCALE',
      question: 'What if we are in a remote area with poor network coverage?',
      answer: 'The offline Black Box stores all readings locally and syncs automatically when connectivity returns. For no Wi-Fi deployments, an optional GSM module sends alerts via SMS and uploads over mobile networks.',
    ),
    SentinelFAQ(category: 'BUSINESS & SCALE',
      question: 'What happens if the device malfunctions in the field?',
      answer: 'A device failure never disrupts the customer\'s operations, the generator or vehicle continues functioning normally. We will offer SLAs during commercial stage. During pilot phase: replacement or repair within 48 hours. Remote diagnostics are built into the dashboard so we can often resolve issues without a site visit.',
    ),
  ];

  // =========================================================================
  // HELPERS
  // =========================================================================
  Map<String, List<SentinelFAQ>> get _filteredGroupedFaqs {
    final Map<String, List<SentinelFAQ>> grouped = {};
    for (final faq in _faqs) {
      final bool matches = _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      if (matches) grouped.putIfAbsent(faq.category, () => []).add(faq);
    }
    return grouped;
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut);
  }

  void _launchEmail() async {
    final Uri uri = Uri(
        scheme: 'mailto',
        path: 'launchbypatrick.webdev@gmail.com',
        query: 'subject=Sentinel Inquiry');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _submitInterest() async {
    if (_interestNameController.text.trim().isEmpty ||
        _interestEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("NAME AND EMAIL ARE REQUIRED")));
      return;
    }
    setState(() => _isSubmittingInterest = true);
    try {
      await http.post(Uri.parse(_formspreeEndpoint),
          headers: {'Accept': 'application/json'},
          body: {
            'Form_Type':    'Sentinel — Expression of Interest',
            'Name':         _interestNameController.text.trim(),
            'Email':        _interestEmailController.text.trim(),
            'Skill_Area':   _selectedSkillArea,
            'Why_Sentinel': _interestWhyController.text.trim(),
            'Timestamp':    DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('⚠️ Interest form: $e');
    }
    if (!mounted) return;
    setState(() {
      _isSubmittingInterest = false;
      _interestSubmitted    = true;
    });
  }

  @override
  void dispose() {
    _pageFocusNode.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _interestNameController.dispose();
    _interestEmailController.dispose();
    _interestWhyController.dispose();
    _interestNameFocus.dispose();
    _interestEmailFocus.dispose();
    _interestWhyFocus.dispose();
    super.dispose();
  }

  // =========================================================================
  // BUILD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/images/sentinel_connect.webp',
            ),
          ),
          LaunchTactileEngine(
            focusNode: _pageFocusNode,
            onRefresh: () async =>
            await Future.delayed(const Duration(milliseconds: 800)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SentinelNavBar(),
                _buildHeader(isMobile),
                _buildPathSelector(isMobile),
                _buildDeployZone(isMobile),
                _buildBuildZone(isMobile),
                _buildFaqZone(isMobile),
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
  // ZONE 1: HEADER
  // =========================================================================
  Widget _buildHeader(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Semantics(
            label: 'EchoLevel Sentinel connection protocol.',
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              color: _green.withValues(alpha: 0.15),
              child: Text(
                "",
                style: GoogleFonts.robotoMono(
                    color: _green,
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            label: 'How to connect with Sentinel.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HOW TO CONNECT',
                    style: TextStyle(
                        fontSize: isMobile ? 30 : 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        height: 1.1)),
                Text('WITH SENTINEL.',
                    style: TextStyle(
                        fontSize: isMobile ? 30 : 52,
                        fontWeight: FontWeight.bold,
                        color: _green,
                        letterSpacing: 1.2,
                        height: 1.1)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              'Two types of people find their path here. Those who need our technology, and those who want to build it. Both matter to what EchoLevel Sentinel is becoming.',
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: isMobile ? 14 : 16,
                  height: 1.65),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // =========================================================================
  // ZONE 2: PATH SELECTOR
  // =========================================================================
  Widget _buildPathSelector(bool isMobile) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3), // Overall background untouched
      child: LaunchSectionContainer(
        child: Column(
          children: [
            isMobile
                ? Column(children: [
              _buildPathCard(
                  icon: Icons.sensors,
                  title: 'DEPLOY SENTINEL',
                  subtitle:
                  'I need fuel telemetry for my operation, fleet, or facility.',
                  cta: 'Go to Pilot & Inquiry →',
                  color: _green,
                  isMobile: isMobile,
                  onTap: () => _scrollTo(_deployKey)),
              const SizedBox(height: 16),
              _buildPathCard(
                  icon: Icons.build_circle_outlined,
                  title: 'BUILD SENTINEL',
                  subtitle:
                  'I want to contribute to what Sentinel is building.',
                  cta: 'Go to Opportunities →',
                  color: _amber,
                  isMobile: isMobile,
                  onTap: () => _scrollTo(_buildKey)),
            ])
                : Row(children: [
              Expanded(
                  child: _buildPathCard(
                      icon: Icons.sensors,
                      title: 'DEPLOY SENTINEL',
                      subtitle:
                      'I need fuel telemetry for my operation, fleet, or facility.',
                      cta: 'Go to Pilot & Inquiry →',
                      color: _green,
                      isMobile: isMobile,
                      onTap: () => _scrollTo(_deployKey))),
              const SizedBox(width: 24),
              Expanded(
                  child: _buildPathCard(
                      icon: Icons.build_circle_outlined,
                      title: 'BUILD SENTINEL',
                      subtitle:
                      'I want to contribute to what Sentinel is building.',
                      cta: 'Go to Opportunities →',
                      color: _amber,
                      isMobile: isMobile,
                      onTap: () => _scrollTo(_buildKey))),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPathCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String cta,
    required Color color,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            color.withValues(alpha: 0.15),
            const Color(0xFF0B0F17),
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              cta,
              style: GoogleFonts.robotoMono(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ZONE 3: DEPLOY PATH
  // Form is now a collapsible dropdown — section aware
  // =========================================================================
  Widget _buildDeployZone(bool isMobile) {
    return Container(
      key: _deployKey,
      color: Colors.black.withValues(alpha: 0.2),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildZoneLabel("DEPLOY SENTINEL", _green),
            const SizedBox(height: 12),
            Text(
              "For Organisations That Need Sentinel",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 22 : 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Facility managers, fleet operators, institutional partners, and investors. Start with a question or apply directly for your free pilot.",
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: isMobile ? 12 : 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // 1. Mission Partner Form (Green)
            _buildFormDropdown(
              isExpanded: _deployFormExpanded,
              isLocked: false,
              color: _green,
              title: "MISSION PARTNER — INITIALIZE YOUR CONNECTION",
              subtitle:
              "Facility managers, fleet operators, institutional partners, and investors.",
              onToggle: () =>
                  setState(() => _deployFormExpanded = !_deployFormExpanded),
              lockedMessage: null,
              child: _deployFormExpanded
                  ? Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ConnectionForm(
                    pageFocusNode: _pageFocusNode,
                    initialProtocol: "Mission Partner",
                    lockedProtocol: "Mission Partner",
                    onLockedTabTap: () => _scrollTo(_buildKey),
                    onInitialize: (data) {
                      setState(() => _deployFormExpanded = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: _green,
                        duration: const Duration(seconds: 3),
                        content: Text(
                          "CONNECTION INITIALIZED — CHECK YOUR INBOX.",
                          style: GoogleFonts.robotoMono(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ));
                    },
                  ),
                ),
              )
                  : null,
            ),

            const SizedBox(height: 16),

            // 2. Specialized Operative Dropdown (Amber / Yellow)
            _buildFormDropdown(
              isExpanded: false,
              isLocked: true,
              color: _amber, // Dynamic yellow identity
              title: "SPECIALIZED OPERATIVE",
              subtitle:
              "Looking to contribute technically? This path is in the Build section.",
              onToggle: () => _scrollTo(_buildKey),
              lockedMessage: "→ Go to Build Sentinel section",
              child: null,
            ),

            const SizedBox(height: 56),
            _buildContactDetails(isMobile),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ZONE 4: BUILD PATH
  // Lightweight form + collapsible Specialized Operative ConnectionForm
  // =========================================================================
  Widget _buildBuildZone(bool isMobile) {
    return Container(
      key: _buildKey,
      color: _amber.withValues(alpha: 0.02),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildZoneLabel("BUILD SENTINEL", _amber),
            const SizedBox(height: 12),
            Text("For Builders, Engineers & Collaborators",
                style: TextStyle(color: Colors.white,
                    fontSize: isMobile ? 22 : 30,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _buildHonestStatement(isMobile),
            const SizedBox(height: 40),
            Text("WHAT IS AVAILABLE RIGHT NOW",
                style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 24),
            isMobile
                ? Column(children: [
              _buildCollabCard('01', 'EARLY TECHNICAL COLLABORATOR',
                  'Engineers and hardware designers who want to contribute to active R&D work on a voluntary or advisory basis while Sentinel reaches commercial stage.'),
              const SizedBox(height: 16),
              _buildCollabCard('02', 'DOMAIN ADVISOR',
                  'Industry professionals in fuel distribution, logistics, banking, or telecoms who can validate our market assumptions and shape our deployment approach.'),
              const SizedBox(height: 16),
              _buildCollabCard('03', 'FUTURE CONSIDERATION',
                  'Builders who want to be first-in-line when Sentinel reaches the stage where it can bring people on formally. Register your interest now.'),
            ])
                : Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCollabCard('01',
                      'EARLY TECHNICAL COLLABORATOR',
                      'Engineers and hardware designers who want to contribute to active R&D work on a voluntary or advisory basis while Sentinel reaches commercial stage.')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCollabCard('02', 'DOMAIN ADVISOR',
                      'Industry professionals in fuel distribution, logistics, banking, or telecoms who can validate our market assumptions and shape our deployment approach.')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCollabCard('03',
                      'FUTURE CONSIDERATION',
                      'Builders who want to be first-in-line when Sentinel reaches the stage where it can bring people on formally. Register your interest now.')),
                ]),
            const SizedBox(height: 48),

            // Lightweight form — always visible
            _buildLightweightForm(isMobile),
            const SizedBox(height: 32),

            // DROPDOWN: Specialized Operative ConnectionForm
            _buildFormDropdown(
              isExpanded: _buildFormExpanded,
              isLocked: false,
              color: _amber,
              title: "SPECIALIZED OPERATIVE — GO DEEPER",
              subtitle: "For engineers serious about active R&D contribution. Submit a full request — potential full access to the Sentinel labs pipeline.",
              onToggle: () => setState(() =>
              _buildFormExpanded = !_buildFormExpanded),
              lockedMessage: null,
              child: _buildFormExpanded
                  ? Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ConnectionForm(
                    pageFocusNode: _pageFocusNode,
                    initialProtocol: "Specialized Operative",
                    lockedProtocol: "Specialized Operative",
                    onLockedTabTap: () => _scrollTo(_deployKey),
                    onInitialize: (data) {
                      setState(() => _buildFormExpanded = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: _amber,
                        duration: const Duration(seconds: 3),
                        content: Text(
                            "OPERATIVE UPLINK INITIALIZED — CHECK YOUR INBOX.",
                            style: GoogleFonts.robotoMono(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ));
                    },
                  ),
                ),
              )
                  : null,
            ),

            // Locked Mission Partner — redirects to Deploy zone
            const SizedBox(height: 16),
            _buildFormDropdown(
              isExpanded: false,
              isLocked: true,
              color: _amber,
              title: "MISSION PARTNER",
              subtitle: "Looking to deploy Sentinel for your operation? This path is in the Deploy section.",
              onToggle: () => _scrollTo(_deployKey),
              lockedMessage: "→ Go to Deploy Sentinel section",
              child: null,
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // REUSABLE DROPDOWN FORM WRAPPER
  // isLocked = true means it shows a redirect hint instead of expanding
  // =========================================================================
  Widget _buildFormDropdown({
    required bool isExpanded,
    required bool isLocked,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onToggle,
    required String? lockedMessage,
    required Widget? child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: isExpanded ? 0.15 : 0.10),
          const Color(0xFF0B0F17),
        ),
        border: Border.all(
          color: isExpanded ? color : color.withValues(alpha: 0.4),
          width: isExpanded ? 1.5 : 1.0,
        ),
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
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isLocked)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(Icons.lock_outline,
                                    color: color.withValues(alpha: 0.6),
                                    size: 14),
                              ),
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.robotoMono(
                                  color: isLocked
                                      ? color.withValues(alpha: 0.8)
                                      : isExpanded
                                      ? color
                                      : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isLocked && lockedMessage != null
                              ? lockedMessage
                              : subtitle,
                          style: GoogleFonts.poppins(
                            color: isLocked ? color : Colors.white54,
                            fontSize: 12,
                            height: 1.4,
                            fontWeight:
                            isLocked ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    isLocked
                        ? Icons.arrow_forward
                        : isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded form container
          if (!isLocked && isExpanded && child != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF07080C),
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // CONTACT DETAILS
  // =========================================================================
  Widget _buildContactDetails(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DIRECT CONTACT",
            style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 10,
                fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        const SizedBox(height: 20),
        isMobile
            ? Column(children: [
          _buildContactBox(icon: Icons.alternate_email,
              label: "EMAIL",
              value: "launchbypatrick.webdev@gmail.com",
              onTap: _launchEmail),
          const SizedBox(height: 12),
          _buildContactBox(icon: Icons.access_time,
              label: "TIMEZONE",
              value: "09:00 – 18:00 (GMT+1)", onTap: null),
          const SizedBox(height: 12),
          _buildContactBox(icon: Icons.public,
              label: "LOCATION",
              value: "Ibadan, Nigeria  ·  Lagos Ops  ·  Remote",
              onTap: null),
        ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                _green.withValues(alpha: 0.10),
                const Color(0xFF0B0F17),
              ),
              border: Border.all(color: _green.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(children: [
              _buildContactRow(icon: Icons.alternate_email,
                  label: "EMAIL",
                  value: "launchbypatrick.webdev@gmail.com",
                  onTap: _launchEmail),
              const Divider(color: Colors.white10, height: 28),
              _buildContactRow(icon: Icons.access_time,
                  label: "TIMEZONE",
                  value: "09:00 – 18:00 (GMT+1)", onTap: null),
            ]),
          )),
          const SizedBox(width: 16),
          Expanded(child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                _green.withValues(alpha: 0.10),
                const Color(0xFF0B0F17),
              ),
              border: Border.all(color: _green.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(children: [
              _buildContactRow(icon: Icons.public,
                  label: "LOCATION",
                  value: "Ibadan, Nigeria  ·  Lagos Ops  ·  Remote",
                  onTap: null),
              const Divider(color: Colors.white10, height: 28),
              _buildContactRow(icon: Icons.schedule_send_outlined,
                  label: "RESPONSE TIME",
                  value: "Within 24 hours on working days",
                  onTap: null),
            ]),
          )),
        ]),
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon, required String label,
    required String value, required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      mouseCursor: onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Row(children: [
        Icon(icon, color: Colors.white24, size: 16),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.robotoMono(
                color: Colors.white38, fontSize: 9,
                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.robotoMono(
                color: Colors.white, fontSize: 12)),
          ],
        )),
        if (onTap != null)
          Icon(Icons.arrow_forward, color: _green, size: 12),
      ]),
    );
  }

  Widget _buildContactBox({
    required IconData icon, required String label,
    required String value, required VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          _green.withValues(alpha: 0.10),
          const Color(0xFF0B0F17),
        ),
        border: Border.all(color: _green.withValues(alpha: 0.3)),
      ),
      child: _buildContactRow(
          icon: icon, label: label, value: value, onTap: onTap),
    );
  }

  // =========================================================================
  // HONEST STATEMENT
  // =========================================================================
  Widget _buildHonestStatement(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          _amber.withValues(alpha: 0.12),
          const Color(0xFF0B0F17),
        ),
        border: const Border(left: BorderSide(color: _amber, width: 3)),
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
          Text("WE ARE NOT HIRING YET.\nWE ARE BUILDING THE TEAM.",
              style: GoogleFonts.robotoMono(color: Colors.white,
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 16),
          Text("There are no salaried positions at Sentinel today. What we are looking for are the people who want to be involved before that changes — early technical contributors, advisors, and collaborators who understand what we are building and want their fingerprints on it from the start.",
              style: GoogleFonts.poppins(color: Colors.white70,
                  fontSize: isMobile ? 13 : 15, height: 1.65)),
          const SizedBox(height: 12),
          Text("If that is you, tell us.",
              style: GoogleFonts.poppins(color: _amber,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildCollabCard(String number, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          _amber.withValues(alpha: 0.10),
          const Color(0xFF0B0F17),
        ),
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
          Text(number, style: TextStyle(
              color: _amber.withValues(alpha: 0.5), fontSize: 11,
              fontFamily: 'monospace', fontWeight: FontWeight.bold,
              letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.robotoMono(color: Colors.white,
              fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Container(height: 1, width: 28, color: _amber.withValues(alpha: 0.3)),
          const SizedBox(height: 14),
          Text(body, style: GoogleFonts.poppins(
              color: Colors.white54, fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }

  // =========================================================================
  // LIGHTWEIGHT FORM
  // =========================================================================
  Widget _buildLightweightForm(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          _amber.withValues(alpha: 0.12),
          const Color(0xFF0B0F17),
        ),
        border: Border.all(color: _amber.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _interestSubmitted
          ? Column(children: [
        const SizedBox(height: 20),
        Icon(Icons.check_circle_outline, color: _amber, size: 48),
        const SizedBox(height: 20),
        Text("INTEREST REGISTERED",
            style: GoogleFonts.robotoMono(color: _amber, fontSize: 14,
                fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        const SizedBox(height: 12),
        Text("We have your details. When the right moment comes — and it will — you will be among the first people we reach out to.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70,
                fontSize: 14, height: 1.6)),
        const SizedBox(height: 20),
      ])
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("REGISTER YOUR INTEREST",
              style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 6),
          Text("Quick — takes 60 seconds.",
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 24),
          _buildLightField("YOUR NAME",
              _interestNameController, _interestNameFocus, null),
          const SizedBox(height: 14),
          _buildLightField("EMAIL ADDRESS *",
              _interestEmailController, _interestEmailFocus, null),
          const SizedBox(height: 14),
          Text("SKILL AREA", style: GoogleFonts.robotoMono(
              color: Colors.white38, fontSize: 9, letterSpacing: 2)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: Colors.white10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSkillArea,
                dropdownColor: const Color(0xFF0A0B10),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: _amber),
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 13),
                items: _skillAreas.map((s) =>
                    DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) =>
                    setState(() => _selectedSkillArea = val!),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildLightField("WHY SENTINEL? (optional)",
              _interestWhyController, _interestWhyFocus, 4),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
              _isSubmittingInterest ? null : _submitInterest,
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber,
                disabledBackgroundColor: _amber.withValues(alpha: 0.4),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: _isSubmittingInterest
                  ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2))
                  : Text("REGISTER MY INTEREST",
                  style: GoogleFonts.robotoMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 13, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightField(String label, TextEditingController controller,
      FocusNode focusNode, int? maxLines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.robotoMono(
            color: Colors.white38, fontSize: 9, letterSpacing: 2)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines ?? 1,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          onTapOutside: (_) => _pageFocusNode.requestFocus(),
          onSubmitted: (_) => _pageFocusNode.requestFocus(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white10),
                borderRadius: BorderRadius.zero),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _amber),
                borderRadius: BorderRadius.zero),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // ZONE 5: FAQ
  // =========================================================================
  Widget _buildFaqZone(bool isMobile) {
    final Map<String, List<SentinelFAQ>> grouped = _filteredGroupedFaqs;
    return Container(
      key: _faqKey,
      color: Colors.black.withValues(alpha: 0.3),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            isMobile
                ? _buildFaqMobileLayout(grouped)
                : _buildFaqDesktopLayout(grouped),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqDesktopLayout(Map<String, List<SentinelFAQ>> grouped) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.only(right: 40, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildZoneLabel("FREQUENTLY ASKED QUESTIONS", _green),
                const SizedBox(height: 24),
                const Text("Technical Briefings",
                    style: TextStyle(color: Colors.white,
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text("Everything prospects, partners, investors, and evaluators typically ask — with complete answers.",
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 13, height: 1.5)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      _green.withValues(alpha: 0.10),
                      const Color(0xFF0B0F17),
                    ),
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(' ${_faqs.length}',
                          style: GoogleFonts.robotoMono(
                              color: _green, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text('FILTER_STATUS: ${_searchQuery.isNotEmpty ? "ACTIVE" : "IDLE"}',
                          style: GoogleFonts.robotoMono(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFaqSearch(),
              const SizedBox(height: 20),
              _buildFaqAccordion(grouped),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaqMobileLayout(Map<String, List<SentinelFAQ>> grouped) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildZoneLabel("FREQUENTLY ASKED QUESTIONS", _green),
        const SizedBox(height: 16),
        const Text("Technical Briefings",
            style: TextStyle(color: Colors.white,
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Everything prospects, partners, investors, and evaluators typically ask.",
            style: GoogleFonts.poppins(
                color: Colors.white54, fontSize: 13, height: 1.5)),
        const SizedBox(height: 20),
        _buildFaqSearch(),
        const SizedBox(height: 16),
        _buildFaqAccordion(grouped),
      ],
    );
  }

  Widget _buildFaqSearch() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
      cursorColor: _green,
      onChanged: (val) => setState(() => _searchQuery = val),
      onTapOutside: (_) => _pageFocusNode.requestFocus(),
      decoration: InputDecoration(
        hintText: 'SEARCH QUESTIONS...',
        hintStyle: GoogleFonts.robotoMono(color: Colors.white24, fontSize: 12),
        prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
            icon: const Icon(Icons.close, color: Colors.white38, size: 16),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            })
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10),
            borderRadius: BorderRadius.zero),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _green),
            borderRadius: BorderRadius.zero),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildFaqAccordion(Map<String, List<SentinelFAQ>> grouped) {
    if (grouped.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(child: Text('NO MATCHING QUESTIONS FOUND.',
            style: GoogleFonts.robotoMono(
                color: Colors.white24, fontSize: 12))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grouped.keys.length,
      itemBuilder: (_, catIndex) {
        final String category = grouped.keys.elementAt(catIndex);
        final List<SentinelFAQ> faqs = grouped[category]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 12),
              child: Text(category, style: GoogleFonts.robotoMono(
                  color: _green, fontSize: 10,
                  fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                expansionTileTheme: ExpansionTileThemeData(
                  iconColor: _green, collapsedIconColor: Colors.white38,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 24, top: 4),
                ),
              ),
              child: Column(
                children: faqs.map((faq) => Container(
                  decoration: const BoxDecoration(border: Border(
                      bottom: BorderSide(color: Colors.white10, width: 1))),
                  child: ExpansionTile(
                    title: Text(faq.question,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 15, fontWeight: FontWeight.w500,
                            height: 1.4)),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(faq.answer,
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 14, height: 1.65))],
                  ),
                )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // SHARED HELPERS
  // =========================================================================
  Widget _buildZoneLabel(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: color.withValues(alpha: 0.12),
      child: Text(label, style: GoogleFonts.robotoMono(
          color: color, fontSize: 10,
          fontWeight: FontWeight.bold, letterSpacing: 2.0)),
    );
  }
}