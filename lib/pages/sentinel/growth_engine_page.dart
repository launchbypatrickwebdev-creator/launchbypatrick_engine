// lib/pages/sentinel/growth_engine_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../shared/ops_background_engine.dart';
import '../../shared/launch_tactile_engine.dart';
import '../../shared/launch_section_container.dart';
import '../../widgets/sentinel_nav_bar.dart';
import '../../widgets/shared_site_footer.dart';

// =============================================================================
// METRIC KEY
// =============================================================================

class MetricKey {
  final String sectorId;
  final String metricId;

  const MetricKey(this.sectorId, this.metricId);

  @override
  bool operator ==(Object other) =>
      other is MetricKey &&
          other.sectorId == sectorId &&
          other.metricId == metricId;

  @override
  int get hashCode => Object.hash(sectorId, metricId);

  @override
  String toString() => '$sectorId.$metricId';
}

// =============================================================================
// DATA MODELS
// =============================================================================

class FuelSectorMetric {
  final String id;
  final String label;
  final String hint;
  final String unit;
  final double min;
  final double max;
  final double defaultValue;
  final double step;

  const FuelSectorMetric({
    required this.id,
    required this.label,
    required this.hint,
    required this.unit,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.step,
  });
}

class FuelSector {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String targetAudience;
  final List<FuelSectorMetric> metrics;
  final Color accentColor;
  final double Function(Map<MetricKey, double>) calculateLoss;

  FuelSector({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.targetAudience,
    required this.metrics,
    required this.accentColor,
    required this.calculateLoss,
  });
}

// =============================================================================
// CALCULATION FORMULAS
// =============================================================================

double calcGeneratorLoss(Map<MetricKey, double> m) {
  final double count   = m[const MetricKey('generator', 'count')]          ?? 5;
  final double budget  = m[const MetricKey('generator', 'monthly_budget')] ?? 200000;
  final double lossPct = m[const MetricKey('generator', 'loss_percent')]   ?? 15;
  return count * budget * (lossPct / 100) * 12;
}

double calcFleetLoss(Map<MetricKey, double> m) {
  final double count       = m[const MetricKey('fleet', 'count')]          ?? 20;
  final double spend       = m[const MetricKey('fleet', 'monthly_spend')]  ?? 120000;
  final double unaccounted = m[const MetricKey('fleet', 'unaccounted')]    ?? 20;
  return count * spend * (unaccounted / 100) * 12;
}

double calcDowntimeLoss(Map<MetricKey, double> m) {
  final double dtHrs      = m[const MetricKey('downtime', 'downtime_hrs')]  ?? 8;
  final double valuePerHr = m[const MetricKey('downtime', 'value_per_hr')] ?? 50000;
  return dtHrs * valuePerHr * 12;
}

double calcLoggingLoss(Map<MetricKey, double> m) {
  final double staffHrs  = m[const MetricKey('logging', 'staff_hrs')]   ?? 10;
  final double costPerHr = m[const MetricKey('logging', 'cost_per_hr')] ?? 2500;
  final double sites     = m[const MetricKey('logging', 'sites')]       ?? 3;
  return staffHrs * costPerHr * sites * 52;
}

double calcEmergencyLoss(Map<MetricKey, double> m) {
  final double buys    = m[const MetricKey('emergency', 'emergency_buys')]  ?? 6;
  final double premium = m[const MetricKey('emergency', 'premium_pct')]     ?? 25;
  final double volume  = m[const MetricKey('emergency', 'purchase_volume')] ?? 150000;
  return buys * volume * (premium / 100);
}

double calcAdulterationLoss(Map<MetricKey, double> m) {
  final double litres     = m[const MetricKey('adulteration', 'monthly_litres')] ?? 2000;
  final double adulterPct = m[const MetricKey('adulteration', 'adulter_pct')]    ?? 10;
  final double costPerL   = m[const MetricKey('adulteration', 'cost_per_litre')] ?? 950;
  return litres * (adulterPct / 100) * costPerL * 12;
}

double calcMultisiteLoss(Map<MetricKey, double> m) {
  final double sites       = m[const MetricKey('multisite', 'sites')]        ?? 5;
  final double monthlyLoss = m[const MetricKey('multisite', 'monthly_loss')] ?? 30000;
  return sites * monthlyLoss * 12;
}

double calcComplianceLoss(Map<MetricKey, double> m) {
  final double audits      = m[const MetricKey('compliance', 'audits')]       ?? 2;
  final double findingCost = m[const MetricKey('compliance', 'finding_cost')] ?? 500000;
  final double probability = m[const MetricKey('compliance', 'probability')]  ?? 40;
  return audits * findingCost * (probability / 100);
}

// =============================================================================
// PAGE
// =============================================================================

class SentinelGrowthEnginePage extends StatefulWidget {
  const SentinelGrowthEnginePage({super.key});

  @override
  State<SentinelGrowthEnginePage> createState() =>
      _SentinelGrowthEnginePageState();
}

class _SentinelGrowthEnginePageState
    extends State<SentinelGrowthEnginePage> {

  // ── Brand tokens ────────────────────────────────────────────────────────
  static const Color _green  = Color(0xFF00C853);
  static const Color _amber  = Color(0xFFFFEA00);
  static const Color _red    = Color(0xFFFF3B3B);
  static const Color _pageBg = Color(0xFF07080C);
  static const Color _cardBg = Color(0xFF0A1A0F);

  static const String _pdfEndpoint =
      'https://zljdfgkvlipwbvmlizyx.supabase.co/functions/v1/generate-sentinel-pdf';
  static const double _qualificationThreshold = 2000000;

  // FIX 1: page-level focus node — the neutral owner that LaunchTactileEngine
  // needs. Without this, unfocusing any TextField leaves the scroll engine
  // as the only focus consumer, causing it to steal all key events.
  final FocusNode _pageFocusNode = FocusNode();

  // ── Step / audience state ────────────────────────────────────────────────
  int     _currentStep      = 0;
  String? _selectedAudience;
  final Set<String> _expandedSecondarySectors = {};

  // ── Typed metric values ──────────────────────────────────────────────────
  final Map<MetricKey, double>                _metricValues      = {};
  final Map<MetricKey, TextEditingController> _metricControllers = {};
  // FIX 2: metric focus nodes use the corrected factory (horizontal only)
  final Map<MetricKey, FocusNode>             _metricFocusNodes  = {};

  // ── Results ──────────────────────────────────────────────────────────────
  bool   _isCalculating   = false;
  bool   _isExportingPdf  = false;
  double _totalAnnualLoss = 0;

  // ── Capture fields ────────────────────────────────────────────────────────
  final TextEditingController _orgNameController  = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // FIX 2: capture field focus nodes — horizontal arrows + space only
  late final FocusNode _orgFocus      = _makeIsolatedFocus();
  late final FocusNode _emailFocus    = _makeIsolatedFocus();
  late final FocusNode _locationFocus = _makeIsolatedFocus();

  // ── Sector cache ─────────────────────────────────────────────────────────
  List<FuelSector>? _cachedPrimarySectors;
  String?           _cachedAudience;

  // =========================================================================
  // FIX 2: isolated focus factory
  // Intercepts horizontal arrows + space ONLY.
  // Does NOT intercept arrowUp / arrowDown — those scroll the page.
  // Matches growth_intakeform_page.dart _createIsolatedFocusNode() exactly.
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
  // METRIC CONTROLLER / FOCUS ACCESSORS
  // =========================================================================

  TextEditingController _controllerFor(
      String sectorId, String metricId, double defaultValue) {
    final MetricKey key = MetricKey(sectorId, metricId);
    if (!_metricControllers.containsKey(key)) {
      _metricControllers[key] =
          TextEditingController(text: defaultValue.toStringAsFixed(0));
    }
    return _metricControllers[key]!;
  }

  FocusNode _focusFor(String sectorId, String metricId) {
    final MetricKey key = MetricKey(sectorId, metricId);
    if (!_metricFocusNodes.containsKey(key)) {
      _metricFocusNodes[key] = _makeIsolatedFocus();
    }
    return _metricFocusNodes[key]!;
  }

  // =========================================================================
  // SECTOR DEFINITIONS
  // =========================================================================

  late final FuelSector _generatorSector = FuelSector(
    id: 'generator',
    name: 'Standby Generators',
    icon: '⚡',
    description: 'Fuel loss, theft, and discrepancy across your generator assets.',
    targetAudience:
    'Banks · Hospitals · Telecoms · Hotels · Data Centers · Schools · Manufacturers',
    accentColor: _green,
    metrics: const [
      FuelSectorMetric(
        id: 'count', label: 'NUMBER OF GENERATORS MANAGED',
        hint: 'Total generator units across all your sites',
        unit: 'units', min: 1, max: 500, defaultValue: 5, step: 1,
      ),
      FuelSectorMetric(
        id: 'monthly_budget', label: 'MONTHLY FUEL BUDGET PER GENERATOR (₦)',
        hint: 'Average monthly fuel spend per unit',
        unit: '₦', min: 50000, max: 5000000, defaultValue: 200000, step: 10000,
      ),
      FuelSectorMetric(
        id: 'loss_percent', label: 'ESTIMATED FUEL LOSS / DISCREPANCY (%)',
        hint: 'Percentage you believe is lost to theft or unaccounted usage',
        unit: '%', min: 1, max: 60, defaultValue: 15, step: 1,
      ),
    ],
    calculateLoss: calcGeneratorLoss,
  );

  late final FuelSector _fleetSector = FuelSector(
    id: 'fleet',
    name: 'Logistics & Commercial Fleets',
    icon: '🚛',
    description: 'Unaccounted fuel across your vehicle fleet operations.',
    targetAudience:
    'Haulage Trucks · Inter-state Buses · Delivery Fleets · Commercial Vans',
    accentColor: _green,
    metrics: const [
      FuelSectorMetric(
        id: 'count', label: 'NUMBER OF VEHICLES IN FLEET',
        hint: 'Total commercial vehicles managed',
        unit: 'vehicles', min: 1, max: 1000, defaultValue: 20, step: 1,
      ),
      FuelSectorMetric(
        id: 'monthly_spend', label: 'MONTHLY FUEL SPEND PER VEHICLE (₦)',
        hint: 'Average monthly fuel budget per vehicle',
        unit: '₦', min: 30000, max: 1000000, defaultValue: 120000, step: 5000,
      ),
      FuelSectorMetric(
        id: 'unaccounted', label: 'ESTIMATED UNACCOUNTED FUEL (%)',
        hint: 'Percentage of fuel you cannot verify',
        unit: '%', min: 1, max: 60, defaultValue: 20, step: 1,
      ),
    ],
    calculateLoss: calcFleetLoss,
  );

  late final List<FuelSector> _secondarySectors = [
    FuelSector(
      id: 'downtime', name: 'Generator Downtime Cost', icon: '🔴',
      description: 'Revenue and productivity lost when generators fail unexpectedly.',
      targetAudience: 'Any operation dependent on continuous power',
      accentColor: _red,
      metrics: const [
        FuelSectorMetric(id: 'ops_hours', label: 'CRITICAL OPERATIONS HOURS PER DAY',
            hint: 'Hours per day where downtime directly costs you money',
            unit: 'hrs', min: 1, max: 24, defaultValue: 12, step: 1),
        FuelSectorMetric(id: 'downtime_hrs', label: 'UNPLANNED DOWNTIME HOURS PER MONTH',
            hint: 'Realistic estimate of unexpected outages',
            unit: 'hrs', min: 0.5, max: 72, defaultValue: 8, step: 0.5),
        FuelSectorMetric(id: 'value_per_hr', label: 'REVENUE / PRODUCTIVITY VALUE PER HOUR (₦)',
            hint: 'What one hour of downtime costs your business',
            unit: '₦', min: 5000, max: 5000000, defaultValue: 50000, step: 5000),
      ],
      calculateLoss: calcDowntimeLoss,
    ),
    FuelSector(
      id: 'logging', name: 'Manual Logging Overhead', icon: '📋',
      description: 'Staff time wasted on manual fuel records and handwritten logs.',
      targetAudience: 'Multi-site operations with manual fuel tracking',
      accentColor: _amber,
      metrics: const [
        FuelSectorMetric(id: 'staff_hrs', label: 'STAFF HOURS SPENT ON FUEL LOGGING PER WEEK',
            hint: 'Total hours across all staff doing manual fuel tracking',
            unit: 'hrs', min: 1, max: 80, defaultValue: 10, step: 1),
        FuelSectorMetric(id: 'cost_per_hr', label: 'AVERAGE STAFF COST PER HOUR (₦)',
            hint: 'Loaded cost including salary and overheads',
            unit: '₦', min: 500, max: 20000, defaultValue: 2500, step: 500),
        FuelSectorMetric(id: 'sites', label: 'NUMBER OF SITES MANAGED',
            hint: 'Locations where manual logging happens',
            unit: 'sites', min: 1, max: 200, defaultValue: 3, step: 1),
      ],
      calculateLoss: calcLoggingLoss,
    ),
    FuelSector(
      id: 'emergency', name: 'Emergency Procurement Premium', icon: '🚨',
      description: 'The premium cost of buying fuel urgently at above-market rates.',
      targetAudience: 'Any site that has run dry unexpectedly',
      accentColor: const Color(0xFFFF9500),
      metrics: const [
        FuelSectorMetric(id: 'emergency_buys', label: 'EMERGENCY FUEL PURCHASES PER YEAR',
            hint: 'Number of times you bought fuel urgently at premium price',
            unit: 'times', min: 1, max: 52, defaultValue: 6, step: 1),
        FuelSectorMetric(id: 'premium_pct', label: 'AVERAGE PREMIUM ABOVE MARKET PRICE (%)',
            hint: 'How much more you paid versus normal market rate',
            unit: '%', min: 5, max: 80, defaultValue: 25, step: 5),
        FuelSectorMetric(id: 'purchase_volume', label: 'AVERAGE EMERGENCY PURCHASE VOLUME (₦)',
            hint: 'Value of each emergency purchase',
            unit: '₦', min: 10000, max: 2000000, defaultValue: 150000, step: 10000),
      ],
      calculateLoss: calcEmergencyLoss,
    ),
    FuelSector(
      id: 'adulteration', name: 'Fuel Adulteration Loss', icon: '🧪',
      description: 'Value lost when purchased fuel is adulterated or substandard.',
      targetAudience: 'High-volume fuel purchasers, logistics operators',
      accentColor: const Color(0xFF9C27B0),
      metrics: const [
        FuelSectorMetric(id: 'monthly_litres', label: 'MONTHLY FUEL VOLUME PURCHASED (litres)',
            hint: 'Total litres purchased across all assets per month',
            unit: 'L', min: 100, max: 100000, defaultValue: 2000, step: 100),
        FuelSectorMetric(id: 'adulter_pct', label: 'ESTIMATED ADULTERATION RATE (%)',
            hint: 'Percentage of fuel you believe is diluted or substandard',
            unit: '%', min: 1, max: 40, defaultValue: 10, step: 1),
        FuelSectorMetric(id: 'cost_per_litre', label: 'CURRENT COST PER LITRE (₦)',
            hint: 'What you currently pay per litre',
            unit: '₦/L', min: 600, max: 3000, defaultValue: 950, step: 10),
      ],
      calculateLoss: calcAdulterationLoss,
    ),
    FuelSector(
      id: 'multisite', name: 'Multi-Site Oversight Gap', icon: '🗺️',
      description: 'Loss that accumulates undetected across multiple sites before discovery.',
      targetAudience: 'Multi-site operators, regional managers',
      accentColor: const Color(0xFF2196F3),
      metrics: const [
        FuelSectorMetric(id: 'sites', label: 'NUMBER OF SITES MANAGED REMOTELY',
            hint: 'Sites you cannot physically visit daily',
            unit: 'sites', min: 2, max: 500, defaultValue: 5, step: 1),
        FuelSectorMetric(id: 'monthly_loss', label: 'ESTIMATED UNDETECTED MONTHLY LOSS PER SITE (₦)',
            hint: 'Conservative estimate of monthly loss at each unmonitored site',
            unit: '₦', min: 5000, max: 500000, defaultValue: 30000, step: 5000),
        FuelSectorMetric(id: 'detection_months', label: 'MONTHS BEFORE LOSS IS DISCOVERED',
            hint: 'How long before you typically notice something is wrong',
            unit: 'months', min: 1, max: 12, defaultValue: 3, step: 1),
      ],
      calculateLoss: calcMultisiteLoss,
    ),
    FuelSector(
      id: 'compliance', name: 'Compliance & Audit Risk', icon: '⚖️',
      description: 'Financial exposure from regulatory audit findings on unverified fuel records.',
      targetAudience: 'Regulated industries: banks, telecoms, healthcare',
      accentColor: _red,
      metrics: const [
        FuelSectorMetric(id: 'audits', label: 'REGULATORY AUDITS PER YEAR',
            hint: 'Number of external audits your organisation faces annually',
            unit: 'audits', min: 1, max: 12, defaultValue: 2, step: 1),
        FuelSectorMetric(id: 'finding_cost', label: 'AVERAGE COST OF DISCREPANCY FINDING (₦)',
            hint: 'Fine, remediation cost, or reputational damage per finding',
            unit: '₦', min: 50000, max: 10000000, defaultValue: 500000, step: 50000),
        FuelSectorMetric(id: 'probability', label: 'PROBABILITY OF AUDIT FINDING (%)',
            hint: 'How likely a finding is given your current record quality',
            unit: '%', min: 5, max: 95, defaultValue: 40, step: 5),
      ],
      calculateLoss: calcComplianceLoss,
    ),
  ];

  // =========================================================================
  // HELPERS
  // =========================================================================

  List<FuelSector> get _primarySectorsForAudience {
    if (_cachedAudience == _selectedAudience &&
        _cachedPrimarySectors != null) {
      return _cachedPrimarySectors!;
    }
    _cachedAudience = _selectedAudience;
    _cachedPrimarySectors = _selectedAudience == 'generator'
        ? [_generatorSector]
        : _selectedAudience == 'fleet'
        ? [_fleetSector]
        : [_generatorSector, _fleetSector];
    return _cachedPrimarySectors!;
  }

  double metricValue(String sectorId, String metricId) {
    final MetricKey key = MetricKey(sectorId, metricId);
    if (_metricValues.containsKey(key)) return _metricValues[key]!;
    final FuelSector? sector = _getSectorById(sectorId);
    if (sector == null) return 0;
    try {
      return sector.metrics.firstWhere((m) => m.id == metricId).defaultValue;
    } catch (_) {
      return 0;
    }
  }

  void _setMetricFromSlider(String sectorId, String metricId, double value) {
    final MetricKey key = MetricKey(sectorId, metricId);
    final FuelSector? sector = _getSectorById(sectorId);
    final FuelSectorMetric? metric = sector?.metrics
        .cast<FuelSectorMetric?>()
        .firstWhere((m) => m?.id == metricId, orElse: () => null);
    setState(() => _metricValues[key] = value);
    final TextEditingController ctrl =
    _controllerFor(sectorId, metricId, metric?.defaultValue ?? 0);
    final String formatted = _rawMetricString(value, metric);
    if (ctrl.text != formatted) {
      ctrl.value = ctrl.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _setMetricFromField(
      String sectorId, String metricId, String text, FuelSectorMetric metric) {
    final String cleaned =
    text.replaceAll(',', '').replaceAll('₦', '').replaceAll('%', '').trim();
    final double? parsed = double.tryParse(cleaned);
    if (parsed == null) return;
    final double clamped = parsed.clamp(metric.min, metric.max);
    setState(() => _metricValues[MetricKey(sectorId, metricId)] = clamped);
  }

  String _rawMetricString(double value, FuelSectorMetric? metric) {
    if (metric == null) return value.toStringAsFixed(0);
    if (metric.step < 1) return value.toStringAsFixed(1);
    return value.toStringAsFixed(0);
  }

  FuelSector? _getSectorById(String id) {
    if (id == 'generator') return _generatorSector;
    if (id == 'fleet')     return _fleetSector;
    try {
      return _secondarySectors.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  double _calculateSectorLoss(FuelSector sector) =>
      sector.calculateLoss(_metricValues);

  double _calculateTotal() {
    double total = 0;
    for (final sector in _primarySectorsForAudience) {
      total += _calculateSectorLoss(sector);
    }
    for (final sector in _secondarySectors) {
      if (_expandedSecondarySectors.contains(sector.id)) {
        total += _calculateSectorLoss(sector);
      }
    }
    return total;
  }

  String _formatNaira(double value) {
    if (value >= 1000000000) return '₦${(value / 1000000000).toStringAsFixed(1)}B';
    if (value >= 1000000)    return '₦${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000)       return '₦${(value / 1000).toStringAsFixed(0)}K';
    return '₦${value.toStringAsFixed(0)}';
  }

  String _formatWithCommas(double value) => value
      .toStringAsFixed(0)
      .replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _formatMetricValue(double value, FuelSectorMetric metric) {
    if (metric.unit == '₦')   return '₦${_formatWithCommas(value)}';
    if (metric.unit == '₦/L') return '₦${value.toStringAsFixed(0)}/L';
    if (metric.unit == '%')   return '${value.toStringAsFixed(0)}%';
    if (metric.step < 1)      return '${value.toStringAsFixed(1)} ${metric.unit}';
    return '${value.toStringAsFixed(0)} ${metric.unit}';
  }

  int get _qualificationOutcome {
    if (_totalAnnualLoss == 0) return 0;
    if (_totalAnnualLoss < _qualificationThreshold) return 1;
    return 2;
  }

  String? _validateBeforeExport() {
    if (_emailController.text.trim().isEmpty) {
      return "EMAIL REQUIRED TO RECEIVE YOUR REPORT";
    }
    bool hasRealInput = false;
    for (final sector in _primarySectorsForAudience) {
      for (final metric in sector.metrics) {
        final MetricKey key = MetricKey(sector.id, metric.id);
        if (_metricValues.containsKey(key) &&
            _metricValues[key] != metric.defaultValue) {
          hasRealInput = true;
          break;
        }
      }
      if (hasRealInput) break;
    }
    if (!hasRealInput) {
      return "ADJUST AT LEAST ONE METRIC TO REFLECT YOUR REAL NUMBERS";
    }
    return null;
  }

  // =========================================================================
  // CALCULATE
  // =========================================================================

  void _runCalculation() {
    setState(() {
      _isCalculating   = true;
      _totalAnnualLoss = 0;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _totalAnnualLoss = _calculateTotal();
        _isCalculating   = false;
        _currentStep     = 3;
      });
    });
  }

  // =========================================================================
  // PDF EXPORT — with one retry
  // =========================================================================

  Future<void> _exportPdf() async {
    final String? error = _validateBeforeExport();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(error,
            style: GoogleFonts.robotoMono(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ));
      return;
    }
    setState(() => _isExportingPdf = true);

    final List<Map<String, dynamic>> breakdown = [];
    for (final sector in _primarySectorsForAudience) {
      final double loss = _calculateSectorLoss(sector);
      if (loss > 0) {
        breakdown.add({
        'sector': sector.name, 'annual_loss': loss,
        'formatted': _formatNaira(loss),
        'percentage': _totalAnnualLoss > 0
            ? ((loss / _totalAnnualLoss) * 100).toStringAsFixed(0) : '0',
      });
      }
    }
    for (final sector in _secondarySectors) {
      if (_expandedSecondarySectors.contains(sector.id)) {
        final double loss = _calculateSectorLoss(sector);
        if (loss > 0) {
          breakdown.add({
          'sector': sector.name, 'annual_loss': loss,
          'formatted': _formatNaira(loss),
          'percentage': _totalAnnualLoss > 0
              ? ((loss / _totalAnnualLoss) * 100).toStringAsFixed(0) : '0',
        });
        }
      }
    }
    breakdown.sort((a, b) =>
        (b['annual_loss'] as double).compareTo(a['annual_loss'] as double));

    final Map<String, dynamic> payload = {
      'report_type':         'sentinel_fuel_loss',
      'organisation':        _orgNameController.text.trim(),
      'email':               _emailController.text.trim(),
      'location':            _locationController.text.trim(),
      'audience':            _selectedAudience,
      'total_annual_loss':   _totalAnnualLoss,
      'formatted_loss':      _formatNaira(_totalAnnualLoss),
      'three_year_loss':     _formatNaira(_totalAnnualLoss * 3),
      'sector_breakdown':    breakdown,
      'primary_risk_sector': breakdown.isNotEmpty
          ? breakdown.first['sector'] : 'N/A',
      'generated_at':        DateTime.now().toIso8601String(),
    };

    bool success = false;
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(_pdfEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        );
        if (response.statusCode == 200) { success = true; break; }
        debugPrint('⚠️ PDF attempt $attempt: ${response.statusCode}');
      } catch (e) {
        debugPrint('⚠️ PDF attempt $attempt error: $e');
      }
      if (attempt == 1) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (!mounted) return;
    setState(() => _isExportingPdf = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: success ? _green : Colors.redAccent,
      duration: Duration(seconds: success ? 4 : 5),
      content: Text(
        success
            ? "REPORT DISPATCHED → ${_emailController.text.trim()}"
            : "PDF GENERATION FAILED — email us at launchbypatrick.webdev@gmail.com",
        style: GoogleFonts.robotoMono(
          color: success ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold, fontSize: 11,
        ),
      ),
    ));
  }

  @override
  void dispose() {
    // FIX 1: dispose page node
    _pageFocusNode.dispose();
    _orgNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _orgFocus.dispose();
    _emailFocus.dispose();
    _locationFocus.dispose();
    for (final ctrl in _metricControllers.values) {
      ctrl.dispose();
    }
    for (final node in _metricFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/videos/growth-engine.mp4',
            ),
          ),
          // FIX 1: pageFocusNode passed to LaunchTactileEngine
          // This is the neutral owner that the scroll engine needs.
          // Without it, every TextField unfocus leaves the engine
          // as sole focus consumer, stealing all keyboard events.
          LaunchTactileEngine(
            focusNode: _pageFocusNode,
            onRefresh: () async =>
            await Future.delayed(const Duration(milliseconds: 800)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SentinelNavBar(),
                _buildHero(isMobile),
                _buildProgressIndicator(isMobile),
                if (_currentStep == 0) _buildAudienceSelector(isMobile),
                if (_currentStep >= 1) _buildPrimarySectors(isMobile),
                if (_currentStep >= 1) _buildSecondarySectors(isMobile),
                if (_currentStep >= 1 && _currentStep < 3)
                  _buildCalculateButton(isMobile),
                if (_currentStep == 3) _buildResults(isMobile),
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
            label: 'Sentinel Fuel Loss Diagnostic Engine.',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: _green.withValues(alpha: 0.15),
              child: Text("SENTINEL // FUEL LOSS DIAGNOSTIC ENGINE",
                  style: GoogleFonts.robotoMono(color: _green,
                      fontSize: isMobile ? 8 : 10,
                      fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            label: 'Calculate exactly how much fuel your operation is losing every year.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CALCULATE EXACTLY',
                    style: TextStyle(fontSize: isMobile ? 28 : 48,
                        fontWeight: FontWeight.bold, color: Colors.white,
                        letterSpacing: 1.2, height: 1.1)),
                Text('WHAT YOU ARE LOSING.',
                    style: TextStyle(fontSize: isMobile ? 28 : 48,
                        fontWeight: FontWeight.bold, color: _green,
                        letterSpacing: 1.2, height: 1.1)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              'Answer three questions per sector. Get your annual fuel loss figure in Naira. Use the PDF report to justify the decision to act.',
              style: GoogleFonts.poppins(color: Colors.white70,
                  fontSize: isMobile ? 13 : 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // =========================================================================
  // PROGRESS INDICATOR
  // =========================================================================
  Widget _buildProgressIndicator(bool isMobile) {
    const List<String> steps = [
      'YOUR OPERATION', 'PRIMARY SECTORS', 'ADD MORE', 'YOUR EXPOSURE'
    ];
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 60, vertical: 20),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(child: Container(height: 1,
                color: _currentStep > (i ~/ 2)
                    ? _green : Colors.white.withValues(alpha: 0.1)));
          }
          final int si     = i ~/ 2;
          final bool isActive  = _currentStep == si;
          final bool isDone    = _currentStep > si;
          return Column(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isDone ? _green
                    : isActive ? _green.withValues(alpha: 0.2)
                    : Colors.transparent,
                border: Border.all(
                    color: isDone || isActive ? _green : Colors.white24,
                    width: 1),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.black, size: 14)
                    : Text('${si + 1}', style: GoogleFonts.robotoMono(
                    color: isActive ? _green : Colors.white38,
                    fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(height: 6),
              Text(steps[si], style: GoogleFonts.robotoMono(
                  color: isActive || isDone ? _green : Colors.white24,
                  fontSize: 8, letterSpacing: 1.0)),
            ],
          ]);
        }),
      ),
    );
  }

  // =========================================================================
  // AUDIENCE SELECTOR
  // =========================================================================
  Widget _buildAudienceSelector(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("STEP 01 // IDENTIFY YOUR OPERATION",
              style: GoogleFonts.robotoMono(color: _green, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 16),
          Text("Which best describes you?",
              style: TextStyle(color: Colors.white,
                  fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("We'll show you the sectors most relevant to your operation first.",
              style: GoogleFonts.poppins(color: Colors.white54,
                  fontSize: isMobile ? 12 : 14)),
          const SizedBox(height: 40),
          isMobile
              ? Column(children: [
            _buildAudienceCard(id: 'generator', icon: '⚡',
                title: 'Standby Generator\nOperator',
                subtitle: 'Banks, Hospitals, Telecoms,\nHotels, Data Centers',
                isMobile: isMobile),
            const SizedBox(height: 16),
            _buildAudienceCard(id: 'fleet', icon: '🚛',
                title: 'Logistics / Fleet\nManager',
                subtitle: 'Haulage, Buses, Delivery\nFleets, Commercial Vans',
                isMobile: isMobile),
            const SizedBox(height: 16),
            _buildAudienceCard(id: 'both', icon: '🏭',
                title: 'Both / Multi-Asset\nOperator',
                subtitle: 'You manage both generators\nand a vehicle fleet',
                isMobile: isMobile),
          ])
              : Row(children: [
            Expanded(child: _buildAudienceCard(id: 'generator', icon: '⚡',
                title: 'Standby Generator\nOperator',
                subtitle: 'Banks, Hospitals, Telecoms,\nHotels, Data Centers',
                isMobile: isMobile)),
            const SizedBox(width: 16),
            Expanded(child: _buildAudienceCard(id: 'fleet', icon: '🚛',
                title: 'Logistics / Fleet\nManager',
                subtitle: 'Haulage, Buses, Delivery\nFleets, Commercial Vans',
                isMobile: isMobile)),
            const SizedBox(width: 16),
            Expanded(child: _buildAudienceCard(id: 'both', icon: '🏭',
                title: 'Both / Multi-Asset\nOperator',
                subtitle: 'You manage both generators\nand a vehicle fleet',
                isMobile: isMobile)),
          ]),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildAudienceCard({
    required String id, required String icon,
    required String title, required String subtitle,
    required bool isMobile,
  }) {
    final bool isSelected = _selectedAudience == id;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAudience     = id;
        _cachedPrimarySectors = null;
        _currentStep          = 1;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        decoration: BoxDecoration(
          color: isSelected
              ? _green.withValues(alpha: 0.1)
              : _cardBg.withValues(alpha: 0.3),
          border: Border.all(
              color: isSelected ? _green : Colors.white10,
              width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold, height: 1.3)),
            const SizedBox(height: 8),
            Text(subtitle, style: GoogleFonts.poppins(
                color: Colors.white38, fontSize: 12, height: 1.4)),
            if (isSelected) ...[
              const SizedBox(height: 16),
              Row(children: [
                Container(width: 8, height: 8, color: _green),
                const SizedBox(width: 8),
                Text("SELECTED", style: GoogleFonts.robotoMono(
                    color: _green, fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // PRIMARY SECTORS
  // =========================================================================
  Widget _buildPrimarySectors(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text("STEP 02 // PRIMARY LOSS SECTORS",
              style: GoogleFonts.robotoMono(color: _green, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 12),
          Text("Your Core Exposure Areas",
              style: TextStyle(color: Colors.white,
                  fontSize: isMobile ? 22 : 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Move the slider or type a number directly. Be conservative — most operations underestimate their losses.",
              style: GoogleFonts.poppins(color: Colors.white54,
                  fontSize: isMobile ? 12 : 14, height: 1.5)),
          const SizedBox(height: 32),
          ..._primarySectorsForAudience.map((sector) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildSectorCard(sector, isMobile),
          )),
        ],
      ),
    );
  }

  // =========================================================================
  // SECONDARY SECTORS
  // =========================================================================
  Widget _buildSecondarySectors(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("STEP 03 // ADD MORE SECTORS (OPTIONAL)",
              style: GoogleFonts.robotoMono(color: _amber, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 12),
          Text("Include More Loss Sources",
              style: TextStyle(color: Colors.white,
                  fontSize: isMobile ? 20 : 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Expand any sector that applies. Each adds to your total exposure figure.",
              style: GoogleFonts.poppins(color: Colors.white54,
                  fontSize: isMobile ? 12 : 14, height: 1.5)),
          const SizedBox(height: 24),
          ..._secondarySectors.map((sector) {
            final bool isExpanded =
            _expandedSecondarySectors.contains(sector.id);
            final double sectorLoss =
            isExpanded ? _calculateSectorLoss(sector) : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(children: [
                GestureDetector(
                  onTap: () => setState(() => isExpanded
                      ? _expandedSecondarySectors.remove(sector.id)
                      : _expandedSecondarySectors.add(sector.id)),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? sector.accentColor.withValues(alpha: 0.08)
                          : _cardBg.withValues(alpha: 0.2),
                      border: Border.all(
                          color: isExpanded
                              ? sector.accentColor.withValues(alpha: 0.4)
                              : Colors.white10),
                    ),
                    child: Row(children: [
                      Text(sector.icon,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sector.name, style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold)),
                          Text(sector.description, style: GoogleFonts.poppins(
                              color: Colors.white38, fontSize: 11, height: 1.4)),
                        ],
                      )),
                      const SizedBox(width: 16),
                      if (isExpanded && sectorLoss > 0)
                        Text(_formatNaira(sectorLoss),
                            style: GoogleFonts.robotoMono(
                                color: sector.accentColor, fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: isExpanded
                              ? sector.accentColor : Colors.white38),
                    ]),
                  ),
                ),
                if (isExpanded)
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: sector.accentColor.withValues(alpha: 0.03),
                      border: Border(
                        left: BorderSide(
                            color: sector.accentColor.withValues(alpha: 0.3)),
                        right: BorderSide(
                            color: sector.accentColor.withValues(alpha: 0.1)),
                        bottom: BorderSide(
                            color: sector.accentColor.withValues(alpha: 0.1)),
                      ),
                    ),
                    child: _buildMetricsForSector(sector, isMobile),
                  ),
              ]),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTOR CARD
  // =========================================================================
  Widget _buildSectorCard(FuelSector sector, bool isMobile) {
    final double sectorLoss = _calculateSectorLoss(sector);
    return Container(
      decoration: BoxDecoration(
        color: _cardBg.withValues(alpha: 0.3),
        border: Border.all(color: sector.accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(border: Border(
                bottom: BorderSide(
                    color: sector.accentColor.withValues(alpha: 0.15)))),
            child: Row(children: [
              Text(sector.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sector.name, style: TextStyle(color: Colors.white,
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.bold)),
                  Text(sector.targetAudience, style: GoogleFonts.poppins(
                      color: Colors.white38, fontSize: 11, height: 1.4)),
                ],
              )),
              if (sectorLoss > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatNaira(sectorLoss), style: GoogleFonts.robotoMono(
                        color: _red,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold)),
                    Text("/ year", style: GoogleFonts.robotoMono(
                        color: Colors.white38, fontSize: 10)),
                  ],
                ),
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: _buildMetricsForSector(sector, isMobile),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // METRICS — slider + editable text field, bidirectional sync
  // FIX 3: onTapOutside and onSubmitted redirect to _pageFocusNode
  // instead of calling focusNode.unfocus() into the void
  // =========================================================================
  Widget _buildMetricsForSector(FuelSector sector, bool isMobile) {
    return Column(
      children: sector.metrics.map((metric) {
        final double current = metricValue(sector.id, metric.id);
        final TextEditingController ctrl =
        _controllerFor(sector.id, metric.id, metric.defaultValue);
        final FocusNode focusNode = _focusFor(sector.id, metric.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(metric.label,
                      style: GoogleFonts.robotoMono(color: Colors.white54,
                          fontSize: isMobile ? 9 : 10, letterSpacing: 1.2))),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: isMobile ? 90 : 120,
                    height: 36,
                    child: TextField(
                      controller: ctrl,
                      focusNode: focusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoMono(color: _green,
                          fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _cardBg,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        suffix: Text(
                          metric.unit == '₦' || metric.unit == '₦/L'
                              ? '₦' : metric.unit,
                          style: TextStyle(
                              color: _green.withValues(alpha: 0.5),
                              fontSize: 10),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _green.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.zero),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: _green),
                            borderRadius: BorderRadius.zero),
                      ),
                      onChanged: (text) => _setMetricFromField(
                          sector.id, metric.id, text, metric),
                      onSubmitted: (_) {
                        final double clamped =
                        metricValue(sector.id, metric.id)
                            .clamp(metric.min, metric.max);
                        _setMetricFromSlider(sector.id, metric.id, clamped);
                        // FIX 3: redirect to page node, not into void
                        _pageFocusNode.requestFocus();
                      },
                      onTapOutside: (_) {
                        final double clamped =
                        metricValue(sector.id, metric.id)
                            .clamp(metric.min, metric.max);
                        _setMetricFromSlider(sector.id, metric.id, clamped);
                        // FIX 3: redirect to page node, not into void
                        _pageFocusNode.requestFocus();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(_formatMetricValue(current, metric),
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: _green,
                  inactiveTrackColor: Colors.white10,
                  thumbColor: _green,
                  overlayColor: _green.withValues(alpha: 0.15),
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8),
                ),
                child: Slider(
                  min: metric.min,
                  max: metric.max,
                  divisions: ((metric.max - metric.min) / metric.step).round(),
                  value: current.clamp(metric.min, metric.max),
                  onChanged: (val) =>
                      _setMetricFromSlider(sector.id, metric.id, val),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatMetricValue(metric.min, metric),
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 10)),
                  Flexible(child: Text(metric.hint,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 9))),
                  Text(_formatMetricValue(metric.max, metric),
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // =========================================================================
  // CALCULATE BUTTON
  // =========================================================================
  Widget _buildCalculateButton(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(children: [
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isCalculating ? null : _runCalculation,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              disabledBackgroundColor: _green.withValues(alpha: 0.4),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 22),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
            child: _isCalculating
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2)),
              const SizedBox(width: 12),
              Text("CALCULATING EXPOSURE...",
                  style: GoogleFonts.robotoMono(
                      fontWeight: FontWeight.bold, fontSize: 13,
                      letterSpacing: 1.5)),
            ])
                : Text("CALCULATE MY FUEL LOSS EXPOSURE",
                style: GoogleFonts.robotoMono(
                    fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 12 : 14, letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }

  // =========================================================================
  // RESULTS
  // =========================================================================
  Widget _buildResults(bool isMobile) {
    return LaunchSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.06),
              border: Border.all(color: _red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ESTIMATED ANNUAL FUEL LOSS EXPOSURE",
                    style: GoogleFonts.robotoMono(color: Colors.white38,
                        fontSize: isMobile ? 9 : 11, letterSpacing: 2.0)),
                const SizedBox(height: 16),
                Text(_formatNaira(_totalAnnualLoss),
                    style: TextStyle(color: _red,
                        fontSize: isMobile ? 48 : 72,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1, height: 1)),
                const SizedBox(height: 8),
                Text("per year — based on your inputs",
                    style: GoogleFonts.poppins(color: Colors.white38,
                        fontSize: isMobile ? 12 : 14)),
                const SizedBox(height: 12),
                Text("Over 3 years: ${_formatNaira(_totalAnnualLoss * 3)}",
                    style: GoogleFonts.robotoMono(
                        color: Colors.white24, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("SECTOR BREAKDOWN",
              style: GoogleFonts.robotoMono(color: Colors.white38,
                  fontSize: 10, fontWeight: FontWeight.bold,
                  letterSpacing: 2.0)),
          const SizedBox(height: 16),
          ..._buildSectorBreakdown(isMobile),
          const SizedBox(height: 40),
          _buildQualificationGate(isMobile),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  List<Widget> _buildSectorBreakdown(bool isMobile) {
    final List<MapEntry<FuelSector, double>> entries = [];
    for (final sector in _primarySectorsForAudience) {
      final double loss = _calculateSectorLoss(sector);
      if (loss > 0) entries.add(MapEntry(sector, loss));
    }
    for (final sector in _secondarySectors) {
      if (_expandedSecondarySectors.contains(sector.id)) {
        final double loss = _calculateSectorLoss(sector);
        if (loss > 0) entries.add(MapEntry(sector, loss));
      }
    }
    entries.sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) {
      final FuelSector sector = entry.key;
      final double loss = entry.value;
      final double pct =
      _totalAnnualLoss > 0 ? (loss / _totalAnnualLoss * 100) : 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          Text(sector.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sector.name, style: TextStyle(color: Colors.white,
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w500)),
                    Text(_formatNaira(loss), style: GoogleFonts.robotoMono(
                        color: _red, fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.bold)),
                  ]),
              const SizedBox(height: 6),
              Stack(children: [
                Container(height: 3, color: Colors.white10),
                FractionallySizedBox(widthFactor: pct / 100,
                    child: Container(height: 3, color: _red)),
              ]),
              const SizedBox(height: 4),
              Text("${pct.toStringAsFixed(0)}% of total exposure",
                  style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          )),
        ]),
      );
    }).toList();
  }

  // =========================================================================
  // QUALIFICATION GATE
  // =========================================================================
  Widget _buildQualificationGate(bool isMobile) {
    if (_qualificationOutcome == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02),
            border: Border.all(color: Colors.white10)),
        child: Text("Enter your asset data above to calculate your fuel loss exposure.",
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
      );
    }

    if (_qualificationOutcome == 1) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        decoration: BoxDecoration(
          color: _amber.withValues(alpha: 0.05),
          border: Border.all(color: _amber.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("EXPOSURE DETECTED // BELOW PRIMARY THRESHOLD",
                style: GoogleFonts.robotoMono(color: _amber, fontSize: 10,
                    fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Text("Your exposure is ${_formatNaira(_totalAnnualLoss)} — even small losses compound over time.",
                style: TextStyle(color: Colors.white,
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Over three years at this rate, you lose ${_formatNaira(_totalAnnualLoss * 3)}. A Sentinel pilot costs nothing to find out if it's worse.",
                style: GoogleFonts.poppins(color: Colors.white70,
                    fontSize: isMobile ? 13 : 15, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber, foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 32, vertical: 16),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text("REQUEST YOUR FREE PILOT ANYWAY",
                  style: GoogleFonts.robotoMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, letterSpacing: 1.2)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.05),
        border: Border.all(color: _green, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: _green,
            child: Text("QUALIFIED — PRIORITY DEPLOYMENT ELIGIBLE",
                style: GoogleFonts.robotoMono(color: Colors.black,
                    fontSize: 10, fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ),
          const SizedBox(height: 20),
          Text("Your operation is losing ${_formatNaira(_totalAnnualLoss)} per year.",
              style: TextStyle(color: Colors.white,
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("That is a preventable loss. A Sentinel telemetry deployment pays for itself in the first month of recovery. Get your full report — then apply for your free pilot.",
              style: GoogleFonts.poppins(color: Colors.white70,
                  fontSize: isMobile ? 13 : 15, height: 1.5)),
          const SizedBox(height: 32),
          _buildReportCapture(isMobile),
        ],
      ),
    );
  }

  // =========================================================================
  // REPORT CAPTURE — FIX 3: all fields use _pageFocusNode.requestFocus()
  // =========================================================================
  Widget _buildReportCapture(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SEND MY FUEL LOSS REPORT",
            style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 10,
                fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        const SizedBox(height: 16),
        isMobile
            ? Column(children: [
          _buildCaptureField("ORGANISATION", _orgNameController, _orgFocus),
          const SizedBox(height: 12),
          _buildCaptureField("EMAIL ADDRESS *", _emailController, _emailFocus),
          const SizedBox(height: 12),
          _buildCaptureField("LOCATION / STATE", _locationController, _locationFocus),
        ])
            : Row(children: [
          Expanded(child: _buildCaptureField(
              "ORGANISATION", _orgNameController, _orgFocus)),
          const SizedBox(width: 12),
          Expanded(child: _buildCaptureField(
              "EMAIL ADDRESS *", _emailController, _emailFocus)),
          const SizedBox(width: 12),
          Expanded(child: _buildCaptureField(
              "LOCATION / STATE", _locationController, _locationFocus)),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isExportingPdf ? null : _exportPdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              disabledBackgroundColor: _green.withValues(alpha: 0.4),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
            child: _isExportingPdf
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2)),
              const SizedBox(width: 12),
              Text("GENERATING YOUR REPORT...",
                  style: GoogleFonts.robotoMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, letterSpacing: 1.5)),
            ])
                : Text("EXPORT MY FUEL LOSS REPORT (PDF)",
                style: GoogleFonts.robotoMono(
                    fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 12 : 14, letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(height: 12),
        Text("Report is emailed to you. Includes sector breakdown, 3-year projection, and a direct link to request your free Sentinel pilot.",
            style: GoogleFonts.poppins(color: Colors.white24,
                fontSize: 11, height: 1.5)),
      ],
    );
  }

  // FIX 3: capture field takes FocusNode, redirects to _pageFocusNode
  Widget _buildCaptureField(
      String label, TextEditingController controller, FocusNode focusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.robotoMono(
            color: Colors.white38, fontSize: 9, letterSpacing: 2)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          // FIX 3: redirect to page node — the neutral focus owner
          onTapOutside: (_) => _pageFocusNode.requestFocus(),
          onSubmitted: (_) => _pageFocusNode.requestFocus(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white10),
                borderRadius: BorderRadius.zero),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _green),
                borderRadius: BorderRadius.zero),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}