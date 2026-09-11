import 'package:flutter/material.dart';

// ============================================================
// SMART LOGO SWITCHER
// ============================================================
class SiteLogo extends StatelessWidget {
  final double height;
  final bool isSentinel;

  const SiteLogo({
    super.key,
    this.height = 70,
    this.isSentinel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSentinel) {
      // ========== SWITCH SENTINEL VERSION HERE ==========
      // return EchoLevelSentinelLogoV1(height: height); // ← Currently active
       return EchoLevelSentinelLogoV2(height: height);
      // return EchoLevelSentinelLogoV3(height: height);
    } else {
      return LaunchByPatrickLogo(height: height);
    }
  }
}

// ============================================================
// LAUNCH BY PATRICK LOGO
// ============================================================
class LaunchByPatrickLogo extends StatelessWidget {
  final double height;

  const LaunchByPatrickLogo({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    final double iconSize = height * 0.9;
    final double titleFontSize = height * 0.26;
    final double byFontSize = height * 0.14;
    final double subtitleFontSize = height * 0.11;
    final double letterSpacing = height * 0.04;

    return Container(
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: iconSize * 1.15,
            height: iconSize,
            child: CustomPaint(
              painter: _LPLogoPainter(),
            ),
          ),
          SizedBox(width: height * 0.12),
          IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'LAUNCH',
                          style: TextStyle(
                            fontFamily: 'sans-serif',
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: height * 0.06),
                            child: Text(
                              'BY',
                              style: TextStyle(
                                fontFamily: 'sans-serif',
                                fontSize: byFontSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: 'PATRICK',
                          style: TextStyle(
                            fontFamily: 'sans-serif',
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
                Container(
                  height: 1.2,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                SizedBox(height: height * 0.06),
                Center(
                  child: Text(
                    'THE WEB ARCHITECT',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: letterSpacing,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LPLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF005CE6)
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    // Top Step
    canvas.drawRect(Rect.fromLTWH(w * 0.06, h * 0.08, w * 0.17, h * 0.05), whitePaint);
    // Lower Step
    canvas.drawRect(Rect.fromLTWH(w * 0.09, h * 0.15, w * 0.14, h * 0.04), whitePaint);

    // Left Outer Pillar
    final Path leftOuterPillar = Path()
      ..moveTo(w * 0.12, h * 0.21)
      ..lineTo(w * 0.23, h * 0.21)
      ..lineTo(w * 0.23, h * 0.82)
      ..lineTo(w * 0.12, h * 0.93)
      ..close();
    canvas.drawPath(leftOuterPillar, whitePaint);

    // Bottom Outer Pillar
    final Path bottomOuterPillar = Path()
      ..moveTo(w * 0.27, h * 0.86)
      ..lineTo(w * 0.48, h * 0.86)
      ..lineTo(w * 0.48, h * 0.97)
      ..lineTo(w * 0.16, h * 0.97)
      ..close();
    canvas.drawPath(bottomOuterPillar, whitePaint);

    // Inner Core
    final Path innerCore = Path()
      ..moveTo(w * 0.27, h * 0.15)
      ..lineTo(w * 0.48, h * 0.15)
      ..lineTo(w * 0.48, h * 0.82)
      ..lineTo(w * 0.27, h * 0.82)
      ..close();
    canvas.drawPath(innerCore, whitePaint);

    // P Loop
    final Path pOuter = Path()
      ..moveTo(w * 0.48, h * 0.15)
      ..lineTo(w * 0.72, h * 0.15)
      ..cubicTo(w * 0.98, h * 0.15, w * 0.98, h * 0.64, w * 0.72, h * 0.64)
      ..lineTo(w * 0.48, h * 0.64)
      ..close();

    final Path pInner = Path()
      ..moveTo(w * 0.48, h * 0.26)
      ..lineTo(w * 0.65, h * 0.26)
      ..cubicTo(w * 0.87, h * 0.26, w * 0.87, h * 0.53, w * 0.65, h * 0.53)
      ..lineTo(w * 0.48, h * 0.53)
      ..close();

    final Path pLoop = Path.combine(PathOperation.difference, pOuter, pInner);
    canvas.drawPath(pLoop, whitePaint);

    // Blue Triangle
    final Path blueTriangle = Path()
      ..moveTo(w * 0.48, h * 0.75)
      ..lineTo(w * 0.70, h * 0.75)
      ..lineTo(w * 0.48, h * 0.97)
      ..close();
    canvas.drawPath(blueTriangle, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// ECHOLEVEL SENTINEL - VERSION 1 (Clean Technical Cross)
// ============================================================
/*
class EchoLevelSentinelLogoV1 extends StatelessWidget {
  final double height;

  const EchoLevelSentinelLogoV1({super.key, this.height = 70});

  @override
  Widget build(BuildContext context) {
    final double iconSize = height * 0.95;
    final double titleSize = height * 0.28;
    final double subtitleSize = height * 0.13;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _SentinelCrossPainterV1(),
          ),
        ),
        SizedBox(width: height * 0.18),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ECHOLEVEL SENTINEL LTD",
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: height * 0.04),
            Text(
              "INDUSTRIAL IoT & ASSET MONITORING",
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: subtitleSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00C853),
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SentinelCrossPainterV1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final Paint greenStroke = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeJoin = StrokeJoin.round;

    final Paint darkFill = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final Path cross = Path();
    final double armW = w * 0.18;
    final double armL = w * 0.42;

    cross.moveTo(cx - armW / 2, cy - armL);
    cross.lineTo(cx + armW / 2, cy - armL);
    cross.lineTo(cx + armW / 2, cy - armW / 2);
    cross.lineTo(cx + armL, cy - armW / 2);
    cross.lineTo(cx + armL, cy + armW / 2);
    cross.lineTo(cx + armW / 2, cy + armW / 2);
    cross.lineTo(cx + armW / 2, cy + armL);
    cross.lineTo(cx - armW / 2, cy + armL);
    cross.lineTo(cx - armW / 2, cy + armW / 2);
    cross.lineTo(cx - armL, cy + armW / 2);
    cross.lineTo(cx - armL, cy - armW / 2);
    cross.lineTo(cx - armW / 2, cy - armW / 2);
    cross.close();

    canvas.drawPath(cross, darkFill);
    canvas.drawPath(cross, greenStroke);

    canvas.drawCircle(Offset(cx, cy), w * 0.16, darkFill);
    canvas.drawCircle(Offset(cx, cy), w * 0.16, greenStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
 */

// ============================================================
// ECHOLEVEL SENTINEL - VERSION 2 (Soft Industrial Cross)
// Currently commented out – uncomment to use
// ============================================================
///*
class EchoLevelSentinelLogoV2 extends StatelessWidget {
  final double height;

  const EchoLevelSentinelLogoV2({super.key, this.height = 70});

  @override
  Widget build(BuildContext context) {
    final double iconSize = height * 0.95;
    final double titleSize = height * 0.28;
    final double subtitleSize = height * 0.13;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _SentinelCrossPainterV2(),
          ),
        ),
        SizedBox(width: height * 0.18),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ECHOLEVEL SENTINEL LTD",
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: height * 0.04),
            Text(
              "INDUSTRIAL IoT & ASSET MONITORING",
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: subtitleSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00C853),
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SentinelCrossPainterV2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final Paint greenStroke = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final Paint darkFill = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final Path cross = Path();
    final double armW = w * 0.22;
    final double armL = w * 0.40;

    cross.moveTo(cx - armW / 2, cy - armL);
    cross.quadraticBezierTo(cx, cy - armL - armW * 0.15, cx + armW / 2, cy - armL);
    cross.lineTo(cx + armW / 2, cy - armW / 2);
    cross.quadraticBezierTo(cx + armL + armW * 0.1, cy, cx + armL, cy + armW / 2);
    cross.lineTo(cx + armW / 2, cy + armW / 2);
    cross.quadraticBezierTo(cx, cy + armL + armW * 0.15, cx - armW / 2, cy + armL);
    cross.lineTo(cx - armW / 2, cy + armW / 2);
    cross.quadraticBezierTo(cx - armL - armW * 0.1, cy, cx - armL, cy - armW / 2);
    cross.lineTo(cx - armW / 2, cy - armW / 2);
    cross.close();

    canvas.drawPath(cross, darkFill);
    canvas.drawPath(cross, greenStroke);

    canvas.drawCircle(Offset(cx, cy), w * 0.15, darkFill);
    canvas.drawCircle(Offset(cx, cy), w * 0.15, greenStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
//*/

// ============================================================
// ECHOLEVEL SENTINEL - VERSION 3 (Shield Cross Hybrid)
// Currently commented out – uncomment to use
// ============================================================
/*
class EchoLevelSentinelLogoV3 extends StatelessWidget {
  final double height;

  const EchoLevelSentinelLogoV3({super.key, this.height = 70});

  @override
  Widget build(BuildContext context) {
    final double iconSize = height * 0.95;
    final double titleSize = height * 0.28;
    final double subtitleSize = height * 0.13;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _SentinelCrossPainterV3(),
          ),
        ),
        SizedBox(width: height * 0.18),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ECHOLEVEL SENTINEL LTD",
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: height * 0.04),
            Text(
              "INDUSTRIAL IoT & ASSET MONITORING",
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: subtitleSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00C853),
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SentinelCrossPainterV3 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final Paint greenStroke = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeJoin = StrokeJoin.round;

    final Paint darkFill = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    // Outer shield
    final Path shield = Path();
    final double s = w * 0.42;
    shield.moveTo(cx, cy - s);
    shield.lineTo(cx + s * 0.7, cy - s * 0.7);
    shield.lineTo(cx + s, cy);
    shield.lineTo(cx + s * 0.7, cy + s * 0.7);
    shield.lineTo(cx, cy + s);
    shield.lineTo(cx - s * 0.7, cy + s * 0.7);
    shield.lineTo(cx - s, cy);
    shield.lineTo(cx - s * 0.7, cy - s * 0.7);
    shield.close();

    canvas.drawPath(shield, darkFill);
    canvas.drawPath(shield, greenStroke);

    // Inner cross
    final Path cross = Path();
    final double armW = w * 0.14;
    final double armL = w * 0.32;

    cross.moveTo(cx - armW / 2, cy - armL);
    cross.lineTo(cx + armW / 2, cy - armL);
    cross.lineTo(cx + armW / 2, cy - armW / 2);
    cross.lineTo(cx + armL, cy - armW / 2);
    cross.lineTo(cx + armL, cy + armW / 2);
    cross.lineTo(cx + armW / 2, cy + armW / 2);
    cross.lineTo(cx + armW / 2, cy + armL);
    cross.lineTo(cx - armW / 2, cy + armL);
    cross.lineTo(cx - armW / 2, cy + armW / 2);
    cross.lineTo(cx - armL, cy + armW / 2);
    cross.lineTo(cx - armL, cy - armW / 2);
    cross.lineTo(cx - armW / 2, cy - armW / 2);
    cross.close();

    canvas.drawPath(cross, darkFill);
    canvas.drawPath(cross, greenStroke);

    canvas.drawCircle(Offset(cx, cy), w * 0.13, darkFill);
    canvas.drawCircle(Offset(cx, cy), w * 0.13, greenStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/