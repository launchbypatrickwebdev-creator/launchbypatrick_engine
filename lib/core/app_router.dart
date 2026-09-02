import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Master Ecosystem Pages (LaunchByPatrick)
import '../pages/home_page.dart';
import '../pages/product_page.dart';
import '../pages/product_detail_page.dart';
import '../pages/growth_engine_page.dart';
import '../pages/growth_intakeform_page.dart';
import '../pages/contact_page.dart';

// Sentinel IoT Isolated Pages
import '../pages/sentinel_page.dart';
import '../pages/sentinel/growth_engine_page.dart' as sentinel_growth;
import '../pages/sentinel/rd_page.dart';
import '../pages/sentinel/connect_page.dart' as sentinel_contact;
import '../../widgets/connection_form.dart';

import '../data/products_data.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,

  // ---------------------------------------------------------------------------
  // 🛡️ DOMAIN ISOLATION REDIRECT LOGIC
  // ---------------------------------------------------------------------------
  redirect: (BuildContext context, GoRouterState state) {
    final String host = Uri.base.host;
    final String path = state.uri.path;

    // Identifies if traffic is visiting via echolevel.vercel.app
    final bool isSentinelDomain = host.contains('echolevel');

    // Rule 1: Visiting echolevel.vercel.app/ directly routes straight into Sentinel
    if (isSentinelDomain && path == '/') {
      return '/sentinel';
    }

    // Rule 2: Visiting launchbypatrick.vercel.app/sentinel blocks access & bounces back home
    if (!isSentinelDomain && path.startsWith('/sentinel')) {
      return '/';
    }

    return null; // Continue standard routing
  },

  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0A0B10),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.gpp_bad_outlined, color: Colors.redAccent, size: 48),
          const SizedBox(height: 20),
          Text(
            "404: NODE_NOT_FOUND",
            style: GoogleFonts.robotoMono(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => context.go('/'),
            child: Text(
              "[ RETURN TO COMMAND_CENTER ]",
              style: GoogleFonts.robotoMono(
                color: const Color(0xFF00E5FF),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    ),
  ),

  routes: [
    // =========================================================================
    // 🌐 LAUNCHBYPATRICK (MASTER HUB ROUTES)
    // =========================================================================
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) => const ProductPage(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'product-detail',
          builder: (context, state) {
            ProductItem? targetProduct = state.extra as ProductItem?;

            if (targetProduct == null) {
              final String fullIncomingPath = state.uri.path;

              targetProduct = productsRegistry.firstWhere(
                    (item) => item.detailUrl == fullIncomingPath,
                orElse: () => productsRegistry.first,
              );
            }

            return ProductDetailPage(product: targetProduct);
          },
        ),
      ],
    ),

    GoRoute(
      path: '/growth-engine',
      name: 'growth-engine',
      builder: (context, state) => const GrowthEnginePage(),
    ),

    GoRoute(
      path: '/growth_intakeform',
      name: 'growth-intakeform',
      builder: (context, state) => const GrowthIntakeformPage(),
    ),

    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) => const ContactPage(),
    ),

    // =========================================================================
    // 🛡️ ECHOLEVEL SENTINEL (ISOLATED SUB-ECOSYSTEM ROUTES)
    // =========================================================================
    GoRoute(
      path: '/sentinel',
      name: 'sentinel',
      builder: (context, state) => const SentinelPage(),
      routes: [
        GoRoute(
          path: 'growth-engine',
          name: 'sentinel-growth-engine',
          builder: (context, state) => const sentinel_growth.SentinelGrowthEnginePage()
        ),
        GoRoute(
          path: 'rd',
          name: 'sentinel-rd',
          builder: (context, state) => const RDPage(),
        ),
        GoRoute(
          path: 'connect',
          name: 'sentinel-connect',
          builder: (context, state) => const sentinel_contact.ConnectPage(),
        ),
      ],
    ),
  ],
);