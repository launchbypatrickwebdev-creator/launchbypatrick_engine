import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/launch_tactile_engine.dart';
import '../shared/launch_section_container.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/shared_site_footer.dart';

class ArchitectureFAQ {
  final String category;
  final String question;
  final String answer;
  final String? deepDiveUrl;
  final String? deepDiveLabel;

  const ArchitectureFAQ({
    required this.category,
    required this.question,
    required this.answer,
    this.deepDiveUrl,
    this.deepDiveLabel,
  });
}

// =========================================================================
// PROCEDURAL BACKGROUND ENGINE: ARCHITECTURAL GRID MESH
// =========================================================================
class GridMeshPainter extends CustomPainter {
  final Color gridColor;
  const GridMeshPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const double step = 45.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridMeshPainter oldDelegate) => false;
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  static const Color _accentColor = Color(0xFF00E5FF);
  static const Color _terminalGreen = Color(0xFF39FF14);
  static const Color _canvasBackground = Color(0xFF0A0B10);
  static const String _backgroundImagePath = 'assets/images/background.webp';
  static const double _backgroundImageOpacity = 0.12;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // =========================================================================
  // FAQ REGISTRY — unchanged
  // =========================================================================
  static const List<ArchitectureFAQ> _faqs = [
    ArchitectureFAQ(
      category: 'ARCHITECTURE & ISOLATION',
      question: 'How do I determine whether my project needs a microservices architecture versus a modular monolith?',
      answer: 'We evaluate this based on team topology, independent deployment requirements, and domain isolation needs. For most scaling platforms, we design a modular monolith first to keep operational overhead low, transitioning to microservices only when distinct domains require disparate scaling profiles.',
      deepDiveUrl: 'https://martinfowler.com/bliki/MicroservicePremium.html',
      deepDiveLabel: 'MARTIN FOWLER // MICROSERVICE PREMIUM',
    ),
    ArchitectureFAQ(
      category: 'ARCHITECTURE & ISOLATION',
      question: 'How do I design my application systems to be truly "offline first"?',
      answer: 'An offline-first architecture requires decoupling UI states from live network responses. We implement local-first caching layers utilizing embeddable databases on the client side, where read operations pull directly from the local store and writes queue up until connection states normalize.',
    ),
    ArchitectureFAQ(
      category: 'ARCHITECTURE & ISOLATION',
      question: 'How do I ensure long-term modularity when building with third party APIs?',
      answer: 'We isolate external third-party dependencies behind custom adapter layers using the Dependency Inversion Principle. Core application logic interacts strictly with internal abstract interfaces, meaning a vendor swap requires changing only a single isolated adapter file.',
    ),
    ArchitectureFAQ(
      category: 'ARCHITECTURE & ISOLATION',
      question: 'What approach should I take to state management in highly reactive ecosystems?',
      answer: 'We treat state as a unidirectional data flow. Local UI ephemeral state stays confined directly inside individual component scopes, while global app wide state is handled through strict state management containers that decouple business logic from the layout layer.',
    ),
    ArchitectureFAQ(
      category: 'NETWORKING & PROTOCOLS',
      question: 'What protocol should I select for real time, bi-directional data transport?',
      answer: 'The choice depends strictly on your payload frequency. For low overhead IoT networks and sensor metrics, we deploy MQTT. For scalable web to server persistent pipelines, we utilize WebSockets. For high throughput microservice handshakes, we implement gRPC over HTTP/2.',
    ),
    ArchitectureFAQ(
      category: 'NETWORKING & PROTOCOLS',
      question: 'How do I handle database selections for transactional integrity versus massive analytical scaling?',
      answer: 'We practice polyglot persistence. Core transactional flows like billing, accounts, and ledger states are assigned to relational databases (PostgreSQL) configured for ACID compliance. High throughput event streams are routed to document stores or time series engines.',
      deepDiveUrl: 'https://aws.amazon.com/architecture/patterns/',
      deepDiveLabel: 'AWS ARCHITECTURE // CLOUD DESIGN PATTERNS',
    ),
    ArchitectureFAQ(
      category: 'NETWORKING & PROTOCOLS',
      question: 'How do I handle large-file streaming and upload pipelines without depleting server memory?',
      answer: 'We avoid loading raw file payloads into active server memory buffer blocks. Instead, we architect direct to storage stream pipelines using multipart upload protocols or provision short lived, pre-signed AWS S3 or Cloud Storage upload URIs directly to the client interface.',
    ),
    ArchitectureFAQ(
      category: 'NETWORKING & PROTOCOLS',
      question: 'What architectural constraints should I implement regarding API versioning?',
      answer: 'We version endpoints explicitly via the URI path (e.g., /api/v1/) to provide deterministic routing rules. Old version APIs are maintained alongside newer deployments for a designated window, accompanied by active deprecation headers alerting integrations.',
    ),
    ArchitectureFAQ(
      category: 'CLOUD & REDUNDANCY',
      question: 'How do I optimize cloud infrastructure spend while preserving high availability?',
      answer: 'We eliminate over provisioned idle compute footprints by engineering elastic scaling boundaries. By setting automated scale up thresholds based on sustained CPU/Memory load and scale-down protocols for off-peak hours, infrastructure footprint matches real traffic.',
    ),
    ArchitectureFAQ(
      category: 'CLOUD & REDUNDANCY',
      question: 'How do I design high-availability systems to withstand localized data center failures?',
      answer: 'We implement multi region active-passive or active-active configurations. Application states are backed by distributed, globally replicated database infrastructures. If a primary data center suffers an outage, cloud routing health probes instantly trigger a failover sequence.',
    ),
    ArchitectureFAQ(
      category: 'CLOUD & REDUNDANCY',
      question: 'How do I handle configuration management and environment secrets safely?',
      answer: 'We strictly decouple configuration from code execution pathways. Hardcoded credentials or local environment config files are completely forbidden in version control. Production secrets are managed through cryptographic secret storage systems and injected at runtime.',
      deepDiveUrl: 'https://12factor.net/',
      deepDiveLabel: 'THE TWELVE-FACTOR APP METHODOLOGY',
    ),
    ArchitectureFAQ(
      category: 'CLOUD & REDUNDANCY',
      question: 'How do I deal with cache invalidation complexities in multi tier setups?',
      answer: 'We use short Time To Live (TTL) baselines combined with programmatic, event driven cache purges. When an underlying data state changes via an authenticated write request, the database transaction layer dispatches a lightweight invalidate signal targeting the specific block.',
    ),
    ArchitectureFAQ(
      category: 'PERFORMANCE & DEFENSE',
      question: 'How do I mitigate performance bottlenecks in cross-platform mobile engines?',
      answer: 'We optimize execution by delegating computationally expensive logic such as deep cryptographic operations, heavy JSON serialization, or local database indexing to background worker isolates, leaving the primary main thread dedicated strictly to UI rendering.',
    ),
    ArchitectureFAQ(
      category: 'PERFORMANCE & DEFENSE',
      question: 'What strategies should I use to protect APIs against malicious distributed traffic spikes?',
      answer: 'We enforce a zero-trust multi-layered defensive perimeter. At the perimeter web entry layer, we use cloud CDNs for DDoS mitigation. At the application gateway layer, we implement token bucket rate limiting alongside strict payload size checks.',
    ),
    ArchitectureFAQ(
      category: 'PERFORMANCE & DEFENSE',
      question: 'How do I optimize initial load times and bundle weights for enterprise web engines?',
      answer: 'We enforce aggressive dead-code elimination (tree-shaking), split layouts by routing vectors via lazy loading, and compress delivery payloads using modern algorithms like Brotli, while caching dynamic asset payloads across edge distribution networks.',
      deepDiveUrl: 'https://developer.mozilla.org/en-US/docs/Web/Performance',
      deepDiveLabel: 'MDN WEB DOCS // PERFORMANCE DOCUMENTATION',
    ),
    ArchitectureFAQ(
      category: 'PERFORMANCE & DEFENSE',
      question: 'What is a Zero Trust Architecture and should I build under it?',
      answer: 'Yes, we treat every network packet as potentially hostile. A Zero Trust Architecture assumes threats exist both outside and inside the local network perimeter, requiring continuous authentication, authorized lease windows, and strict role based access controls.',
    ),
    ArchitectureFAQ(
      category: 'STABILITY & DEBT LIFECYCLE',
      question: 'How do I address and track technical debt during fast paced product cycles?',
      answer: 'Technical debt is handled like financial interest. We modularize our codebases so that legacy structures are encapsulated behind clean interface abstractions. This allows us to re-engineer underperforming backend subsystems independently without breaking platform features.',
    ),
    ArchitectureFAQ(
      category: 'STABILITY & DEBT LIFECYCLE',
      question: 'What testing metrics should I rely on to guarantee system stability prior to production deployment?',
      answer: 'We maintain automated CI/CD validation pipelines combining three core disciplines: isolated unit tests targeting domain business logic, integration test arrays checking data access layers, and end to end user journey smoke tests executing headlessly.',
    ),
    ArchitectureFAQ(
      category: 'STABILITY & DEBT LIFECYCLE',
      question: 'How do I approach error handling and logging across distributed cloud apps?',
      answer: 'We implement structured JSON logging linked to distributed correlation IDs. Every inbound request gets assigned a unique identification string. If an unhandled error occurs deep inside a service, the correlation ID lets us trace the entire system pipeline.',
    ),
    ArchitectureFAQ(
      category: 'STABILITY & DEBT LIFECYCLE',
      question: 'How do I secure data transmission between my internal microservices?',
      answer: 'We enforce Mutual TLS (mTLS) inside our service mesh infrastructure. This configuration demands that every backend microservice validates the cryptographic certificate of any adjacent microservice before completing an internal data handshake.',
    ),
    ArchitectureFAQ(
      category: 'FLUTTER & CROSS-PLATFORM',
      question: 'What makes Flutter a strong choice for production cross-platform apps?',
      answer: 'Flutter compiles directly to native ARM code, bypassing JavaScript bridges entirely. This gives near-native rendering performance on iOS, Android, Web, Desktop, and Embedded from a single codebase. The widget system renders at 60–120fps using its own Skia/Impeller engine rather than relying on platform UI components, eliminating cross platform inconsistency.',
      deepDiveUrl: 'https://docs.flutter.dev/perf/best-practices',
      deepDiveLabel: 'FLUTTER DOCS // PERFORMANCE BEST PRACTICES',
    ),
    ArchitectureFAQ(
      category: 'FLUTTER & CROSS-PLATFORM',
      question: 'How should I structure state management in a large Flutter application?',
      answer: 'We use a layered approach: Riverpod for dependency injection and global reactive state, local StatefulWidget for transient UI state, and repository pattern to isolate data access. Business logic lives in pure Dart use-case classes — testable in isolation without a Flutter runtime. This keeps UI rebuilds surgical and prevents full tree re-renders on data changes.',
      deepDiveUrl: 'https://riverpod.dev/docs/concepts/providers',
      deepDiveLabel: 'RIVERPOD // PROVIDER ARCHITECTURE GUIDE',
    ),
    ArchitectureFAQ(
      category: 'FLUTTER & CROSS-PLATFORM',
      question: 'What are the most common Flutter performance pitfalls and how do we avoid them?',
      answer: 'The biggest pitfalls are: rebuilding the entire widget tree on unrelated state changes (fix: use const constructors and targeted Consumer scopes), running expensive computation on the main isolate (fix: offload to compute() or a background isolate), and unoptimised image sizes in scroll views (fix: use cached_network_image with memCacheWidth constraints). Profile with DevTools before optimising — never guess.',
    ),
    ArchitectureFAQ(
      category: 'FLUTTER & CROSS-PLATFORM',
      question: 'How do we handle platform specific features (camera, Bluetooth, biometrics) in Flutter?',
      answer: 'Flutter exposes platform channels for native feature access. For most needs, community packages (camera, flutter_blue_plus, local_auth) wrap these channels. For custom hardware integrations we write platform channel code in Swift/Kotlin and expose a clean Dart API above it. The Flutter app never calls native APIs directly — it always goes through an abstract interface, making platform swaps safe.',
    ),
    ArchitectureFAQ(
      category: 'SEO, AEO & WEB VISIBILITY',
      question: 'What is the difference between SEO, AEO, and GEO, and do I need all three?',
      answer: 'SEO (Search Engine Optimization) targets traditional search ranking in Google and Bing. AEO (Answer Engine Optimization) targets AI-generated answer surfaces — ChatGPT, Perplexity, Claude, Google AI Overviews. GEO (Generative Engine Optimization) is the emerging practice of structuring content so large language models cite your brand as an authoritative source. Yes, you need all three — AI handles over 30% of informational queries today and growing.',
      deepDiveUrl: 'https://developers.google.com/search/docs/fundamentals/seo-starter-guide',
      deepDiveLabel: 'GOOGLE // SEO STARTER GUIDE',
    ),
    ArchitectureFAQ(
      category: 'SEO, AEO & WEB VISIBILITY',
      question: 'How does Flutter Web affect SEO and how do we mitigate it?',
      answer: 'Flutter Web\'s CanvasKit renderer outputs a single canvas element with no accessible DOM text — traditional crawlers cannot index it. Mitigations: switch to HTML renderer for public-facing pages (better DOM output), implement SSR via a Next.js or Nuxt shell for critical landing pages, pre-render static routes using flutter_seo package, and submit an XML sitemap. For content heavy marketing sites we typically recommend Next.js over Flutter Web.',
    ),
    ArchitectureFAQ(
      category: 'SEO, AEO & WEB VISIBILITY',
      question: 'What structured data markup delivers the highest ROI for most businesses?',
      answer: 'Priority order by impact: 1) Organization schema (establishes your entity in Google\'s Knowledge Graph), 2) WebSite schema with SearchAction (enables Sitelinks search box), 3) FAQPage schema (direct FAQ expansions in SERPs, heavily used by AI answer engines), 4) BreadcrumbList (clean navigation trails), 5) Product and Review schemas for e-commerce. Implement all five in JSON-LD — it takes one afternoon and yields sustained organic visibility gains.',
      deepDiveUrl: 'https://schema.org/docs/gs.html',
      deepDiveLabel: 'SCHEMA.ORG // GETTING STARTED WITH STRUCTURED DATA',
    ),
    ArchitectureFAQ(
      category: 'SEO, AEO & WEB VISIBILITY',
      question: 'How do Core Web Vitals actually impact search rankings and what thresholds matter most?',
      answer: 'Google uses Core Web Vitals as a tiebreaker ranking signal between pages with similar content quality. The thresholds that matter: LCP (Largest Contentful Paint) under 2.5 seconds, INP (Interaction to Next Paint) under 200ms, CLS (Cumulative Layout Shift) under 0.1. LCP has the highest impact — a 1-second improvement in LCP correlates with a 3–5% conversion lift. Measure in field data via CrUX, not just Lighthouse lab scores.',
      deepDiveUrl: 'https://web.dev/explore/learn-core-web-vitals',
      deepDiveLabel: 'WEB.DEV // CORE WEB VITALS LEARNING PATH',
    ),
    ArchitectureFAQ(
      category: 'WORKING WITH LAUNCHBYPATRICK',
      question: 'What does a typical engagement with LaunchByPatrick look like from start to finish?',
      answer: 'It starts with a 30m inute scoping sprint to audit your current stack, define clear non-functional requirements, and agree on scope. From there we move into a design phase (architecture diagrams, API contracts, data models), then iterative build sprints with weekly demos. You get a production-ready codebase, deployment setup, and a 30 day handoff window where we answer questions and fix any issues that surface post-launch.',
    ),
    ArchitectureFAQ(
      category: 'WORKING WITH LAUNCHBYPATRICK',
      question: 'What types of projects are the best fit for LaunchByPatrick?',
      answer: 'Best fits: cross-platform Flutter apps (mobile + web + desktop), high traffic web platforms needing architecture audits, backend systems with complex data flows (marketplaces, fintech, creator platforms), and greenfield products where the founding team wants production-quality architecture from day one. Not a fit: simple landing pages with no backend, pure graphic design work, or projects with no technical decision maker on the client side.',
    ),
    ArchitectureFAQ(
      category: 'WORKING WITH LAUNCHBYPATRICK',
      question: 'How do you handle projects where the existing codebase is a mess?',
      answer: 'We start with a paid Architecture Audit — a structured review of your codebase, infrastructure, and database that produces a prioritised remediation plan. We score every finding by business impact and fix effort, so you know exactly what to tackle first. From there we can implement the fixes ourselves or guide your internal team through them. Most audits reveal 3–5 high impact quick wins that pay for the audit cost within weeks.',
    ),
    ArchitectureFAQ(
      category: 'WORKING WITH LAUNCHBYPATRICK',
      question: 'Do you work with early stage startups or only established companies?',
      answer: 'Both, with different engagement shapes. Early stage startups benefit most from our MVP Scoping service — we help you build the leanest possible version that validates your core hypothesis without over engineering. Established companies typically engage us for Architecture Audits, performance remediation, or platform migrations. The minimum bar is that you have a clear product vision and a technical decision-maker we can work directly with.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'launchbypatrick.webdev@gmail.com',
      query: 'subject=Infrastructure Inquiry',
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email protocol');
    }
  }

  void _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    await launchUrl(
      url,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );
  }

  Map<String, List<ArchitectureFAQ>> _getFilteredAndGroupedFaqs() {
    final Map<String, List<ArchitectureFAQ>> grouped = {};
    for (var faq in _faqs) {
      final matchesSearch =
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      if (matchesSearch) {
        if (!grouped.containsKey(faq.category)) {
          grouped[faq.category] = [];
        }
        grouped[faq.category]!.add(faq);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;
    final filteredGroupedFaqs = _getFilteredAndGroupedFaqs();

    return Scaffold(
      backgroundColor: _canvasBackground,
      body: Stack(
        children: [
          // LAYER 1: Background image
          Positioned.fill(
            child: Opacity(
              opacity: _backgroundImageOpacity,
              child: Image.asset(
                _backgroundImagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // LAYER 2: Grid mesh
          Positioned.fill(
            child: CustomPaint(
              painter: GridMeshPainter(
                gridColor: Colors.white.withValues(alpha: 0.012),
              ),
            ),
          ),

          // LAYER 3: Ambient glow top-right
          Positioned(
            top: 150,
            right: -100,
            width: 600,
            height: 600,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentColor.withValues(alpha: 0.035),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // LAYER 3: Ambient glow bottom-left
          Positioned(
            bottom: 300,
            left: -200,
            width: 700,
            height: 700,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentColor.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // INTERACTION LAYER
          LaunchTactileEngine(
            onRefresh: () async =>
            await Future.delayed(const Duration(milliseconds: 1000)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── [1] NAV ───────────────────────────────────────────────
                const TopNavBar(),

                // ── [2] ZONE 0: WHO WE ARE (new About layer) ─────────────
                _buildAboutZone(isMobile),

                // ── [3] ZONE 1: DIRECT CONTACT ENTRY POINT ───────────────
                _buildContactEntryHero(isMobile),

                const SizedBox(height: 40),

                // ── [4] ZONE 2: FAQ ───────────────────────────────────────
                LaunchSectionContainer(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16.0 : 40.0),
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: isMobile
                          ? _buildMobileFaqLayout(filteredGroupedFaqs)
                          : _buildDesktopAsymmetricFaqLayout(
                          filteredGroupedFaqs),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // ── [5] ZONE 3: CONTACT DETAILS ───────────────────────────
                LaunchSectionContainer(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16.0 : 40.0),
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: isMobile
                          ? Column(
                        children: [
                          const Divider(
                              color: Colors.white10, height: 1),
                          _buildContactRow(
                              label: "EMAIL SECURE",
                              value:
                              "launchbypatrick.webdev@gmail.com",
                              icon: Icons.alternate_email,
                              onTap: _launchEmail,
                              isMobile: true),
                          const Divider(
                              color: Colors.white10, height: 1),
                          _buildContactRow(
                              label: "TIMEZONE OPS",
                              value: "09:00 - 18:00 (GMT+1)",
                              icon: Icons.access_time,
                              onTap: null,
                              isMobile: true),
                          const Divider(
                              color: Colors.white10, height: 1),
                          _buildContactRow(
                              label: "GLOBAL LOC",
                              value: "Remote / London / Lagos",
                              icon: Icons.public,
                              onTap: null,
                              isMobile: true),
                          const Divider(
                              color: Colors.white10, height: 1),
                        ],
                      )
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.only(top: 32.0),
                              child: Text(
                                "CONTACT US",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    height: 1.5),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Column(
                              children: [
                                const Divider(
                                    color: Colors.white10,
                                    height: 1),
                                _buildContactRow(
                                    label: "EMAI SECURE",
                                    value:
                                    "launchbypatrick.webdev@gmail.com",
                                    icon: Icons.alternate_email,
                                    onTap: _launchEmail,
                                    isMobile: false),
                                const Divider(
                                    color: Colors.white10,
                                    height: 1),
                                _buildContactRow(
                                    label: "TIMEZONE OPS",
                                    value: "09:00 - 18:00 (GMT+1)",
                                    icon: Icons.access_time,
                                    onTap: null,
                                    isMobile: false),
                                const Divider(
                                    color: Colors.white10,
                                    height: 1),
                                _buildContactRow(
                                    label: "GLOBAL LOC",
                                    value: "Remote / London / Lagos",
                                    icon: Icons.public,
                                    onTap: null,
                                    isMobile: false),
                                const Divider(
                                    color: Colors.white10,
                                    height: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 100),
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
  // ZONE 0 — WHO WE ARE: Semantics on every meaningful block
  // =========================================================================
  Widget _buildAboutZone(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        border: Border(
            bottom:
            BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: LaunchSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // ── section label ──────────────────────────────────────────
            Semantics(
              header: true,
              label: 'About Launch by Patrick — who we are, our mission, direction, and values.',
              child: const Text(
                'WHO WE ARE',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // ── mission + direction ────────────────────────────────────
            isMobile
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMissionBlock(isMobile),
                const SizedBox(height: 48),
                _buildDirectionBlock(isMobile),
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildMissionBlock(isMobile)),
                const SizedBox(width: 60),
                Expanded(flex: 7, child: _buildDirectionBlock(isMobile)),
              ],
            ),

            const SizedBox(height: 72),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 64),

            // ── values label ───────────────────────────────────────────
            Semantics(
              header: true,
              label: 'Our values — integrity above delivery, compassion as architecture, unconventional by design, sovereignty over convenience.',
              child: const Text(
                'VALUES',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── value cards ────────────────────────────────────────────
            isMobile
                ? Column(children: [
              _buildValueCard(
                number: '01',
                title: 'INTEGRITY ABOVE DELIVERY',
                body: 'We would rather lose a deadline than ship a lie. Code that works but misleads is not code we sign our name to.',
              ),
              const SizedBox(height: 16),
              _buildValueCard(
                number: '02',
                title: 'COMPASSION AS ARCHITECTURE',
                body: 'We build for the person whose livelihood depends on this system working. That human weight lives in every technical decision.',
              ),
              const SizedBox(height: 16),
              _buildValueCard(
                number: '03',
                title: 'UNCONVENTIONAL BY DESIGN',
                body: 'The conventional solution already exists. If we are rebuilding what is already there, we are wasting the continent\'s time.',
              ),
              const SizedBox(height: 16),
              _buildValueCard(
                number: '04',
                title: 'SOVEREIGNTY OVER CONVENIENCE',
                body: 'We don\'t build dependence on foreign rails when we can engineer the rail itself. Every shortcut that creates lock-in is a tax on Africa\'s future.',
              ),
            ])
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(children: [
                    _buildValueCard(
                      number: '01',
                      title: 'INTEGRITY ABOVE DELIVERY',
                      body: 'We would rather lose a deadline than ship a lie. Code that works but misleads is not code we sign our name to.',
                    ),
                    const SizedBox(height: 16),
                    _buildValueCard(
                      number: '03',
                      title: 'UNCONVENTIONAL BY DESIGN',
                      body: 'The conventional solution already exists. If we are rebuilding what is already there, we are wasting the continent\'s time.',
                    ),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(children: [
                    _buildValueCard(
                      number: '02',
                      title: 'COMPASSION AS ARCHITECTURE',
                      body: 'We build for the person whose livelihood depends on this system working. That human weight lives in every technical decision.',
                    ),
                    const SizedBox(height: 16),
                    _buildValueCard(
                      number: '04',
                      title: 'SOVEREIGNTY OVER CONVENIENCE',
                      body: 'We don\'t build dependence on foreign rails when we can engineer the rail itself. Every shortcut that creates lock-in is a tax on Africa\'s future.',
                    ),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionBlock(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MISSION',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0)),
        const SizedBox(height: 20),
        Semantics(
          label: 'Mission: We exist for the founder who sees what does not exist yet and refuses to wait for someone else to build it.',
          child: Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
                border:
                Border(left: BorderSide(color: _accentColor, width: 2))),
            child: Text(
              'We exist for the founder who sees what doesn\'t exist yet and refuses to wait for someone else to build it.',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w500,
                height: 1.55,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionBlock(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DIRECTION',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0)),
        const SizedBox(height: 20),
        Semantics(
          label: 'Direction: We are building toward a world where the most ambitious software on the continent is also built here, by teams who understand what Africa needs to own, not just consume. Launch by Patrick exists at the beginning of that story.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We are building toward a world where the most ambitious software on the continent is also built here, by teams who understand what Africa needs to own, not just consume.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: isMobile ? 15 : 16,
                  height: 1.75,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Launch by Patrick exists at the beginning of that story.',
                style: TextStyle(
                  color: _accentColor.withValues(alpha: 0.85),
                  fontSize: isMobile ? 14 : 15,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard({
    required String number,
    required String title,
    required String body,
  }) {
    return Semantics(
      label: 'Value $number: $title. $body',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number,
                style: TextStyle(
                    color: _accentColor.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8)),
            const SizedBox(height: 12),
            Container(
                height: 1,
                width: 32,
                color: _accentColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(body,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    fontSize: 13,
                    height: 1.65,
                    fontWeight: FontWeight.w300)),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ZONE 1 — CONTACT ENTRY HERO: Semantics on headline + subtext
  // =========================================================================
  Widget _buildContactEntryHero(bool isMobile) {
    return LaunchSectionContainer(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 40.0),
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Semantics(
                header: true,
                label: 'Start a conversation with Launch by Patrick.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('START A',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            height: 1.1)),
                    Text('CONVERSATION.',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: _accentColor,
                            letterSpacing: 2.0,
                            height: 1.1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Browse the architecture briefs below — most questions are already answered. When you are ready, the direct line is open.',
                child: const Text(
                  'Browse the architecture briefs below — most questions are already answered. When you\'re ready, the direct line is open.',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      height: 1.6),
                ),
              ),
              const SizedBox(height: 40),
            ],
          )
              : Padding(
            padding: const EdgeInsets.only(top: 80.0, bottom: 40.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Semantics(
                    header: true,
                    label: 'Start a conversation with Launch by Patrick.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('START A',
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                height: 1.1)),
                        Text('CONVERSATION.',
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: _accentColor,
                                letterSpacing: 2.0,
                                height: 1.1)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Semantics(
                      label: 'Browse the architecture briefs below — most questions are already answered. When you are ready, the direct line is open.',
                      child: const Text(
                        'Browse the architecture briefs below — most questions are already answered. When you\'re ready, the direct line is open.',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                            height: 1.7,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // ZONE 2 — FAQ: Semantics on each question + answer pair
  // =========================================================================
  Widget _buildDesktopAsymmetricFaqLayout(
      Map<String, List<ArchitectureFAQ>> groupedFaqs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.only(right: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  label: 'Frequently asked questions about Launch by Patrick architecture services.',
                  child: const Text('FAQ',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontFamily: 'monospace')),
                ),
                const SizedBox(height: 32),
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10),
                      color: Colors.white.withValues(alpha: 0.005),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(' ${_faqs.length}',
                            style: const TextStyle(
                                color: _terminalGreen,
                                fontSize: 11,
                                fontFamily: 'monospace')),
                        const SizedBox(height: 6),
                        Text(
                            'FILTER_STATUS: ${_searchQuery.isNotEmpty ? "ACTIVE" : "IDLE"}',
                            style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildFaqAccordionList(groupedFaqs),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFaqLayout(
      Map<String, List<ArchitectureFAQ>> groupedFaqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              header: true,
              label: 'Frequently asked questions.',
              child: const Text('FAQ',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace')),
            ),
            ExcludeSemantics(
              child: Text('[ ${_faqs.length} ]',
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontFamily: 'monospace')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildFaqAccordionList(groupedFaqs),
      ],
    );
  }

  Widget _buildSearchField() {
    return Semantics(
      label: 'Search field — filter architecture frequently asked questions by keyword.',
      textField: true,
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
            color: Colors.white, fontFamily: 'monospace', fontSize: 14),
        cursorColor: _accentColor,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'FILTER ARCHITECTURE LOGS BY KEYWORD...',
          hintStyle: const TextStyle(
              color: Colors.white30,
              fontSize: 13,
              fontFamily: 'monospace'),
          prefixIcon:
          const Icon(Icons.search, color: Colors.white38, size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close,
                color: Colors.white54, size: 16),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.02),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.zero),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _accentColor),
              borderRadius: BorderRadius.zero),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildFaqAccordionList(
      Map<String, List<ArchitectureFAQ>> groupedFaqs) {
    if (groupedFaqs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80.0),
        child: Center(
          child: Text('NO MATCHING BRIEFINGS FOUND IN THE LOGS.',
              style: TextStyle(
                  color: Colors.white24,
                  fontFamily: 'monospace',
                  fontSize: 13)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedFaqs.keys.length,
      itemBuilder: (context, catIndex) {
        final categoryName = groupedFaqs.keys.elementAt(catIndex);
        final categoryFaqs = groupedFaqs[categoryName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 36.0, bottom: 12.0),
              child: Semantics(
                header: true,
                label: 'FAQ category: $categoryName',
                child: Text(categoryName,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                expansionTileTheme: const ExpansionTileThemeData(
                  iconColor: _accentColor,
                  collapsedIconColor: Colors.white38,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.only(bottom: 24, top: 4),
                ),
              ),
              child: Column(
                children: categoryFaqs.map((faq) {
                  return Semantics(
                    // each Q&A is one semantic unit for bots
                    label: 'Question: ${faq.question} Answer: ${faq.answer}',
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.white10, width: 1))),
                      child: ExpansionTile(
                        title: Text(faq.question,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.4)),
                        expandedCrossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(faq.answer,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.6)),
                          if (faq.deepDiveUrl != null) ...[
                            const SizedBox(height: 16),
                            Semantics(
                              button: true,
                              label:
                              'Deep dive resource: ${faq.deepDiveLabel ?? "external link"}',
                              child: InkWell(
                                onTap: () =>
                                    _launchUrl(faq.deepDiveUrl!),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        faq.deepDiveLabel ??
                                            'DEEP DIVE RESOURCE',
                                        style: const TextStyle(
                                            color: _terminalGreen,
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            fontWeight:
                                            FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_outward,
                                        color: _terminalGreen,
                                        size: 12),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // ZONE 3 — CONTACT DETAILS: Semantics on each row
  // =========================================================================
  Widget _buildContactRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isMobile,
  }) {
    return Semantics(
      label: onTap != null
          ? '$label: $value — tap to open'
          : '$label: $value',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        mouseCursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Padding(
          padding:
          EdgeInsets.symmetric(vertical: isMobile ? 24.0 : 36.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(icon,
                    color: Colors.white24,
                    size: isMobile ? 20 : 22),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Text(value,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
              if (onTap != null)
                ExcludeSemantics(
                  child: const Icon(Icons.arrow_forward,
                      color: _accentColor, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}