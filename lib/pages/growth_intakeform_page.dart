import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../shared/ops_background_engine.dart';
import '../shared/launch_tactile_engine.dart';
import '../shared/launch_section_container.dart';
import '../widgets/shared_site_footer.dart';

class GrowthIntakeformPage extends StatefulWidget {
  const GrowthIntakeformPage({super.key});

  @override
  State<GrowthIntakeformPage> createState() => _GrowthIntakeformPageState();
}

class _GrowthIntakeformPageState extends State<GrowthIntakeformPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isTransmitting = false;

  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _techStackController = TextEditingController();
  final _teamSizeController = TextEditingController();
  final _bottleneckController = TextEditingController();

  late final FocusNode _nameFocus;
  late final FocusNode _companyFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _techStackFocus;
  late final FocusNode _teamSizeFocus;
  late final FocusNode _bottleneckFocus;
  late final FocusNode _pageFocusNode;

  String _selectedTrack = 'WEB ARCHITECTURE & PRODUCTION SCALE';
  final List<String> _engagementTracks = [
    'WEB ARCHITECTURE & PRODUCTION SCALE',
    'CREATOR ECONOMY EMPOWERMENT',
    'CUSTOM SYSTEM AUDIT'
  ];

  @override
  void initState() {
    super.initState();
    _pageFocusNode = FocusNode();
    _nameFocus = _createIsolatedFocusNode();
    _companyFocus = _createIsolatedFocusNode();
    _emailFocus = _createIsolatedFocusNode();
    _techStackFocus = _createIsolatedFocusNode();
    _teamSizeFocus = _createIsolatedFocusNode();
    _bottleneckFocus = _createIsolatedFocusNode();
  }

  FocusNode _createIsolatedFocusNode() {
    return FocusNode(
      onKeyEvent: (node, event) {
        final isHorizontalArrowKey =
            event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowRight;
        final isSpaceKey = event.logicalKey == LogicalKeyboardKey.space;
        if (isHorizontalArrowKey || isSpaceKey) {
          return KeyEventResult.skipRemainingHandlers;
        }
        return KeyEventResult.ignored;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _techStackController.dispose();
    _teamSizeController.dispose();
    _bottleneckController.dispose();
    _nameFocus.dispose();
    _companyFocus.dispose();
    _emailFocus.dispose();
    _techStackFocus.dispose();
    _teamSizeFocus.dispose();
    _bottleneckFocus.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitTransmission() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isTransmitting = true);

    final payload = {
      "Form_Type": "High-Value Architect Engagement",
      "Target_Track": _selectedTrack,
      "Name": _nameController.text.trim(),
      "Company": _companyController.text.trim(),
      "Email": _emailController.text.trim(),
      "Tech_Stack": _techStackController.text.trim(),
      "Team_Size": _teamSizeController.text.trim(),
      "Operational_Bottleneck": _bottleneckController.text.trim(),
    };

    try {
      await http.post(
        Uri.parse('https://formspree.io/f/xpqjyydl'),
        headers: {"Accept": "application/json"},
        body: payload,
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isTransmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0B10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xFF00E5FF)),
        ),
        title: const Text(
          'PROTOCOL INTAKE LOCKED',
          style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
              letterSpacing: 1.0),
        ),
        content: const Text(
          'Your deep scoping parameters have been established. Direct architect engagement and scheduling sequences are routing to your corporate inbox.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text(
              'ACKNOWLEDGED',
              style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 11),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    const Color accentColor = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      body: Stack(
        children: [
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/videos/growth-intakeform.mp4',
            ),
          ),
          LaunchTactileEngine(
            focusNode: _pageFocusNode,
            onRefresh: () async =>
            await Future.delayed(const Duration(milliseconds: 1000)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStandaloneHeader(),

                LaunchSectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'INTAKE PROTOCOL.',
                        style: TextStyle(
                          fontSize: isMobile ? 32 : 56,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 2.0,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: const Text(
                          'Initialize a direct deployment line. Provide your software infrastructure baseline and operational blockages for enterprise scheduling.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                LaunchSectionContainer(
                  child: isMobile
                      ? _buildMobileLayout(accentColor)
                      : _buildDesktopLayout(accentColor),
                ),

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
  // MOBILE LAYOUT — pure Column, zero Expanded, children are intrinsic height
  // =========================================================================
  Widget _buildMobileLayout(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTrackSelector(accentColor),      // sizes to its own content
        const SizedBox(height: 40),
        _buildIntakeForm(accentColor),         // sizes to its own content
      ],
    );
  }

  // =========================================================================
  // DESKTOP LAYOUT — Row with Expanded children, bounded width from parent
  // =========================================================================
  Widget _buildDesktopLayout(Color accentColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _buildTrackSelector(accentColor),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 6,
          child: _buildIntakeForm(accentColor),
        ),
      ],
    );
  }

  // =========================================================================
  // LEFT PANEL — Track selector + architect node (shared between layouts)
  // =========================================================================
  Widget _buildTrackSelector(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0B10).withValues(alpha: 0.7),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRACK SELECTION',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: _engagementTracks.map((track) {
              final bool isSelected = _selectedTrack == track;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedTrack = track),
                  borderRadius: BorderRadius.zero,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.05)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? accentColor : Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected ? accentColor : Colors.white24,
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          // ✅ SAFE: Expanded inside a Row is always valid
                          child: Text(
                            track,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 40),
          const Text(
            'TEAM DEV',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'LAUNCH by PATRICK ',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          const Text(
            'Systems Architect & Technical',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // RIGHT PANEL — Intake form (shared between layouts)
  // =========================================================================
  Widget _buildIntakeForm(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.01),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'METRIC INTENDED INTAKE',
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace'),
                ),
                if (_isTransmitting)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        color: accentColor, strokeWidth: 1.5),
                  )
              ],
            ),
            const SizedBox(height: 32),
            _buildContactField(
                label: "Lead Contact Name",
                controller: _nameController,
                focusNode: _nameFocus),
            _buildContactField(
                label: "Enterprise Entity / Company",
                controller: _companyController,
                focusNode: _companyFocus),
            _buildContactField(
                label: "Corporate Email Interface",
                controller: _emailController,
                focusNode: _emailFocus,
                isEmail: true),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.white10, height: 1),
            ),
            _buildContactField(
                label:
                "Primary Framework / Tech Stack (e.g. Node, AWS, Flutter)",
                controller: _techStackController,
                focusNode: _techStackFocus),
            _buildContactField(
                label: "Engineering Footprint / Team Size",
                controller: _teamSizeController,
                focusNode: _teamSizeFocus),
            _buildContactField(
                label: "Primary Operational Bottleneck or System Hurdle",
                controller: _bottleneckController,
                focusNode: _bottleneckFocus,
                maxLines: 4),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isTransmitting ? null : _submitTransmission,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: const Color(0xFF0A0B10),
                minimumSize: const Size(double.infinity, 54),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: const Text(
                'LOCK IN VERDICT ARCHIVE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // STANDALONE ESCAPE HATCH HEADER
  // =========================================================================
  Widget _buildStandaloneHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, color: const Color(0xFF00E5FF)),
              const SizedBox(width: 16),
              const Text(
                'UPLINK ESTABLISHED',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => context.push('/growth-engine'),
            icon: const Icon(Icons.arrow_back, color: Colors.white54, size: 14),
            label: const Text(
              'BACK',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // FIELD BUILDER
  // =========================================================================
  Widget _buildContactField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isEmail = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        onTapOutside: (pointerDownEvent) {
          _pageFocusNode.requestFocus();
        },
        onFieldSubmitted: (value) {
          _pageFocusNode.requestFocus();
        },
        validator: (v) {
          if (v == null || v.trim().isEmpty) return "PARAMETER STRICTLY REQUIRED";
          if (isEmail &&
              !RegExp(r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(v)) {
            return "INVALID COMMUNICATION INTERFACE FORMAT";
          }
          return null;
        },
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontFamily: 'monospace',
              letterSpacing: 0.5),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.01),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.zero),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00E5FF)),
              borderRadius: BorderRadius.zero),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.zero),
          focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.zero),
          errorStyle: const TextStyle(
              color: Colors.redAccent, fontSize: 9, fontFamily: 'monospace'),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}