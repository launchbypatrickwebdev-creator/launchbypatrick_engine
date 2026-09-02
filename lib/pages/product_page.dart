// lib/pages/product_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../shared/ops_background_engine.dart';
import '../shared/launch_tactile_engine.dart';
import '../shared/launch_section_container.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/shared_site_footer.dart';
import '../data/products_data.dart'; // Bundled data layer access

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Future<void> _refreshProtocol(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (context.mounted) {
      setState(() {}); // Refreshes state indices if required
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      body: Stack(
        children: [
          // 🛰️ LAYER 01: Your Dedicated Background Video Loop
          const Positioned.fill(
            child: OpsBackgroundEngine(
              assetPath: 'assets/videos/product.mp4',
            ),
          ),

          // 🛰️ LAYER 02: Interactive Storefront Content
          LaunchTactileEngine(
            onRefresh: () => _refreshProtocol(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TopNavBar(),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Page Header Block
                      LaunchSectionContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STUDIO PRODUCTION',
                              style: GoogleFonts.robotoMono(
                                fontSize: isMobile ? 32 : 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'SOFTWARE SOURCE.',
                              style: GoogleFonts.robotoMono(
                                fontSize: isMobile ? 32 : 64,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00E5FF),
                                letterSpacing: 2.0,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'SELECT A NODE INSTANCE TO REVIEW DETAILED SPECIFICATION ARCHITECTURE.',
                              style: GoogleFonts.robotoMono(
                                color: Colors.white54,
                                fontSize: isMobile ? 10 : 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),

                      // Core Product Display Grid Mesh
                      _buildProductGrid(context),

                      const SharedSiteFooter(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 1;
    } else if (screenWidth < 1000) { crossAxisCount = 2;
    } else if (screenWidth < 1400) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return LaunchSectionContainer(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.0, // Strict design geometry square constraint
          ),
          itemCount: productsRegistry.length,
          itemBuilder: (context, index) {
            final product = productsRegistry[index];
            final String systemName = product.title.split(' : ').first;

            return InkWell(
              onTap: () {
                // 🛰️ Structural Shift: Pops entirely into GoRouter stack navigation paths
                context.push(product.detailUrl, extra: product);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0B10).withValues(alpha: 0.6),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '[ SYS_NODE_0${index + 1} ]',
                            style: GoogleFonts.robotoMono(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_outward_rounded,
                            color: Color(0xFF00E5FF),
                            size: 14,
                          ),
                        ],
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(screenWidth < 600 ? 4.0 : 0.0),
                              child: Image.asset(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.white.withValues(alpha: 0.03),
                                    child: Center(
                                      child: Icon(
                                        Icons.developer_board_rounded,
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                        size: 28,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: Colors.white10, height: 16),
                          Text(
                            '$systemName: ${product.subtitle}'.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.robotoMono(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}