import 'package:flutter/material.dart';

class LaunchByPatrickLogo extends StatelessWidget {
  final double height;

  const LaunchByPatrickLogo({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    final double iconSize = height * 0.9;

    // Compressed text sizes so they float within the pillar height
    final double titleFontSize = height * 0.26;
    final double byFontSize = height * 0.14; // Specifically smaller for 'BY'
    final double subtitleFontSize = height * 0.11;
    final double letterSpacing = height * 0.04;

    return Container(
      // 1. Stripped padding so it sits perfectly flush in top-left corners
      padding: EdgeInsets.zero,
      // 2. Set to transparent so it seamlessly adopts your web header's background color
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // Centers text block relative to LP logo
        children: [
          // The Monogram Vector Engine (Perfected Geometry)
          SizedBox(
            width: iconSize * 1.15,
            height: iconSize,
            child: CustomPaint(
              painter: _LPLogoPainter(),
            ),
          ),

          // 3. Closed the gap between the LP pillar and the typography
          SizedBox(width: height * 0.12), // Reduced from 0.25 to 0.12

          // The Clean Typography Engine
          IntrinsicWidth( // Forces children to match the width of the widest element
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretches the divider line
              children: [

                // LAUNCH BY PATRICK (Centered horizontally in the block)
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

                        // Floating 'BY' vertically centered
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

                // Clean Divider Line (Stretches perfectly to the edge of the text above)
                Container(
                  height: 1.2,
                  color: Colors.white.withValues(alpha: 0.7),
                ),

                SizedBox(height: height * 0.06),

                // THE WEB ARCHITECT (Centered horizontally)
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
      ..color = const Color(0xFF005CE6) // True vivid corporate blueprint blue
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    // --- 1. ARCHITECTURAL CAPITALS (Left side only, flush with gap) ---
    // Top Step
    canvas.drawRect(Rect.fromLTWH(w * 0.06, h * 0.08, w * 0.17, h * 0.05), whitePaint);
    // Lower Step
    canvas.drawRect(Rect.fromLTWH(w * 0.09, h * 0.15, w * 0.14, h * 0.04), whitePaint);

    // --- 2. LEFT OUTER PILLAR (With 45-degree angled bottom cut) ---
    final Path leftOuterPillar = Path()
      ..moveTo(w * 0.12, h * 0.21)
      ..lineTo(w * 0.23, h * 0.21)
      ..lineTo(w * 0.23, h * 0.82)
      ..lineTo(w * 0.12, h * 0.93) // Diagonal slope \
      ..close();
    canvas.drawPath(leftOuterPillar, whitePaint);

    // --- 3. BOTTOM OUTER PILLAR (With parallel 45-degree angled left cut) ---
    final Path bottomOuterPillar = Path()
      ..moveTo(w * 0.27, h * 0.86)
      ..lineTo(w * 0.48, h * 0.86)
      ..lineTo(w * 0.48, h * 0.97)
      ..lineTo(w * 0.16, h * 0.97) // Parallel diagonal slope \
      ..close();
    canvas.drawPath(bottomOuterPillar, whitePaint);

    // --- 4. INNER CORE (The main stem of the L and P) ---
    final Path innerCore = Path()
      ..moveTo(w * 0.27, h * 0.15) // Aligns exactly with the top of the lower capital
      ..lineTo(w * 0.48, h * 0.15)
      ..lineTo(w * 0.48, h * 0.82) // Aligns with bottom diagonal gap intersection
      ..lineTo(w * 0.27, h * 0.82)
      ..close();
    canvas.drawPath(innerCore, whitePaint);

    // --- 5. THE 'P' LOOP (Mathematically uniform 0.11 thickness) ---
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

    // Use PathOperation.difference to cleanly punch the inner hole out of the P
    final Path pLoop = Path.combine(PathOperation.difference, pOuter, pInner);
    canvas.drawPath(pLoop, whitePaint);

    // --- 6. BLUE GEOMETRIC SHADOW (Right Isosceles Triangle) ---
    // Nestled exactly between the bottom of the P loop and the top of the bottom pillar
    final Path blueTriangle = Path()
      ..moveTo(w * 0.48, h * 0.75) // Top-Left corner
      ..lineTo(w * 0.70, h * 0.75) // Top-Right corner
      ..lineTo(w * 0.48, h * 0.97) // Bottom-Left corner (Creates the / diagonal)
      ..close();

    canvas.drawPath(blueTriangle, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}