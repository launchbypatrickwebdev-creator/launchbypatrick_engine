// lib/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/launch_tactile_engine.dart';
import '../shared/launch_section_container.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/shared_site_footer.dart';
import '../data/products_data.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductItem product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late String _selectedMediaView;
  bool _isVideoActive = false;

  @override
  void initState() {
    super.initState();
    _selectedMediaView = widget.product.imageUrl;
  }

  Future<void> _executeExternalLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      body: Stack(
        children: [
          // 🛰️ LAYER 01: High-Res Static Architecture Canvas Backing
          Positioned.fill(
            child: Image.asset(
              'assets/images/industrial_bg.webp',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xFF0A0B10).withValues(alpha: 0.94)),
          ),

          // 🛰️ LAYER 02: Interactive E-Commerce Interface Viewport
          LaunchTactileEngine(
            onRefresh: () async => await Future.delayed(const Duration(milliseconds: 200)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TopNavBar(),
                  const SizedBox(height: 24),

                  // Navigation Context Trace
                  LaunchSectionContainer(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 12),
                          color: const Color(0xFF00E5FF),
                          onPressed: () => context.pop(),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            'PLATFORM INDEX',
                            style: GoogleFonts.robotoMono(
                              color: Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Text(
                          '  /  ${widget.product.id.toUpperCase()}',
                          style: GoogleFonts.robotoMono(color: Colors.white12, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🏗️ UNBOXED PANEL CONFIGURATION: Media Block vs Purchase Spec Column
                  LaunchSectionContainer(
                    child: isMobile
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInteractiveGalleryHub(isMobile),
                        const SizedBox(height: 40),
                        _buildCommercialSpecificationColumn(isMobile),
                      ],
                    )
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildInteractiveGalleryHub(isMobile)),
                        const SizedBox(width: 50),
                        Expanded(flex: 6, child: _buildCommercialSpecificationColumn(isMobile)),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white10, height: 80),

                  // 🏗️ INDUSTRIAL COMPONENT MATRIX LAYER (Technical Specification Sheet)
                  LaunchSectionContainer(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: _buildMassiveECommerceDescriptionBlock(),
                    ),
                  ),

                  const SharedSiteFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Multi-Asset Dynamic Gallery Engine (1 Primary Display + 5 Strip Selectors)
  Widget _buildInteractiveGalleryHub(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: Container(
            color: const Color(0xFF07080C),
            child: _isVideoActive
                ? Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, color: Color(0xFF00E5FF), size: 54),
                    const SizedBox(height: 12),
                    Text(
                      "INITIALIZING INTEGRATED STUDIO STREAM PREVIEW...",
                      style: GoogleFonts.robotoMono(color: const Color(0xFF00E5FF), fontSize: 10, letterSpacing: 1.0),
                    ),
                  ],
                ),
              ),
            )
                : Image.asset(
              _selectedMediaView,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.developer_board_rounded, color: Colors.white10, size: 48),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Media Asset Selection Track
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (widget.product.videoAssetPath != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: InkWell(
                    onTap: () => setState(() => _isVideoActive = true),
                    child: Container(
                      width: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07080C),
                        border: Border.all(
                          color: _isVideoActive ? const Color(0xFF00E5FF) : Colors.white10,
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.video_library_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                    ),
                  ),
                ),

              ...widget.product.mediaGallery.map((imgUrl) {
                final bool isSelected = (_selectedMediaView == imgUrl) && !_isVideoActive;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: InkWell(
                    onTap: () => setState(() {
                      _selectedMediaView = imgUrl;
                      _isVideoActive = false;
                    }),
                    child: Container(
                      width: 78,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00E5FF) : Colors.white10,
                          width: 1.5,
                        ),
                      ),
                      child: Image.asset(imgUrl, fit: BoxFit.cover),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Core Pricing/Action Target Matrix block
  Widget _buildCommercialSpecificationColumn(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.title,
          style: GoogleFonts.robotoMono(
            color: Colors.white,
            fontSize: isMobile ? 24 : 34,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.product.subtitle.toUpperCase(),
          style: GoogleFonts.robotoMono(
            color: const Color(0xFF00E5FF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'ARCHITECTURAL MISSION STATEMENT',
          style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.description,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
            height: 1.65,
            fontWeight: FontWeight.w300,
          ),
        ),

        const SizedBox(height: 28),

        // Primary Metric Node
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF0F111A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.product.metricLabel, style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 9, letterSpacing: 1.0)),
              const SizedBox(height: 4),
              Text(
                widget.product.metricValue,
                style: GoogleFonts.robotoMono(color: const Color(0xFF00E5FF), fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'AUTHORIZED CHANNELS & ONBOARDING ENVIRONMENT',
          style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            ElevatedButton.icon(
              onPressed: () => _executeExternalLink(widget.product.primaryActionUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: const RoundedRectangleBorder(),
                elevation: 0,
              ),
              icon: const Icon(Icons.download_for_offline_rounded, size: 18),
              label: Text(
                widget.product.primaryActionLabel,
                style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
              ),
            ),

            OutlinedButton.icon(
              onPressed: () => _executeExternalLink(widget.product.secondaryActionUrl),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: const RoundedRectangleBorder(),
              ),
              icon: const Icon(Icons.forum_rounded, size: 16),
              label: Text(
                'JOIN THE DEVELOPMENT ECOSYSTEM',
                style: GoogleFonts.robotoMono(fontSize: 11, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Technical Breakdown & Formatted Hardware Mapping Data Tables
  Widget _buildMassiveECommerceDescriptionBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRODUCT DESCRIPTION & CORE WORKSPACE ARCHITECTURE',
          style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.white12),
        const SizedBox(height: 24),

        // Deep Engineering Stack Framework Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.product.techStack.map((tech) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F111A),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                tech.toUpperCase(),
                style: GoogleFonts.robotoMono(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),
        Text(
          'DEEP HARDWARE-INTELLIGENT RUNTIME SPECS',
          style: GoogleFonts.robotoMono(color: const Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 14),
        Text(
          widget.product.longDescription,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, height: 1.7, fontWeight: FontWeight.w300),
        ),

        const SizedBox(height: 40),

        // Core Tactical Feature Matrix
        Text(
          'KEY COMPILATION & MONITORING SAFEGUARDS',
          style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        Column(
          children: widget.product.bulletFeatures.map((feature) {
            final parts = feature.split(': ');
            final title = parts.isNotEmpty ? parts[0] : '';
            final body = parts.length > 1 ? parts[1] : '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0, right: 12.0),
                    child: Icon(Icons.square, size: 5, color: Color(0xFF00E5FF)),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, height: 1.5),
                        children: [
                          TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          TextSpan(text: body, style: const TextStyle(fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        // 📊 TECHNICAL TARGET SPECIFICATION DATA GRID
        if (widget.product.spatialMatrix.isNotEmpty) ...[
          const SizedBox(height: 50),
          Text(
            'TARGET SYSTEM COMPATIBILITY & ARCHITECTURE RULES',
            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.white10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF0F111A)),
                columns: [
                  DataColumn(label: Text('ARCHITECTURE NODE', style: GoogleFonts.robotoMono(color: const Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('INTEGRATION STATUS', style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 11))),
                  DataColumn(label: Text('VALIDATION LOGIC COMPONENT SCAN', style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 11))),
                  DataColumn(label: Text('CLASSIFICATION', style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 11))),
                ],
                rows: widget.product.spatialMatrix.map((row) {
                  return DataRow(
                    cells: [
                      DataCell(Text(row['zone'] ?? '', style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                      DataCell(Text(row['dir'] ?? '', style: GoogleFonts.robotoMono(color: const Color(0xFF00E5FF), fontSize: 11))),
                      DataCell(Text(row['array'] ?? '', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12))),
                      DataCell(Text(row['count'] ?? '', style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 11))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],

        // 🌍 Open Ecosystem Platform Vision Strip
        const SizedBox(height: 50),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF07080C),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRODUCTION DEPLOYMENT & SCALING OBJECTIVES',
                style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const SizedBox(height: 10),
              Text(
                'Stop thinking like just a coder. Start building like a Founder. Sentinel Core IDE provides the tooling infrastructure, custom third-party visualizer models, and rigid compile-time safety barriers required to solve high-density operational problems and scale reliable fleet products into active real-world networks with absolute stability.',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13, height: 1.6, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ],
    );
  }
}