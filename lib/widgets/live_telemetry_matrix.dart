// lib/widgets/live_telemetry_matrix.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiveTelemetryMatrix extends StatefulWidget {
  final Color accentColor;
  const LiveTelemetryMatrix({super.key, this.accentColor = const Color(0xFF00E5FF)});

  @override
  State<LiveTelemetryMatrix> createState() => _LiveTelemetryMatrixState();
}

class _LiveTelemetryMatrixState extends State<LiveTelemetryMatrix>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Timer _timer;
  final Random _rng = Random();

  double _throughput = 107.39;
  double _isolation  = 99.998;
  late List<double> _fin, _geo, _cdn, _sec;

  ui.Image? _earthImage;

  @override
  void initState() {
    super.initState();
    _fin = List.generate(6, (_) => 30 + _rng.nextDouble() * 50);
    _geo = List.generate(6, (_) => 40 + _rng.nextDouble() * 65);
    _cdn = List.generate(6, (_) => 20 + _rng.nextDouble() * 75);
    _sec = List.generate(6, (_) => 10 + _rng.nextDouble() * 40);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120), // one full globe revolution
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!mounted) return;
      setState(() {
        _throughput = 104 + _rng.nextDouble() * 5.8;
        _isolation  = 99.995 + _rng.nextDouble() * 0.004;
        _fin.removeAt(0); _fin.add(20 + _rng.nextDouble() * 70);
        _geo.removeAt(0); _geo.add(35 + _rng.nextDouble() * 75);
        _cdn.removeAt(0); _cdn.add(15 + _rng.nextDouble() * 85);
        _sec.removeAt(0); _sec.add(5  + _rng.nextDouble() * 50);
      });
    });

    _loadEarthAsset();
  }

  Future<void> _loadEarthAsset() async {
    try {
      // Load from assets — no CORS, no network, instant
      final ByteData data = await rootBundle.load('assets/images/earth_night.webp');
      final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo frame = await codec.getNextFrame();
      if (mounted) setState(() => _earthImage = frame.image);
    } catch (e) {
      // If asset fails, globe will render with painted fallback
      debugPrint('Earth asset load failed: $e');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _timer.cancel();
    _earthImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── HEADER ──────────────────────────────────────────────────────────
        Row(children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text("LAUNCHBYPATRICK", style: TextStyle(
              fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold,
              letterSpacing: 1.8, color: Colors.white.withValues(alpha: 0.45))),
        ]),
        const SizedBox(height: 20),

        // ── GLOBE | DATA PANELS ──────────────────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Globe
          Expanded(flex: 5, child: SizedBox(
            height: 460,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: EarthGlobePainter(
                  progress: _ctrl.value,
                  accentColor: widget.accentColor,
                  earthImage: _earthImage,
                ),
              ),
            ),
          )),
          const SizedBox(width: 24),
          // Data panels
          Expanded(flex: 4, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hdr("NETWORK TOPOLOGY MAPPING",
                  "LOGICAL ARCHITECTURE (DISTANCE INVARIANT)"),
              const SizedBox(height: 8),
              SizedBox(height: 120, child: CustomPaint(
                size: Size.infinite,
                painter: DomainTopologyPainter(accentColor: widget.accentColor),
              )),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _queues()),
                const SizedBox(width: 20),
                Expanded(child: _bands()),
              ]),
              const SizedBox(height: 20),
              _utils(),
            ],
          )),
        ]),

        const SizedBox(height: 16),

        // ── STATUS BAR ───────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          )),
          child: Row(children: [
            _stat("DATAPATH THROUGHPUT",
                "${_throughput.toStringAsFixed(2)} GB/s", "SYSTEM MAX 200 GB/s"),
            Container(width: 1, height: 35,
                color: Colors.white.withValues(alpha: 0.05)),
            _stat("ISOLATION HEALTH MATRIX",
                "${_isolation.toStringAsFixed(3)}%", "0% CRITICAL BREACH STATUS"),
          ]),
        ),
      ],
    );
  }

  Widget _stat(String l, String v, String s) => Expanded(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: TextStyle(fontFamily: 'monospace', fontSize: 9,
          color: Colors.white.withValues(alpha: 0.35), fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(v, style: const TextStyle(fontFamily: 'monospace', fontSize: 16,
          fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 2),
      Text(" $s", style: TextStyle(fontFamily: 'monospace', fontSize: 9,
          color: widget.accentColor.withValues(alpha: 0.5))),
    ]),
  ));

  Widget _queues() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _hdr("PIPELINE SERVICE QUEUES", "PROCESSING BACKLOGS"),
    const SizedBox(height: 10),
    SizedBox(height: 60, child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar("FIN", _fin.last * 0.6, Colors.cyan),
        _bar("GEO", _geo.last * 0.6, Colors.white),
        _bar("CDN", _cdn.last * 0.6, widget.accentColor),
        _bar("SEC", _sec.last * 0.6, Colors.redAccent),
      ],
    )),
  ]);

  Widget _bands() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _hdr("SYSTEM BAND CAPACITIES", "FREQUENCY FREIGHT LIMITS"),
    const SizedBox(height: 10),
    SizedBox(height: 60, child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar("X-BAND", 38, const Color(0xFF00B0FF)),
        _bar("K-BAND", 58, const Color(0xFF00E676)),
      ],
    )),
  ]);

  Widget _utils() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _hdr("REAL-TIME PIPELINE UTILITIES", "CROSS-REFERENCE FREQUENCY MATRIX"),
    const SizedBox(height: 12),
    SizedBox(height: 40, child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ..._fin.map((v) => _dot(v, Colors.cyan)),
        ..._geo.map((v) => _dot(v, Colors.white)),
        ..._cdn.map((v) => _dot(v, widget.accentColor)),
        ..._sec.map((v) => _dot(v, Colors.redAccent)),
      ],
    )),
    const SizedBox(height: 8),
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      _leg("FIN", Colors.cyan), const SizedBox(width: 12),
      _leg("GEO", Colors.white), const SizedBox(width: 12),
      _leg("CDN", widget.accentColor), const SizedBox(width: 12),
      _leg("SEC", Colors.redAccent),
    ]),
  ]);

  Widget _bar(String l, double h, Color c) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(width: 24, height: h.clamp(4.0, 50.0),
          color: c.withValues(alpha: 0.85)),
      const SizedBox(height: 6),
      Text(l, style: TextStyle(fontFamily: 'monospace', fontSize: 8,
          color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
    ],
  );

  Widget _dot(double v, Color c) => Container(
      width: 4, height: (v * 0.4).clamp(4.0, 40.0),
      color: c.withValues(alpha: (v / 100).clamp(0.25, 0.95)));

  Widget _leg(String t, Color c) => Row(children: [
    Container(width: 6, height: 6, color: c),
    const SizedBox(width: 4),
    Text(t, style: TextStyle(fontFamily: 'monospace', fontSize: 8,
        color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
  ]);

  Widget _hdr(String a, String b) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(a, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
          color: Colors.white.withValues(alpha: 0.35),
          fontFamily: 'monospace', letterSpacing: 0.5)),
      Text("// $b", style: TextStyle(fontSize: 7.5,
          color: widget.accentColor.withValues(alpha: 0.45), fontFamily: 'monospace')),
    ],
  );
}

// =============================================================================
// EARTH GLOBE PAINTER
//
// Layout matches AiRANACULUS exactly:
//  • Earth photo clipped to circle — static image, globe rotates via
//    a subtle cloud-shimmer overlay drawn in code
//  • Moon: FIXED bottom-left, does NOT orbit — only its rings animate
//  • Three orbital ellipses with YELLOW dots orbit around the MOON
//  • Two RED anchor dots on Earth (at fixed pixel positions on the photo)
//  • Blue dot = moon relay station
//  • Thick yellow-green data beams from moon-blue-dot → each red Earth dot
// =============================================================================
class EarthGlobePainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final ui.Image? earthImage;

  EarthGlobePainter({
    required this.progress,
    required this.accentColor,
    this.earthImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Globe: slightly smaller — server node hangs below-left
    final double R = size.height * 0.33;
    final Offset gc = Offset(size.width * 0.54, size.height * 0.42);

    // ── STAR FIELD ────────────────────────────────────────────────────────────
    final rng = Random(13);
    for (int i = 0; i < 110; i++) {
      final double sx = rng.nextDouble() * size.width;
      final double sy = rng.nextDouble() * size.height;
      // Don't draw stars inside or immediately around the globe
      if ((Offset(sx, sy) - gc).distance > R + 20) {
        canvas.drawCircle(Offset(sx, sy), rng.nextDouble() * 1.1,
            Paint()..color = Colors.white.withValues(
                alpha: 0.20 + rng.nextDouble() * 0.55));
      }
    }

    // ── ATMOSPHERE HALO ───────────────────────────────────────────────────────
    canvas.drawCircle(gc, R * 1.07, Paint()
      ..shader = RadialGradient(
        center: Alignment.center, radius: 1.0,
        colors: [
          const Color(0xFF1A5090).withValues(alpha: 0.0),
          const Color(0xFF0D2A5A).withValues(alpha: 0.18),
          const Color(0xFF061020).withValues(alpha: 0.60),
        ],
        stops: const [0.68, 0.86, 1.0],
      ).createShader(Rect.fromCircle(center: gc, radius: R * 1.07)));

    // ── CLIP TO GLOBE & DRAW EQUIRECTANGULAR MAP ─────────────────────────────
    // The NASA Black Marble map is equirectangular (flat rectangle, 2:1 ratio).
    // Scrolling it horizontally inside a circle simulates a spinning globe.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: gc, radius: R - 0.5)));

    if (earthImage != null) {
      final ui.Image img = earthImage!;
      final double iw = img.width.toDouble();
      final double ih = img.height.toDouble();

      // ── SCALE: fit the map height to the globe diameter ─────────────────────
      // Equirectangular maps are 2:1 (width = 2 × height).
      // We scale so the image HEIGHT = globe diameter (2R).
      // This means the image WIDTH = 4R (two full globe widths visible at once).
      // We only ever see a ~half-width window through the circle clip.
      final double scale = (R * 2) / ih;   // scale so height = 2R
      final double dstW  = iw * scale;     // scaled width  (= 4R for 2:1 map)
      final double dstH  = ih * scale;     // scaled height (= 2R)

      // Centre the map vertically on gc (equator at centre of circle)
      // final double imgTop = gc.dy - R;     // top of scaled image

      // ── SMOOTH 360° ROTATION — no loop, no jump ───────────────────────────
      // progress runs 0→1 continuously from AnimationController.repeat().
      // One full progress cycle = one full globe revolution (360°).
      // No modulo needed — progress itself is already seamless.
      // scrollOffset 0→dstW as progress 0→1, then instantly back to 0
      // at the next repeat — but because we draw TWO copies side by side,
      // the seam between the right edge and left edge of the map is always
      // filled, so the reset is completely invisible.
      final double scrollOffset = progress * dstW;

      final double imgLeft = gc.dx - (dstW * 0.25) - scrollOffset;
      final double imgTop  = gc.dy - R;

      canvas.drawImageRect(img, Rect.fromLTWH(0, 0, iw, ih),
          Rect.fromLTWH(imgLeft, imgTop, dstW, dstH), Paint());
      canvas.drawImageRect(img, Rect.fromLTWH(0, 0, iw, ih),
          Rect.fromLTWH(imgLeft + dstW, imgTop, dstW, dstH), Paint());

    } else {
      // ── FALLBACK painted globe ───────────────────────────────────────────────
      canvas.drawCircle(gc, R, Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.35), radius: 1.0,
          colors: const [
            Color(0xFF1B3A6B), Color(0xFF0E2244), Color(0xFF060D1C)],
        ).createShader(Rect.fromCircle(center: gc, radius: R)));
    }

    // ── SPHERICAL VIGNETTE — makes the flat map look like a 3D globe ─────────
    // Strong dark limb around the edges, like real Earth from space.
    canvas.drawCircle(gc, R, Paint()
      ..shader = RadialGradient(
        center: Alignment.center, radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.25),
          Colors.black.withValues(alpha: 0.80),
        ],
        stops: const [0.0, 0.55, 0.78, 1.0],
      ).createShader(Rect.fromCircle(center: gc, radius: R)));

    // Subtle blue atmospheric tint at the limb
    canvas.drawCircle(gc, R, Paint()
      ..shader = RadialGradient(
        center: Alignment.center, radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.transparent,
          const Color(0xFF0D3A6A).withValues(alpha: 0.15),
          const Color(0xFF1565C0).withValues(alpha: 0.40),
        ],
        stops: const [0.0, 0.65, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: gc, radius: R)));

    // Specular sun-glint upper-left
    canvas.drawCircle(gc, R, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.40, -0.46), radius: 0.42,
        colors: [
          Colors.white.withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: gc, radius: R)));

    canvas.restore(); // end globe clip

    // Globe rim
    canvas.drawCircle(gc, R, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.12));

    // ── RED ANCHOR DOTS — scroll WITH the globe ───────────────────────────────
    // Same scroll speed and offset as the image so nodes stay on their cities.
    // earthImage dimensions drive the same dstW used for the image draw.
    final double nodeImgW = earthImage != null
        ? earthImage!.width.toDouble() * ((R * 2) / earthImage!.height.toDouble())
        : R * 4;
    // Same formula as image: no modulo, direct progress drive
    final double nodeScroll = progress * nodeImgW;
    final double nodeOriginX = gc.dx - (nodeImgW * 0.25);

    // Map geographic positions to pixel X on the unscrolled image.
    // Equirectangular: lon -180..180 maps left..right across the image width.
    // We place nodes at their real lon/lat, converted to canvas coords.
    Offset geoToCanvas(double lon, double lat) {
      // Normalised 0..1 position in the equirectangular image
      final double normX = (lon + 180.0) / 360.0;
      final double normY = (90.0 - lat) / 180.0;
      // Canvas position before scroll
      final double baseX = nodeOriginX + normX * nodeImgW;
      final double baseY = gc.dy - R + normY * (R * 2);
      // Apply scroll (shift left)
      double scrolledX = baseX - nodeScroll;
      // Wrap: keep within one image width of the visible area
      while (scrolledX < gc.dx - R * 1.5) { scrolledX += nodeImgW; }
      while (scrolledX > gc.dx + R * 1.5 + nodeImgW) { scrolledX -= nodeImgW; }
      return Offset(scrolledX, baseY);
    }

    // Your real business node locations
    final Offset lagosPos = geoToCanvas(3.4,   6.5);   // Lagos, Nigeria
    final Offset lonPos   = geoToCanvas(-0.1, 51.5);   // London, UK
    final Offset sgpPos   = geoToCanvas(103.8, 1.3);   // Singapore
    final Offset nycPos   = geoToCanvas(-74.0, 40.7);  // New York

    bool onFront(Offset pos) => (pos - gc).distance < R * 0.96;

    void redAnchor(Offset pos) {
      if (!onFront(pos)) return;
      canvas.drawCircle(pos, 9.5 + 3.0 * sin(progress * 6 * pi).abs(),
          Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0
            ..color = Colors.redAccent.withValues(alpha: 0.30));
      canvas.drawCircle(pos, 6.0, Paint()..color = Colors.redAccent);
      canvas.drawCircle(pos, 2.5,
          Paint()..color = Colors.white.withValues(alpha: 0.70));
    }
    redAnchor(lagosPos);
    redAnchor(lonPos);
    redAnchor(sgpPos);
    redAnchor(nycPos);

    // ── SERVER NODE — hexagonal data center hub, bottom-left ─────────────────
    // Replaces the moon. This is LaunchByPatrick's core infrastructure node —
    // a dark hexagonal server cluster with circuit traces and cyan glow,
    // with three orbital rings representing active traffic routing around it.
    final Offset hub = Offset(gc.dx - R * 1.02, gc.dy + R * 0.80);
    const double hR = 40.0; // hexagon circumradius

    // Helper: get the 6 vertices of a regular hexagon
    List<Offset> hexPoints(Offset centre, double r, {double rotation = 0}) {
      return List.generate(6, (i) {
        final double a = rotation + (i * pi / 3);
        return Offset(centre.dx + r * cos(a), centre.dy + r * sin(a));
      });
    }

    Path hexPath(Offset centre, double r, {double rotation = 0}) {
      final pts = hexPoints(centre, r, rotation: rotation);
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < 6; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      return path..close();
    }

    // Outer glow pulse
    for (int g = 3; g >= 1; g--) {
      final double glowR = hR + 12.0 + g * 6.0 +
          4.0 * sin(progress * 2 * pi).abs();
      canvas.drawPath(hexPath(hub, glowR, rotation: pi / 6),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = accentColor.withValues(alpha: 0.06 * g));
    }

    // Dark filled body
    canvas.drawPath(hexPath(hub, hR, rotation: pi / 6),
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF050D14));

    // Inner gradient — subtle blue glow from top-left
    canvas.drawPath(hexPath(hub, hR, rotation: pi / 6),
        Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.4), radius: 1.0,
            colors: [
              accentColor.withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: hub, radius: hR)));

    // ── CIRCUIT TRACES inside the hexagon ────────────────────────────────────
    final Paint circuitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = accentColor.withValues(alpha: 0.35);

    // Horizontal server rack lines
    for (int row = -2; row <= 2; row++) {
      final double y = hub.dy + row * 7.0;
      final double halfW = hR * 0.62;
      canvas.drawLine(Offset(hub.dx - halfW, y), Offset(hub.dx + halfW, y),
          circuitPaint);
    }

    // Vertical bus lines
    for (int col = -2; col <= 2; col++) {
      final double x = hub.dx + col * 8.0;
      canvas.drawLine(Offset(x, hub.dy - hR * 0.55), Offset(x, hub.dy + hR * 0.55),
          circuitPaint);
    }

    // Circuit corner nodes (junction dots)
    final circuitDot = Paint()..color = accentColor.withValues(alpha: 0.55);
    for (final dx in [-16.0, 0.0, 16.0]) {
      for (final dy in [-14.0, 0.0, 14.0]) {
        canvas.drawCircle(Offset(hub.dx + dx, hub.dy + dy), 1.8, circuitDot);
      }
    }

    // Animated data pulse — a glowing dot that moves along one circuit trace
    final double pulseX = hub.dx - hR * 0.62 +
        (hR * 1.24) * ((progress * 2.5) % 1.0);
    canvas.drawCircle(Offset(pulseX, hub.dy - 7),
        3.0,
        Paint()..color = accentColor.withValues(alpha: 0.90)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0));

    // Second pulse on a different trace, offset phase
    final double pulseX2 = hub.dx + hR * 0.62 -
        (hR * 1.24) * (((progress * 2.5) + 0.5) % 1.0);
    canvas.drawCircle(Offset(pulseX2, hub.dy + 7),
        2.5,
        Paint()..color = const Color(0xFF00FF88).withValues(alpha: 0.80)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0));

    // Hexagon border — cyan stroke
    canvas.drawPath(hexPath(hub, hR, rotation: pi / 6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = accentColor.withValues(alpha: 0.75));

    // Inner hexagon — smaller, rotated 30°, faint
    canvas.drawPath(hexPath(hub, hR * 0.55, rotation: 0),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = accentColor.withValues(alpha: 0.25));

    // ── THREE ORBITAL RINGS — active traffic routing orbits ───────────────────
    // Represent live request traffic circulating around the server node.
    // Cyan/green dots = active request packets being routed globally.
    void hubOrbit({
      required double tilt, required double rx, required double ry,
      required double phase, required double dir, required Color dotColor,
    }) {
      canvas.save();
      canvas.translate(hub.dx, hub.dy);
      canvas.rotate(tilt);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
          Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0
            ..color = accentColor.withValues(alpha: 0.30));
      final double a = (progress + phase) * 2 * pi * dir;
      final Offset dotPos = Offset(rx * cos(a), ry * sin(a));
      // Glowing packet dot
      canvas.drawCircle(dotPos, 5.5,
          Paint()..color = dotColor
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5));
      canvas.drawCircle(dotPos, 3.0,
          Paint()..color = Colors.white.withValues(alpha: 0.80));
      canvas.restore();
    }
    hubOrbit(tilt: -0.32, rx: hR*2.0, ry: hR*0.65, phase: 0.0,  dir:  1.0,
        dotColor: accentColor);
    hubOrbit(tilt:  0.52, rx: hR*2.2, ry: hR*0.85, phase: 0.33, dir: -1.0,
        dotColor: const Color(0xFF00FF88));
    hubOrbit(tilt:  1.22, rx: hR*1.80, ry: hR*1.50, phase: 0.66, dir:  1.0,
        dotColor: const Color(0xFFFFDD00));

    // ── RELAY POINT — beam origin at hex centre ───────────────────────────────
    final Offset hubRelay = hub;
    // Pulsing core dot
    canvas.drawCircle(hubRelay,
        6.0 + 2.0 * sin(progress * 4 * pi).abs(),
        Paint()..color = accentColor.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0));
    canvas.drawCircle(hubRelay, 5.0, Paint()..color = accentColor);
    canvas.drawCircle(hubRelay, 2.5,
        Paint()..color = Colors.white.withValues(alpha: 0.90));

    // ── DATA BEAMS: hub → visible ground nodes ────────────────────────────────
    void beam(Offset from, Offset to) {
      canvas.drawLine(from, to, Paint()
        ..strokeWidth = 5.5..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFDD00).withValues(alpha: 0.68));
      canvas.drawLine(from, to, Paint()
        ..strokeWidth = 2.8..strokeCap = StrokeCap.round
        ..color = const Color(0xFF00FF88).withValues(alpha: 0.90));
      canvas.drawLine(from, to, Paint()
        ..strokeWidth = 0.9..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.55));
    }
    if (onFront(lagosPos)) beam(hubRelay, lagosPos);
    if (onFront(sgpPos))   beam(hubRelay, sgpPos);
    if (onFront(lonPos))   beam(hubRelay, lonPos);
    if (onFront(nycPos))   beam(hubRelay, nycPos);

    // ── LEGEND ────────────────────────────────────────────────────────────────
    void legend(double y, Color c, String lbl) {
      final double lx = size.width - 52.0;
      canvas.drawRect(Rect.fromLTWH(lx, y + 1, 6, 6),
          Paint()..color = c.withValues(alpha: 0.85));
      (TextPainter(
          text: TextSpan(text: lbl, style: TextStyle(
              fontFamily: 'monospace', fontSize: 8.5, fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.42))),
          textDirection: TextDirection.ltr)..layout())
          .paint(canvas, Offset(lx + 12, y));
    }
    legend(16, Colors.cyan,      "FIN");
    legend(32, Colors.white,     "GEO");
    legend(48, accentColor,      "CDN");
    legend(64, Colors.redAccent, "SEC");
  }

  @override
  bool shouldRepaint(covariant EarthGlobePainter old) =>
      old.progress != progress || old.earthImage != earthImage;
}

// =============================================================================
// DOMAIN TOPOLOGY PAINTER
// =============================================================================
class DomainTopologyPainter extends CustomPainter {
  final Color accentColor;
  DomainTopologyPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0;
    final n = Paint()..style = PaintingStyle.fill;
    final double lx = size.width*0.12, cx = size.width*0.45, rx = size.width*0.82;
    final Offset core = Offset(lx, size.height*0.5);
    final fw = List.generate(4, (i) => Offset(cx, size.height*(0.2+i*0.2)));
    final hubs = List.generate(3, (i) => Offset(rx, size.height*(0.25+i*0.25)));
    final labels = ["Ka Lae (Hub Alpha)", "Singapore (Hub Beta)", "White Sands (Vault)"];
    final fc = [Colors.cyan, Colors.white, accentColor, Colors.redAccent];

    p.color = Colors.white.withValues(alpha: 0.035);
    for (var f in fw) {
      canvas.drawLine(core, f, p);
      for (var h in hubs) { canvas.drawLine(f, h, p); }
    }
    p.strokeWidth = 1.2;
    for (int i=0; i<fw.length; i++) {
      p.color = fc[i].withValues(alpha: 0.65);
      canvas.drawLine(core, fw[i], p);
    }
    p.color=fc[0].withValues(alpha:0.65); canvas.drawLine(fw[0],hubs[0],p);
    p.color=fc[1].withValues(alpha:0.65); canvas.drawLine(fw[1],hubs[1],p);
    p.color=fc[2].withValues(alpha:0.65); canvas.drawLine(fw[2],hubs[1],p);
    p.color=fc[3].withValues(alpha:0.65); canvas.drawLine(fw[3],hubs[2],p);

    n.color = accentColor; canvas.drawCircle(core, 3.5, n);
    for (int i=0; i<fw.length; i++) { n.color=fc[i]; canvas.drawCircle(fw[i],3.0,n); }
    for (int i=0; i<hubs.length; i++) {
      n.color = i==2 ? Colors.redAccent : Colors.redAccent.withValues(alpha:0.4);
      canvas.drawCircle(hubs[i], 3.0, n);
      (TextPainter(
          text: TextSpan(text: labels[i], style: TextStyle(
              fontFamily: 'monospace', fontSize: 7.5,
              fontWeight: i==2 ? FontWeight.bold : FontWeight.normal,
              color: i==2 ? Colors.white : Colors.white38)),
          textDirection: TextDirection.ltr)..layout())
          .paint(canvas, Offset(hubs[i].dx+8, hubs[i].dy-4));
    }
  }

  @override
  bool shouldRepaint(covariant DomainTopologyPainter old) => false;
}