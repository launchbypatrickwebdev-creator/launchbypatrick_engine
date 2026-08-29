// lib/widgets/connection_form.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ConnectionForm extends StatefulWidget {
  final Function(Map<String, dynamic> data) onInitialize;
  final String initialProtocol;
  final String? lockedProtocol;
  final VoidCallback? onLockedTabTap;

  // ADD: pageFocusNode received from parent page
  // Every field's onTapOutside and onSubmitted
  // calls pageFocusNode.requestFocus() — returns
  // focus to the neutral page-level node so
  // LaunchTactileEngine never loses its focus owner
  final FocusNode pageFocusNode;

  const ConnectionForm({
    super.key,
    required this.onInitialize,
    required this.pageFocusNode,
    this.initialProtocol = "Specialized Operative",
    this.lockedProtocol,
    this.onLockedTabTap,
  });

  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {

  // =========================================================================
  // CONFIG
  // =========================================================================
  static const String _formspreeEndpoint  = 'https://formspree.io/f/xpqjyydl';
  static const String _emailjsServiceId   = 'service_694gypk';
  static const String _emailjsPublicKey   = 'K3kTM-IwtSD5FFdPY';
  static const String _partnerTemplateId  = 'template_PARTNER_PROSPECTUS';
  static const String _operativeTemplateId = 'template_OPERATIVE_RECRUIT';

  // =========================================================================
  // STATE
  // =========================================================================
  late String _selectedProtocol;
  String _classification  = "Industrial Architect";
  String _investmentScale = "₦ 2M – ₦ 10M";
  String _readiness       = "Pilot Program";
  String _entityStructure = "LLC";
  bool   _isAuthorized    = false;
  bool   _isHardware      = false;
  String _seniorityLevel  = "L2";
  String _workMode        = "Hybrid";
  String _availability    = "Full-Sync";
  bool   _isSubmitting    = false;

  final List<String> _selectedStack = [];

  // ── Text controllers ──────────────────────────────────────────────────────
  final TextEditingController _nameController      = TextEditingController();
  final TextEditingController _emailController     = TextEditingController();
  final TextEditingController _locationController  = TextEditingController();
  final TextEditingController _visionController    = TextEditingController();
  final TextEditingController _loadController      = TextEditingController();
  final TextEditingController _darkCloudController = TextEditingController();
  final TextEditingController _timelineController  = TextEditingController();
  final TextEditingController _artifactController  = TextEditingController();
  final TextEditingController _timezoneController  = TextEditingController();
  final TextEditingController _customClassController        = TextEditingController();
  final TextEditingController _customReadinessController    = TextEditingController();
  final TextEditingController _customEntityController       = TextEditingController();
  final TextEditingController _customStackController        = TextEditingController();
  final TextEditingController _customAvailabilityController = TextEditingController();

  // ── FIX: isolated FocusNodes — only intercept horizontal arrows + space.
  // Do NOT intercept arrowUp/arrowDown — those belong to the scroll engine
  // for vertical page scrolling. This matches exactly what
  // growth_intakeform_page.dart does.
  late final FocusNode _nameFocus         = _makeIsolatedFocus();
  late final FocusNode _emailFocus        = _makeIsolatedFocus();
  late final FocusNode _locationFocus     = _makeIsolatedFocus();
  late final FocusNode _loadFocus         = _makeIsolatedFocus();
  late final FocusNode _timelineFocus     = _makeIsolatedFocus();
  late final FocusNode _artifactFocus     = _makeIsolatedFocus();
  late final FocusNode _timezoneFocus     = _makeIsolatedFocus();
  late final FocusNode _customClassFocus  = _makeIsolatedFocus();
  late final FocusNode _customReadFocus   = _makeIsolatedFocus();
  late final FocusNode _customEntityFocus = _makeIsolatedFocus();
  late final FocusNode _customStackFocus  = _makeIsolatedFocus();
  late final FocusNode _customAvailFocus  = _makeIsolatedFocus();

  // ── FIX: multiline fields use plain FocusNode — no key interceptor.
  // Multiline TextFields handle their own vertical cursor movement and
  // don't conflict with the scroll engine the way single-line fields do.
  late final FocusNode _visionFocus    = FocusNode();
  late final FocusNode _darkCloudFocus = FocusNode();

  // =========================================================================
  // DROPDOWN OPTIONS
  // =========================================================================
  static const List<String> _operativeOptions = [
    "KiCad PCB", "ESP32/C++", "Flutter/Dart",
    "Rust", "Cloud Infra", "Solar IoT",
    "Software Engineer", "OTHER...",
  ];
  static const List<String> _partnerOptions = [
    "Industrial IoT", "Logistics Auditing",
    "Asset Protection", "Solar Microgrids",
    "Regional Radio", "OTHER...",
  ];
  static const List<String> _investmentScaleOptions = [
    "₦ 500K – ₦ 2M       (SME / Single Asset)",
    "₦ 2M – ₦ 10M        (Mid-Scale Deployment)",
    "₦ 10M – ₦ 50M       (Enterprise / Fleet)",
    "₦ 50M – ₦ 200M      (Institutional / Multi-Site)",
    "₦ 200M+              (Strategic / National Scale)",
    "Prefer not to disclose",
  ];

  // =========================================================================
  // INIT / DISPOSE
  // =========================================================================

  @override
  void initState() {
    super.initState();
    _selectedProtocol = widget.initialProtocol;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _visionController.dispose();
    _loadController.dispose();
    _darkCloudController.dispose();
    _timelineController.dispose();
    _artifactController.dispose();
    _timezoneController.dispose();
    _customClassController.dispose();
    _customReadinessController.dispose();
    _customEntityController.dispose();
    _customStackController.dispose();
    _customAvailabilityController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _locationFocus.dispose();
    _visionFocus.dispose();
    _loadFocus.dispose();
    _darkCloudFocus.dispose();
    _timelineFocus.dispose();
    _artifactFocus.dispose();
    _timezoneFocus.dispose();
    _customClassFocus.dispose();
    _customReadFocus.dispose();
    _customEntityFocus.dispose();
    _customStackFocus.dispose();
    _customAvailFocus.dispose();
    super.dispose();
  }

  // =========================================================================
  // FIX: isolated focus factory — horizontal arrows + space ONLY
  // Matches growth_intakeform_page.dart _createIsolatedFocusNode() exactly
  // =========================================================================
  FocusNode _makeIsolatedFocus() {
    return FocusNode(
      onKeyEvent: (node, event) {
        final bool isHorizontalArrow =
            event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowRight;
        final bool isSpace =
            event.logicalKey == LogicalKeyboardKey.space;
        if (isHorizontalArrow || isSpace) {
          return KeyEventResult.skipRemainingHandlers;
        }
        return KeyEventResult.ignored;
      },
    );
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  bool get isPartner => _selectedProtocol == "Mission Partner";

  Color get _accentColor => isPartner
      ? const Color(0xFFFFD700)
      : const Color(0xFF00C853);

  bool _isLocked(String protocol) =>
      widget.lockedProtocol != null &&
          protocol != widget.lockedProtocol;

  void _handleLockedTabTap() {
    if (widget.onLockedTabTap != null) widget.onLockedTabTap!();
  }

  String _resolveOther(String current, TextEditingController ctrl) =>
      current == "OTHER..." ? ctrl.text.trim() : current;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text(message,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    ));
  }

  // =========================================================================
  // SUBMISSION
  // =========================================================================

  Future<void> _initializeUplink() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      _showError("CRITICAL ERROR: IDENTIFICATION & EMAIL REQUIRED");
      return;
    }
    setState(() => _isSubmitting = true);

    final Map<String, dynamic> payload = {
      "Form_Type": isPartner
          ? "Sentinel — Mission Partner"
          : "Sentinel — Specialized Operative",
      "Protocol":  _selectedProtocol,
      "Name":      _nameController.text.trim(),
      "Email":     _emailController.text.trim(),
      "Location":  _locationController.text.trim(),
      "Timestamp": DateTime.now().toIso8601String(),
      "Status":    "pending_verification",
    };

    if (isPartner) {
      payload.addAll({
        "Classification":      _resolveOther(_classification, _customClassController),
        "Investment_Scale":    _investmentScale,
        "Infrastructure_Load": _loadController.text.trim(),
        "Deployment_Window":   _timelineController.text.trim(),
        "Dark_Clouds":         _darkCloudController.text.trim(),
        "Readiness":           _resolveOther(_readiness, _customReadinessController),
        "Entity_Structure":    _resolveOther(_entityStructure, _customEntityController),
        "Is_Authorized_Signatory": _isAuthorized.toString(),
        "Strategic_Vision":    _visionController.text.trim(),
      });
    } else {
      List<String> finalStack = List.from(_selectedStack);
      if (finalStack.contains("OTHER...")) {
        finalStack.remove("OTHER...");
        if (_customStackController.text.isNotEmpty) {
          finalStack.add(_customStackController.text.trim());
        }
      }
      payload.addAll({
        "Hardware_Focus":   _isHardware.toString(),
        "Seniority_Level":  _seniorityLevel,
        "Technical_Stack":  finalStack.join(", "),
        "Work_Mode":        _workMode,
        "Availability":     _resolveOther(_availability, _customAvailabilityController),
        "Timezone":         _timezoneController.text.trim(),
        "Artifact_Link":    _artifactController.text.trim(),
        "Vision_Statement": _visionController.text.trim(),
      });
    }

    await Future.wait([
      _postToFormspree(payload),
      _sendEmailjsReply(payload),
    ]);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: const Color(0xFF00C853),
      duration: const Duration(seconds: 3),
      content: Text("CONNECTION INITIALIZED — CHECK YOUR INBOX.",
          style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    ));
    widget.onInitialize(payload);
  }

  Future<void> _postToFormspree(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(_formspreeEndpoint),
        headers: {"Accept": "application/json"},
        body: payload.map((k, v) => MapEntry(k, v.toString())),
      );
      if (response.statusCode != 200) {
        debugPrint("⚠️ FORMSPREE: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ FORMSPREE ERROR: $e");
    }
  }

  Future<void> _sendEmailjsReply(Map<String, dynamic> payload) async {
    final String templateId =
    isPartner ? _partnerTemplateId : _operativeTemplateId;
    try {
      await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id':  _emailjsServiceId,
          'template_id': templateId,
          'user_id':     _emailjsPublicKey,
          'template_params': {
            'user_name':      payload['Name'],
            'user_email':     payload['Email'],
            'subject_line':   isPartner
                ? "PARTNERSHIP_PROSPECTUS: ${payload['Classification'] ?? ''}"
                : "OPERATIVE_UPLINK: ${payload['Name']}",
            'sector_details': isPartner
                ? "Scale: ${payload['Investment_Scale']} | Readiness: ${payload['Readiness']}"
                : "Stack: ${payload['Technical_Stack']} | Seniority: ${payload['Seniority_Level']}",
            'pain_points': isPartner
                ? payload['Dark_Clouds']
                : payload['Vision_Statement'],
          },
        }),
      );
    } catch (e) {
      debugPrint("⚠️ EMAILJS ERROR: $e");
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("01. IDENTITY & COORDINATES"),
        const SizedBox(height: 15),
        _buildProtocolToggle(),
        const SizedBox(height: 25),
        _buildTextField("IDENTIFY YOUR PROTOCOL",
            "Full Name / Alias",
            _nameController, _nameFocus),
        const SizedBox(height: 25),
        _buildTextField("COMMUNICATION UPLINK",
            "Valid Email Address",
            _emailController, _emailFocus),
        const SizedBox(height: 25),
        _buildTextField("CURRENT SECTOR COORDINATES",
            "Location (e.g. Lagos, Remote)",
            _locationController, _locationFocus),
        const SizedBox(height: 40),
        if (isPartner) ..._buildPartnerFields()
        else            ..._buildOperativeFields(),
        const SizedBox(height: 30),
        _buildTextField(
          isPartner ? "THE STRATEGIC VISION" : "THE VISION STATEMENT",
          isPartner
              ? "How should we align to secure your specific corridor?"
              : "In 50 words, how do we stop the 'Black Cloud'?",
          _visionController,
          _visionFocus,    // plain FocusNode — multiline field
          maxLines: 3,
        ),
        const SizedBox(height: 40),
        _buildSubmitButton(),
      ],
    );
  }

  // =========================================================================
  // PROTOCOL TOGGLE
  // =========================================================================
  Widget _buildProtocolToggle() {
    final List<String> protocols = [
      "Specialized Operative",
      "Mission Partner",
    ];
    return Row(
      children: protocols.map((protocol) {
        final bool isSelected = _selectedProtocol == protocol;
        final bool isLocked   = _isLocked(protocol);
        final Color typeAccent = protocol == "Mission Partner"
            ? const Color(0xFFFFD700)
            : const Color(0xFF00C853);

        return Expanded(
          child: GestureDetector(
            onTap: isLocked
                ? _handleLockedTabTap
                : () => setState(() => _selectedProtocol = protocol),
            child: Tooltip(
              message: isLocked
                  ? 'Go to ${protocol == "Mission Partner" ? "Deploy" : "Build"} section'
                  : '',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? typeAccent.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isLocked
                        ? Colors.white10
                        : isSelected
                        ? typeAccent
                        : Colors.white10,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: isLocked ? 0.3 : 1.0,
                      child: Text(
                        protocol.toUpperCase(),
                        style: GoogleFonts.robotoMono(
                          color: isSelected ? typeAccent : Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isLocked)
                      Positioned(
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_forward,
                                color: Colors.white24, size: 10),
                            const SizedBox(width: 2),
                            Icon(Icons.lock_outline,
                                color: Colors.white24, size: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // =========================================================================
  // PARTNER FIELDS
  // =========================================================================
  List<Widget> _buildPartnerFields() {
    return [
      _buildSectionLabel("02. ARCHITECTURAL CLASSIFICATION"),
      const SizedBox(height: 15),
      _buildSimpleDropdown(
        ["Industrial Architect", "Educational Architect",
          "Financial Architect", "Strategic Partner", "OTHER..."],
        _classification,
            (val) => setState(() => _classification = val!),
      ),
      if (_classification == "OTHER...") ...[
        const SizedBox(height: 10),
        _buildTextField("SPECIFY CLASSIFICATION",
            "Enter your sector",
            _customClassController, _customClassFocus),
      ],
      const SizedBox(height: 25),
      _buildSectionLabel("PROJECTED INVESTMENT SCALE"),
      const SizedBox(height: 6),
      Text("Select the band that best describes your deployment budget.",
          style: TextStyle(
              color: Colors.white38, fontSize: 10, height: 1.4)),
      const SizedBox(height: 12),
      _buildSimpleDropdown(
        _investmentScaleOptions, _investmentScale,
            (val) => setState(() => _investmentScale = val!),
      ),
      const SizedBox(height: 25),
      _buildTextField("INFRASTRUCTURE LOAD",
          "Assets/sites (e.g. 50+ Enterprise generators)",
          _loadController, _loadFocus),
      const SizedBox(height: 25),
      _buildTextField("DEPLOYMENT WINDOW",
          "e.g. Q3 2025 – Q1 2026",
          _timelineController, _timelineFocus),
      const SizedBox(height: 25),
      // FIX: Dark Clouds is multiline — plain FocusNode, no key interceptor
      _buildTextField("REGIONAL DARK CLOUDS",
          "Identify primary hurdles (e.g. Diesel theft, manual logging)",
          _darkCloudController, _darkCloudFocus,
          maxLines: 2),
      const SizedBox(height: 25),
      _buildSectionLabel("03. READINESS PROTOCOL"),
      const SizedBox(height: 15),
      _buildSimpleDropdown(
        ["Pilot Program", "Full-Scale Audit",
          "Investor Briefing", "OTHER..."],
        _readiness,
            (val) => setState(() => _readiness = val!),
      ),
      if (_readiness == "OTHER...") ...[
        const SizedBox(height: 10),
        _buildTextField("SPECIFY READINESS",
            "e.g. Research Phase",
            _customReadinessController, _customReadFocus),
      ],
      const SizedBox(height: 25),
      _buildSectionLabel("LEGAL & COMPLIANCE"),
      const SizedBox(height: 15),
      _buildSimpleDropdown(
        ["LLC", "Corporation", "Sole Proprietorship",
          "Government / NGO", "OTHER..."],
        _entityStructure,
            (val) => setState(() => _entityStructure = val!),
      ),
      if (_entityStructure == "OTHER...") ...[
        const SizedBox(height: 10),
        _buildTextField("SPECIFY ENTITY",
            "Enter legal structure",
            _customEntityController, _customEntityFocus),
      ],
      const SizedBox(height: 16),
      CheckboxListTile(
        title: Text("AUTHORIZED SIGNATORY",
            style: GoogleFonts.robotoMono(
                color: Colors.white, fontSize: 10)),
        subtitle: Text(
            "I have authority to execute agreements on behalf of my organization.",
            style: TextStyle(color: Colors.white38, fontSize: 9)),
        value: _isAuthorized,
        activeColor: _accentColor,
        onChanged: (val) => setState(() => _isAuthorized = val!),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    ];
  }

  // =========================================================================
  // OPERATIVE FIELDS
  // =========================================================================
  List<Widget> _buildOperativeFields() {
    return [
      _buildSectionLabel("02. OPERATIONAL PARAMETERS"),
      const SizedBox(height: 10),
      SwitchListTile(
        title: Text("HARDWARE FOCUS",
            style: GoogleFonts.robotoMono(
                color: Colors.white, fontSize: 12)),
        subtitle: Text(
            "Enable if submitting .kicad_pcb files or hardware schematics.",
            style: TextStyle(color: Colors.white38, fontSize: 10)),
        value: _isHardware,
        activeTrackColor: _accentColor,
        activeThumbColor: Colors.black,
        onChanged: (val) => setState(() => _isHardware = val),
      ),
      const SizedBox(height: 25),
      _buildSectionLabel("CLEARANCE / SENIORITY"),
      const SizedBox(height: 15),
      _buildSegmentedControl(
        segments: const [
          ButtonSegment(value: "L1", label: Text("JUNIOR")),
          ButtonSegment(value: "L2", label: Text("MID")),
          ButtonSegment(value: "L3", label: Text("SENIOR")),
        ],
        selected: _seniorityLevel,
        onChanged: (val) => setState(() => _seniorityLevel = val),
      ),
      const SizedBox(height: 25),
      _buildStackChips(),
      if (_selectedStack.contains("OTHER...")) ...[
        const SizedBox(height: 10),
        _buildTextField("SPECIFY SKILLS",
            "e.g. Zigbee, LoRaWAN, Python",
            _customStackController, _customStackFocus),
      ],
      const SizedBox(height: 25),
      _buildSectionLabel("03. LOGISTICS & AVAILABILITY"),
      const SizedBox(height: 15),
      _buildSegmentedControl(
        segments: const [
          ButtonSegment(value: "Remote",  label: Text("REMOTE")),
          ButtonSegment(value: "Hybrid",  label: Text("HYBRID")),
          ButtonSegment(value: "On-Site", label: Text("LOCAL")),
        ],
        selected: _workMode,
        onChanged: (val) => setState(() => _workMode = val),
      ),
      const SizedBox(height: 20),
      _buildTextField("TIME ZONE",
          "Current offset (e.g. UTC+1)",
          _timezoneController, _timezoneFocus),
      const SizedBox(height: 25),
      _buildAvailabilityDropdown(),
      if (_availability == "OTHER...") ...[
        const SizedBox(height: 10),
        _buildTextField("SPECIFY AVAILABILITY",
            "e.g. Project-based only",
            _customAvailabilityController, _customAvailFocus),
      ],
      const SizedBox(height: 25),
      _buildTextField("ARTIFACT UPLINK",
          "Link to GitHub, Behance, or .kicad_pcb file",
          _artifactController, _artifactFocus),
    ];
  }

  // =========================================================================
  // COMPONENT BUILDERS
  // =========================================================================

  Widget _buildStackChips() {
    final String label =
    isPartner ? "INFRASTRUCTURE DOMAINS" : "TECHNICAL STACK";
    final List<String> options =
    isPartner ? _partnerOptions : _operativeOptions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((skill) {
            final bool isSelected = _selectedStack.contains(skill);
            return FilterChip(
              label: Text(skill,
                  style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      color: isSelected ? Colors.black : Colors.white)),
              selected: isSelected,
              onSelected: (val) => setState(() => val
                  ? _selectedStack.add(skill)
                  : _selectedStack.remove(skill)),
              selectedColor: _accentColor,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              checkmarkColor: Colors.black,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl({
    required List<ButtonSegment<String>> segments,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: _accentColor,
          selectedForegroundColor: Colors.black,
          side: const BorderSide(color: Colors.white10),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero),
        ),
        segments: segments,
        selected: {selected},
        onSelectionChanged: (set) => onChanged(set.first),
      ),
    );
  }

  Widget _buildAvailabilityDropdown() {
    final List<String> partnerItems = [
      "Direct Investment", "Strategic Partnership",
      "Regional Deployment", "OTHER...",
    ];
    final List<String> operativeItems = [
      "Full-Sync", "Part-Sync",
      "Hybrid-Sync (Ibadan)", "OTHER...",
    ];
    final List<String> items =
    isPartner ? partnerItems : operativeItems;
    if (!items.contains(_availability)) _availability = items.first;
    return _buildSimpleDropdown(
        items, _availability,
            (val) => setState(() => _availability = val!));
  }

  Widget _buildSimpleDropdown(
      List<String> items,
      String currentVal,
      Function(String?) onChanged,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          dropdownColor: const Color(0xFF0A0B10),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: _accentColor),
          style: GoogleFonts.robotoMono(
              color: Colors.white, fontSize: 12),
          items: items
              .map((val) => DropdownMenuItem(
            value: val,
            child: Text(val, overflow: TextOverflow.ellipsis),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // FIX: every TextField calls widget.pageFocusNode.requestFocus()
  // on both onTapOutside and onSubmitted — same pattern as
  // growth_intakeform_page.dart which uses _pageFocusNode.requestFocus()
  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller,
      FocusNode focusNode, {
        int maxLines = 1,
        TextInputAction action = TextInputAction.next,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.robotoMono(
                color: Colors.white38,
                fontSize: 9,
                letterSpacing: 2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          textInputAction: action,
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 14),
          // FIX: redirect to pageFocusNode — not unfocus() into void
          onTapOutside: (_) =>
              widget.pageFocusNode.requestFocus(),
          onSubmitted: (_) =>
              widget.pageFocusNode.requestFocus(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Colors.white10, fontSize: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white10),
                borderRadius: BorderRadius.zero),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _accentColor),
                borderRadius: BorderRadius.zero),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: GoogleFonts.robotoMono(
            color: _accentColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2));
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _initializeUplink,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          disabledBackgroundColor:
          _accentColor.withValues(alpha: 0.4),
          foregroundColor: Colors.black,
          disabledForegroundColor: Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
                color: Colors.black, strokeWidth: 2))
            : Text("EXECUTE CONNECTION",
            style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 13)),
      ),
    );
  }
}