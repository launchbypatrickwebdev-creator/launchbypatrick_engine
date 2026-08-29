import 'dart:convert'; // Added for microservice JSON handshake serialization
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../shared/ops_background_engine.dart';
import '../shared/launch_tactile_engine.dart';
import '../shared/launch_section_container.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/shared_site_footer.dart';

// =========================================================================
// 1. ARCHITECTURAL VECTOR CONFIGURATION MODEL
// =========================================================================
class TechnicalSector {
  final String title;
  final Color themeColor;
  final String description;
  final String metricLabel1;
  final String metricLabel2;
  final double maxInput1;
  final double maxInput2;
  final String unit1;
  final String unit2;
  final double Function(double, double) computeLoss;
  final String Function(double) getSymptom1;
  final String Function(double) getSymptom2;

  const TechnicalSector({
    required this.title,
    required this.themeColor,
    required this.description,
    required this.metricLabel1,
    required this.metricLabel2,
    required this.maxInput1,
    required this.maxInput2,
    required this.unit1,
    required this.unit2,
    required this.computeLoss,
    required this.getSymptom1,
    required this.getSymptom2,
  });
}

class GrowthEnginePage extends StatefulWidget {
  const GrowthEnginePage({super.key});

  // =========================================================================
  // 🛰️ ENTERPRISE SYSTEM CONFIGURATION LAYER
  // =========================================================================
  static const double qualificationThreshold = 5000.0;

  @override
  State<GrowthEnginePage> createState() => _GrowthEnginePageState();
}

class _GrowthEnginePageState extends State<GrowthEnginePage> {
  int _selectedSectorIndex = 0;

  double _value1 = 5000;
  double _value2 = 250;

  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late FocusNode _focusNode1;
  late FocusNode _focusNode2;
  late FocusNode _pageFocusNode;

  bool _isInitialized = false;
  bool _hasCapturedLead = false;

  // =========================================================================
  // 2. THE ARCHITECTURAL LEAKAGE SECTORS
  // =========================================================================
  final List<TechnicalSector> _sectors = [
    TechnicalSector(
      title: 'INFRASTRUCTURE PROVISIONING & COMPUTE',
      themeColor: const Color(0xFF00E5FF),
      description: 'Audits financial leakage from over-provisioned cloud instances, missing autoscaling configurations, and unoptimized database threads running idle capacity.',
      metricLabel1: 'Monthly Cloud Infrastructure Spend',
      metricLabel2: 'Estimated Idle/Unoptimized Capacity',
      maxInput1: 50000,
      maxInput2: 100,
      unit1: '\$',
      unit2: '%',
      computeLoss: (spend, idle) => spend * (idle / 100),
      getSymptom1: (val) => val > 20000 ? 'Enterprise tier infra footprint.' : 'Standard mid-market cloud volume.',
      getSymptom2: (val) {
        if (val <= 20) return 'OPERATIONAL REALITY: Optimized baseline. Standard fallback redundancy headroom.';
        if (val <= 50) return 'OPERATIONAL REALITY: Fixed-size cloud instances. Paying for maximum peak performance 24/7 even during low-traffic night cycles.';
        return 'OPERATIONAL REALITY: Severe wastage. Ghost staging environments active, unindexed heavy queries causing CPU spikes, and complete lack of elastic autoscaling architecture.';
      },
    ),
    TechnicalSector(
      title: 'LATENCY DEGRADATION & VITAL CHURN',
      themeColor: const Color(0xFFFF3D00),
      description: 'Calculates user bounce rate drop-off and conversion bleeding caused by sub-optimal server response times and blocking rendering main threads.',
      metricLabel1: 'Average Monthly Digital Revenue',
      metricLabel2: 'Latency Delay beyond 200ms Baseline',
      maxInput1: 100000,
      maxInput2: 2000,
      unit1: '\$',
      unit2: 'ms',
      computeLoss: (revenue, ms) => revenue * ((ms / 100) * 0.01),
      getSymptom1: (val) => 'Baseline transaction flow metric.',
      getSymptom2: (val) {
        if (val <= 300) return 'OPERATIONAL REALITY: Snappy processing. User acquisition retention is unhindered.';
        if (val <= 800) return 'OPERATIONAL REALITY: Noticeable lag. Mobile layout stuttering. Expect an immediate 7% to 15% drop-off at payment checkouts.';
        return 'OPERATIONAL REALITY: Critical network bottleneck. Heavy database round-trips or missing edge server distribution. Users assume app/site is broken and abandon entirely.';
      },
    ),
    TechnicalSector(
      title: 'ENGINEERING VELOCITY & TECH DEBT',
      themeColor: const Color(0xFFFFEA00),
      description: 'Measures payroll capital burned on process theater, regression handling, and resolving modular dependency breaks inside legacy architectures.',
      metricLabel1: 'Monthly Developer Payroll Overhead',
      metricLabel2: 'Time Lost to Legacy Technical Debt',
      maxInput1: 40000,
      maxInput2: 100,
      unit1: '\$',
      unit2: '%',
      computeLoss: (payroll, debt) => payroll * (debt / 100),
      getSymptom1: (val) => 'Total operational cost of internal engineering department.',
      getSymptom2: (val) {
        if (val <= 15) return 'OPERATIONAL REALITY: High velocity. Codebase is clean; new modules or features deploy to production in less than 72 hours.';
        if (val <= 45) return 'OPERATIONAL REALITY: Codebase friction. Onboarding new engineers takes weeks. Modifying a feature triggers unexpected breaks in unrelated modules.';
        return 'OPERATIONAL REALITY: Architectural Gridlock. Developers spend 80% of their billing hours writing regression fixes and patching bugs rather than shipping growth features.';
      },
    ),
    TechnicalSector(
      title: 'SYSTEMIC FAULT TOLERANCE EXPOSURE',
      themeColor: const Color(0xFFFF1744),
      description: 'Projects potential revenue drops and systemic exposure costs caused by single points of failure and missing edge redundancy layers.',
      metricLabel1: 'Average System Value Generated Per Hour',
      metricLabel2: 'Expected Annual Unscheduled Downtime',
      maxInput1: 10000,
      maxInput2: 48,
      unit1: '\$',
      unit2: 'hrs',
      computeLoss: (valPerHour, hours) => valPerHour * hours,
      getSymptom1: (val) => 'Hourly cost of software/web core functions remaining offline.',
      getSymptom2: (val) {
        if (val <= 2) return 'OPERATIONAL REALITY: High availability architecture. Redundancy systems capture runtime crashes gracefully.';
        if (val <= 12) return 'OPERATIONAL REALITY: Vulnerable system setup. Single points of failure exist. Database server crashes take hours to manually restore from backups.';
        return 'OPERATIONAL REALITY: High-risk operational exposure. Complete lack of multi-region replication. A single host outage results in multi-day operational blackouts.';
      },
    ),
    TechnicalSector(
      title: 'THIRD-PARTY PAYLOAD OVER-BILLING',
      themeColor: const Color(0xFFD500F9),
      description: 'Tracks capital wasted on redundant external API synchronizations and webhooks that lack clean local caching grids.',
      metricLabel1: 'Monthly External API Operational Bill',
      metricLabel2: 'Redundant Cachable Requests Fetch Rate',
      maxInput1: 15000,
      maxInput2: 100,
      unit1: '\$',
      unit2: '%',
      computeLoss: (apiBill, redundancy) => apiBill * (redundancy / 100),
      getSymptom1: (val) => 'Aggregated cost of database connections, search APIs, or map tools.',
      getSymptom2: (val) {
        if (val <= 20) return 'OPERATIONAL REALITY: Smart caching layer active. Re-fetching identical static states from servers is highly minimized.';
        if (val <= 50) return 'OPERATIONAL REALITY: Missing local database states. App calls external APIs for raw lists repeatedly instead of syncing delta changes.';
        return 'OPERATIONAL REALITY: Data bleeding. Every single screen reload or minor user tap forces a fresh billing payload from third-party networks.';
      },
    ),
    TechnicalSector(
      title: 'CLIENT-SIDE BLOAT & NETWORK CHURN',
      themeColor: const Color(0xFF00E676),
      description: 'Calculates user acquisition churn and app drop-off rates on mid-range devices due to uncompressed script bundle weights.',
      metricLabel1: 'Monthly Marketing Acquisition Spend',
      metricLabel2: 'Initial Client Payload Bundle Weight',
      maxInput1: 20000,
      maxInput2: 20,
      unit1: '\$',
      unit2: 'MB',
      computeLoss: (adSpend, mb) => mb > 5 ? adSpend * ((mb - 5) * 0.08) : 0,
      getSymptom1: (val) => 'Capital allocated to drive user traffic to the core page interface.',
      getSymptom2: (val) {
        if (val <= 4) return 'OPERATIONAL REALITY: Lean delivery asset. Loads instantaneously even on legacy 3G network bands and entry-level mobile devices.';
        if (val <= 10) return 'OPERATIONAL REALITY: Suboptimal weight. Bundling unoptimized assets or unminified libraries. Users on cellular connections experience visual freezing.';
        return 'OPERATIONAL REALITY: Catastrophic client payload size. Ad traffic clicks are entirely wasted because the interface takes over 6 seconds to execute on mid-range hardware.';
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageFocusNode = FocusNode();
    _focusNode1 = _createIsolatedFocusNode();
    _focusNode2 = _createIsolatedFocusNode();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _resetInputsForSector(0);
      _isInitialized = true;
    }
  }

  void _resetInputsForSector(int index) {
    final sector = _sectors[index];
    _value1 = sector.maxInput1 * 0.25;
    _value2 = sector.maxInput2 * 0.40;

    // 🛰️ FIX: Prevent Orphaned Resource Memory Leaks
    if (_isInitialized) {
      _controller1.text = _value1.toStringAsFixed(0);
      _controller2.text = _value2.toStringAsFixed(0);
    } else {
      _controller1 = TextEditingController(text: _value1.toStringAsFixed(0));
      _controller2 = TextEditingController(text: _value2.toStringAsFixed(0));
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _focusNode1.dispose();   // Dispose new nodes
    _focusNode2.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  // Triggered to capture the lead initially
  void _triggerExportModal(double monthlyLoss) {
    final currentSector = _sectors[_selectedSectorIndex];
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _DiagnosticExportModal(
          sectorTitle: currentSector.title,
          themeColor: currentSector.themeColor,
          metricLabel1: currentSector.metricLabel1,
          metricLabel2: currentSector.metricLabel2,
          unit1: currentSector.unit1,
          unit2: currentSector.unit2,
          value1: _value1,
          value2: _value2,
          calculatedMonthlyLoss: monthlyLoss,
          calculatedAnnualLoss: monthlyLoss * 12,
          onSuccess: () {
            setState(() {
              _hasCapturedLead = true; // Unlock phase 2 routing configurations
            });
          },
        );
      },
    );
  }

  Future<void> _refreshProtocol(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (context.mounted) {
      setState(() {
        _resetInputsForSector(_selectedSectorIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSector = _sectors[_selectedSectorIndex];
    final double calculatedMonthlyLoss = currentSector.computeLoss(_value1, _value2);
    final double calculatedAnnualLoss = calculatedMonthlyLoss * 12;
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      body: Stack(
        children: [
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/videos/growth-engine.mp4',
            ),
          ),
          LaunchTactileEngine(
            focusNode: _pageFocusNode,
            onRefresh: () => _refreshProtocol(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopNavBar(),
                LaunchSectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'SYSTEM LEAKAGE DIAGNOSTIC.',
                        style: TextStyle(fontSize: isMobile ? 32 : 56, fontWeight: FontWeight.bold, color: currentSector.themeColor, letterSpacing: 2.0, height: 1.1),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Text(
                          'Isolate, metricize, and neutralize infrastructural leakages bleeding performance efficiency and enterprise operating capital.',
                          style: TextStyle(color: Colors.white60, fontSize: isMobile ? 14 : 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                LaunchSectionContainer(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(_sectors.length, (index) {
                      final active = _selectedSectorIndex == index;
                      return OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedSectorIndex = index;
                            _resetInputsForSector(index);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: active ? _sectors[index].themeColor : Colors.white10, width: 1.5),
                          backgroundColor: active ? _sectors[index].themeColor.withValues(alpha: 0.05) : Colors.transparent,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        child: Text(
                          'TRACK 0${index + 1}',
                          style: TextStyle(color: active ? _sectors[index].themeColor : Colors.white38, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 40),
                LaunchSectionContainer(
                  child: Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isMobile ? 0 : 6,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0B10).withValues(alpha: 0.7),
                            border: Border.all(color: currentSector.themeColor.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentSector.title, style: TextStyle(color: currentSector.themeColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              const SizedBox(height: 12),
                              Text(currentSector.description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                              const SizedBox(height: 40),

                              // 🛰️ UPDATED SLIDER/TEXT SYNC - BUG FIXED
                              _buildSynchronizedInputFrame(
                                label: currentSector.metricLabel1,
                                value: _value1,
                                max: currentSector.maxInput1,
                                unit: currentSector.unit1,
                                controller: _controller1,
                                focusNode: _focusNode1,
                                symptomText: currentSector.getSymptom1(_value1),
                                onSliderChanged: (val) {
                                  setState(() {
                                    _value1 = val;
                                    _controller1.text = val.toStringAsFixed(0);
                                  });
                                },
                                onTextChanged: (text) {
                                  final parsed = double.tryParse(text) ?? 0.0;
                                  if (parsed <= currentSector.maxInput1) {
                                    setState(() => _value1 = parsed);
                                  }
                                },
                              ),

                              const SizedBox(height: 40),

                              // 🛰️ UPDATED SLIDER/TEXT SYNC - BUG FIXED
                              _buildSynchronizedInputFrame(
                                label: currentSector.metricLabel2,
                                value: _value2,
                                max: currentSector.maxInput2,
                                unit: currentSector.unit2,
                                controller: _controller2,
                                focusNode: _focusNode2,
                                symptomText: currentSector.getSymptom2(_value2),
                                onSliderChanged: (val) {
                                  setState(() {
                                    _value2 = val;
                                    _controller2.text = val.toStringAsFixed(0);
                                  });
                                },
                                onTextChanged: (text) {
                                  final parsed = double.tryParse(text) ?? 0.0;
                                  if (parsed <= currentSector.maxInput2) {
                                    setState(() => _value2 = parsed);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isMobile) const SizedBox(width: 40),
                      if (isMobile) const SizedBox(height: 40),
                      Expanded(
                        flex: isMobile ? 0 : 4,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: currentSector.themeColor.withValues(alpha: 0.02),
                            border: Border.all(color: currentSector.themeColor.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('LEAKAGE DIAGNOSTIC OUTPUT', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const SizedBox(height: 40),
                              const Text('MONTHLY ESCAPE CAPITAL', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.0)),
                              const SizedBox(height: 4),
                              Text('\$${calculatedMonthlyLoss.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 32),
                              const Text('PROJECTED ANNUAL LOSS', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.0)),
                              const SizedBox(height: 4),
                              Text('\$${calculatedAnnualLoss.toStringAsFixed(0)}', style: TextStyle(color: currentSector.themeColor, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -1)),
                              const SizedBox(height: 40),

                              // 🛰️ DYNAMIC CTA RENDERING LOGIC
                              _buildDynamicCTA(calculatedMonthlyLoss, calculatedAnnualLoss, currentSector.themeColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

  // 🛰️ DECOUPLED FUNNEL: DYNAMIC BUTTON LOGIC USING THE ISOLATED CONSTANT THRESHOLD
  Widget _buildDynamicCTA(double monthlyLoss, double annualLoss, Color themeColor) {
    if (!_hasCapturedLead) {
      // Phase 1: Not captured yet. Button triggers information capture gate.
      return ElevatedButton(
        onPressed: () => _triggerExportModal(monthlyLoss),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: const Color(0xFF0A0B10),
          minimumSize: const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: const Text('EXPORT SYSTEM DIAGNOSTICS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 12)),
      );
    }

    // Phase 2 Check: Uses class-level decoupled threshold evaluation engine
    if (annualLoss >= GrowthEnginePage.qualificationThreshold) {
      // Lead captured AND qualified high-value pipeline target. Unlock specialized intake pathway.
      return ElevatedButton(
        onPressed: () => context.push('/growth_intakeform'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: themeColor,
          minimumSize: const Size(double.infinity, 54),
          side: BorderSide(color: themeColor, width: 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: const Text('INITIALIZE DIRECT ARCHITECT ENGAGEMENT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 11)),
      );
    }

    // Phase 2 Alternative: Lead captured BUT filters as non-enterprise tier. Display successful lock notice.
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
        disabledForegroundColor: Colors.greenAccent,
        minimumSize: const Size(double.infinity, 54),
        side: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.3)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: const Text('REPORT DISPATCHED TO INBOX', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 11)),
    );
  }

  Widget _buildSynchronizedInputFrame({
    required String label,
    required double value,
    required double max,
    required String unit,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String symptomText,
    required ValueChanged<double> onSliderChanged,
    required ValueChanged<String> onTextChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 8,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _sectors[_selectedSectorIndex].themeColor,
                  inactiveTrackColor: Colors.white10,
                  thumbColor: _sectors[_selectedSectorIndex].themeColor,
                  thumbShape: const SquareSliderThumbShape(),
                  trackHeight: 2,
                ),
                child: Slider(
                  value: value.clamp(0.0, max),
                  min: 0.0,
                  max: max,
                  onChanged: onSliderChanged,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
                  onChanged: onTextChanged,
                  // 🛰️ FIXED: _pageFocusNode is now the exact FocusNode
                  // LaunchTactileEngine uses for CallbackShortcuts, so
                  // reclaiming it here actually restores page arrow-key
                  // scrolling (unlike the previous unfocus()-into-the-void,
                  // which permanently killed scrolling after first use,
                  // or the original version, which pointed at a dead node).
                  onTapOutside: (pointerDownEvent) {
                    _pageFocusNode.requestFocus();
                  },
                  onSubmitted: (text) {
                    _pageFocusNode.requestFocus();
                  },
                  decoration: InputDecoration(
                    suffixText: unit,
                    suffixStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10), borderRadius: BorderRadius.zero),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _sectors[_selectedSectorIndex].themeColor), borderRadius: BorderRadius.zero),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Text(
            symptomText,
            key: ValueKey(symptomText),
            style: TextStyle(
              color: _sectors[_selectedSectorIndex].themeColor.withValues(alpha: 0.85),
              fontFamily: 'monospace',
              fontSize: 11,
              height: 1.4,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

class SquareSliderThumbShape extends SliderComponentShape {
  const SquareSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isPressed) => const Size(12, 12);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;
    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(center: center, width: 12, height: 12),
      fillPaint,
    );
  }
}

// =========================================================================
// 3. ENHANCED DIAGNOSTIC EXPORT MODAL (MICROSERVICE ENGINE DATA HANDSHAKE)
// =========================================================================
class _DiagnosticExportModal extends StatefulWidget {
  final String sectorTitle;
  final Color themeColor;
  final String metricLabel1;
  final String metricLabel2;
  final String unit1;
  final String unit2;
  final double value1;
  final double value2;
  final double calculatedMonthlyLoss;
  final double calculatedAnnualLoss;
  final VoidCallback onSuccess;

  const _DiagnosticExportModal({
    required this.sectorTitle,
    required this.themeColor,
    required this.metricLabel1,
    required this.metricLabel2,
    required this.unit1,
    required this.unit2,
    required this.value1,
    required this.value2,
    required this.calculatedMonthlyLoss,
    required this.calculatedAnnualLoss,
    required this.onSuccess,
  });

  @override
  State<_DiagnosticExportModal> createState() => _DiagnosticExportModalState();
}

class _DiagnosticExportModalState extends State<_DiagnosticExportModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isTransmitting = false;
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _companyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _executeCapture() async {
    // 🛰️ MODAL FOCUS FIX: Instantly drop the text input cursor focus when clicking the dispatch button
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isTransmitting = true);

    // 🛰️ PHASE 1: STRUCTURAL HANDSHAKE PAYLOAD ASSEMBLY
    // Compiles nested operational and context metrics to fuel dynamic HTML generation inside the cloud worker.
    final Map<String, dynamic> pipelinePayload = {
      "meta": {
        "formType": "Growth Engine PDF Export Request",
        "systemThresholdSetting": GrowthEnginePage.qualificationThreshold,
        "isLeadQualified": widget.calculatedAnnualLoss >= GrowthEnginePage.qualificationThreshold
      },
      "profile": {
        "clientName": _nameController.text.trim(),
        "companyName": _companyController.text.trim(),
        "corporateEmail": _emailController.text.trim(),
      },
      "infrastructureState": {
        "analyzedTrack": widget.sectorTitle,
        "metricAlpha": {
          "label": widget.metricLabel1,
          "rawInput": widget.value1,
          "unit": widget.unit1
        },
        "metricBeta": {
          "label": widget.metricLabel2,
          "rawInput": widget.value2,
          "unit": widget.unit2
        }
      },
      "financialLedger": {
        "monthlyLossRaw": widget.calculatedMonthlyLoss,
        "annualLossRaw": widget.calculatedAnnualLoss,
        "formattedMonthlyLoss": "\$${widget.calculatedMonthlyLoss.toStringAsFixed(0)}",
        "formattedAnnualLoss": "\$${widget.calculatedAnnualLoss.toStringAsFixed(0)}"
      }
    };

    try {
      // Handshake connection straight to your live Supabase Deno worker
      final response = await http.post(
        Uri.parse('https://zljdfgkvlipwbvmlizyx.supabase.co/functions/v1/generate-pdf-report'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode(pipelinePayload),
      );

      // Optional debug trace to check your server's runtime response in your console
      debugPrint('Edge Worker Response Status: ${response.statusCode}');
      debugPrint('Edge Worker Response Body: ${response.body}');
    } catch (e) {
      debugPrint('Network transport link error: $e');
    }

    if (!mounted) return;
    setState(() => _isTransmitting = false);

    // Unwinds capture panel views, triggers local success hooks, and presents completion confirmation
    Navigator.pop(context);
    widget.onSuccess();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF0A0B10),
        content: Text('DIAGNOSTICS EXPORTED. CHECK INSIGHT LOG INBOX.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: AlertDialog(
        backgroundColor: const Color(0xFF0A0B10),
        contentPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: widget.themeColor.withValues(alpha: 0.5)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'EXPORT DIAGNOSTICS PDF',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'monospace'),
            ),
            if (_isTransmitting)
              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: widget.themeColor, strokeWidth: 1.5))
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We are compiling your custom bottleneck report. Enter communication parameters to dispatch the diagnostic layout to your inbox.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              _buildField("Contact Name", _nameController),
              _buildField("Enterprise Entity Name", _companyController),
              _buildField("Corporate Email", _emailController, isEmail: true),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isTransmitting ? null : _executeCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: const Color(0xFF0A0B10),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text('DISPATCH REPORT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return "PARAMETER STRICTLY REQUIRED";
          if (isEmail && !RegExp(r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v)) {
            return "INVALID COMMUNICATION INTERFACE FORMAT";
          }
          return null;
        },
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace'),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.01),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10), borderRadius: BorderRadius.zero),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.themeColor), borderRadius: BorderRadius.zero),
          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 9, fontFamily: 'monospace'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}