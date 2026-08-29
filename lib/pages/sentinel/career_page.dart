import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/launch_section_container.dart';
import '../../shared/launch_tactile_engine.dart';
import '../../shared/ops_background_engine.dart';
import '../../widgets/sentinel_nav_bar.dart';
import '../../widgets/shared_site_footer.dart';

class CareerPage extends StatefulWidget {
  const CareerPage({super.key});

  @override
  State<CareerPage> createState() => _CareerPageState();
}

class _CareerPageState extends State<CareerPage> {
  Future<void> _pageRefresh(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (context.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFFD500F9);
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF07080C),
      body: Stack(
        children: [
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/videos/sentinel_matrix_loop.mp4',
            ),
          ),
          LaunchTactileEngine(
            onRefresh: () => _pageRefresh(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SentinelNavBar(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    LaunchSectionContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: accentColor.withValues(alpha: 0.15),
                            child: Text(
                              "FOUNDER METRICS // ARCHITECT TRAJECTORY",
                              style: GoogleFonts.robotoMono(
                                color: accentColor,
                                fontSize: isMobile ? 8 : 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'FOUNDER PORTFOLIO &',
                            style: TextStyle(fontSize: isMobile ? 32 : 54, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5, height: 1.1),
                          ),
                          Text(
                            'PERSONAL CAREER.',
                            style: TextStyle(fontSize: isMobile ? 32 : 54, fontWeight: FontWeight.bold, color: accentColor, letterSpacing: 1.5, height: 1.1),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Professional track records, deployment historical metrics, and architectural build methodologies as a project founder.',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: isMobile ? 12 : 16, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                    LaunchSectionContainer(
                      mobileHeight: 280,
                      desktopHeight: 400,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF031B3B).withValues(alpha: 0.2),
                          border: Border.all(color: accentColor.withValues(alpha: 0.15)),
                        ),
                        child: Center(
                          child: Text(
                            '[ CHRONOLOGICAL PROFESSIONAL TIMELINE PLACEHOLDER ]',
                            style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: isMobile ? 12 : 16),
                          ),
                        ),
                      ),
                    ),
                    const StickyFooterSpacer(),
                    const SharedSiteFooter(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}