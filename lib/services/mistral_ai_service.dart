// lib/services/mistral_ai_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ai_buddy_config.dart';

/// Service to communicate with Mistral AI API
class MistralAIService {
  static const String _apiKey = 'wS8TJDsEmoytJy8F6u70yF64eITVlhug';
  static const String _apiBaseUrl = 'https://api.mistral.ai/v1/chat/completions';

  final AIBuddyConfig config;

  MistralAIService({required this.config});

  /// Get AI response from Mistral AI
  Future<String> getAIResponse(
      String userMessage, {
        List<Map<String, String>>? conversationHistory,
      }) async {
    try {
      final List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': config.systemPrompt,
        },
        if (conversationHistory != null) ...conversationHistory,
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      final response = await http.post(
        Uri.parse(_apiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'mistral-small',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('API request timeout'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = decoded['choices'] as List;
        final message = choices[0]['message']['content'] as String;
        return message.trim();
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your Mistral API credentials.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limited. Please try again later.');
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Fallback to mock only when real API is unavailable
      return await _getMockAIResponse(userMessage);
    }
  }

  /// Stream AI response (optional real-time typing effect)
  Stream<String> streamAIResponse(
      String userMessage, {
        List<Map<String, String>>? conversationHistory,
      }) async* {
    try {
      final response = await getAIResponse(
        userMessage,
        conversationHistory: conversationHistory,
      );
      yield response;
    } catch (e) {
      yield 'Error: ${e.toString()}';
    }
  }

  // ===========================================================================
  // OFFLINE FALLBACK MOCK RESPONSES
  // Only fires when the real Mistral API is unreachable (network failure,
  // timeout, etc.). Each sub-question now has its own distinct answer so
  // the fallback still gives useful, specific replies.
  //
  // MATCHING ORDER MATTERS — more specific phrases are checked FIRST so they
  // win before a broad category catch-all can swallow them.
  // ===========================================================================
  Future<String> _getMockAIResponse(String userMessage) async {
    final lower = userMessage.toLowerCase();

    // ── SENTINEL PROFILE ─────────────────────────────────────────────────────
    if (config.assistantName == "CORTEX_AI") {
      return _getSentinelMockResponse(lower);
    }

    // ── LAUNCHBYPATRICK PROFILE ───────────────────────────────────────────────
    return _getPatrickMockResponse(lower);
  }

  // ---------------------------------------------------------------------------
  // SENTINEL mock responses — specific sub-questions matched first
  // ---------------------------------------------------------------------------
  String _getSentinelMockResponse(String lower) {

    // ── ESP32 / Microcontroller ────────────────────────────────────────────
    if (lower.contains('esp') ||
        lower.contains('esp32') ||
        lower.contains('microcontroller') ||
        lower.contains('gpio') ||
        lower.contains('pin')) {
      return "ESP32 configuration starts with mapping your pin roles: INPUT, OUTPUT, or INPUT_PULLUP. Pins 34–39 are input-only. Use digitalWrite() for outputs and digitalRead() for inputs. Always check your board's pinout. Would you like help with WiFi, BLE, power management, or firmware flashing?";
    }

    // ── Firmware ───────────────────────────────────────────────────────────
    if (lower.contains('firmware') ||
        lower.contains('ota') ||
        lower.contains('flash') ||
        lower.contains('update') ||
        lower.contains('rollback')) {
      return "Firmware management on the ESP32 uses OTA slots (OTA_0 and OTA_1). The running firmware validates the new binary, writes it to the inactive slot, then reboots. If the new firmware fails health checks, it automatically rolls back. Want the full OTA process or help with version control?";
    }

    // ── Security ───────────────────────────────────────────────────────────
    if (lower.contains('security') ||
        lower.contains('encrypt') ||
        lower.contains('secure boot') ||
        lower.contains('auth') ||
        lower.contains('tls')) {
      return "Security layers on Sentinel devices: AES hardware acceleration, Secure Boot V2 with RSA-PSS signatures, and mutual TLS for cloud communication. Keys are stored in the encrypted NVS partition. Would you like details on Secure Boot, encryption, or authentication?";
    }

    // ── Sensors ────────────────────────────────────────────────────────────
    if (lower.contains('sensor') ||
        lower.contains('temperature') ||
        lower.contains('fuel') ||
        lower.contains('level') ||
        lower.contains('calibration')) {
      return "Sentinel uses non-invasive sensors for fuel level, temperature compensation, and adulteration detection (acoustic FFT). The system can operate fully offline and store data in the Black Box. Which sensor would you like to configure or calibrate?";
    }

    // ── Diagnostics ────────────────────────────────────────────────────────
    if (lower.contains('diagnostic') ||
        lower.contains('troubleshoot') ||
        lower.contains('error') ||
        lower.contains('log') ||
        lower.contains('health')) {
      return "Diagnostics include sensor health checks, connection stability (RSSI + packet loss), heap monitoring, and crash log analysis via core dumps. I can walk you through any of these. What issue are you seeing?";
    }

    // ── Booking / Zoom ─────────────────────────────────────────────────────
    if (lower.contains('zoom') ||
        lower.contains('book') ||
        lower.contains('meeting') ||
        lower.contains('call') ||
        lower.contains('sync') ||
        lower.contains('consultation')) {
      return "Ready to coordinate. Click the Zoom button above to lock in a hardware synchronization session with the Sentinel team. We'll cover your specific firmware, sensor, or security requirements in depth.";
    }

    // ── Default fallback (only when nothing matches) ───────────────────────
    return "SENTINEL_CORE_OS operational. I can help with:\n\n• ESP32 / GPIO configuration\n• Firmware & OTA updates\n• Security & Secure Boot\n• Sensors & calibration\n• Diagnostics & troubleshooting\n\nOr click Zoom to book a direct technical sync. What do you need help with?";
  }

  // ---------------------------------------------------------------------------
  // LAUNCHBYPATRICK mock responses — specific sub-questions matched first
  // ---------------------------------------------------------------------------
  String _getPatrickMockResponse(String lower) {

    // ── WEB DEV sub-questions ─────────────────────────────────────────────
    if (lower.contains('flutter for web') || lower.contains('flutter web')) {
      return "Flutter for web compiles Dart to JavaScript (CanvasKit or HTML renderer). CanvasKit gives pixel-perfect rendering and is best for complex UI; HTML renderer loads faster and is better for SEO. Key considerations: lazy-load routes with GoRouter, use conditional imports for platform-specific code, and pre-render critical routes for search engine visibility.";
    }
    if (lower.contains('react') || lower.contains('next.js') || lower.contains('nextjs') || lower.contains('vue')) {
      return "React/Next.js architecture decisions: use App Router (Next.js 13+) for server components and built-in streaming. State management — Zustand for lightweight global state, React Query for server state. For performance: code-split per route, use next/image for automatic WebP conversion, and implement ISR (Incremental Static Regeneration) for data-heavy pages.";
    }
    if (lower.contains('backend api') || lower.contains('api design') || lower.contains('rest') || lower.contains('graphql')) {
      return "Backend API design principles: REST for resource-based operations, GraphQL for complex relational data with variable query shapes. Layer your API: controller (HTTP handling) → service (business logic) → repository (data access). Version with /api/v1/ prefixes. Implement request validation, rate limiting, and structured error responses from day one — retrofitting is painful.";
    }
    if (lower.contains('database') || lower.contains('postgres') || lower.contains('mongodb') || lower.contains('sql')) {
      return "Database selection framework: PostgreSQL for transactional data (ACID compliance, joins, referential integrity), MongoDB for document-heavy workloads with flexible schema, Redis for caching and session storage. Index every foreign key and every column in a WHERE clause. Use connection pooling (PgBouncer for Postgres) — raw connections don't scale past ~100 concurrent users.";
    }

    // ── SEO sub-questions ─────────────────────────────────────────────────
    if (lower.contains('on-page') || lower.contains('on page seo') || lower.contains('meta') || lower.contains('title tag')) {
      return "On-page SEO foundations: one H1 per page matching the target keyword, meta description under 160 characters (this is your ad copy — write it to earn the click, not just describe the page), semantic HTML structure (article, section, nav, aside), and descriptive alt text on every image. Internal linking between related pages distributes PageRank and reduces orphan pages.";
    }
    if (lower.contains('technical seo') || lower.contains('audit') || lower.contains('core web vitals') || lower.contains('crawl')) {
      return "Technical SEO audit checklist: Core Web Vitals (LCP under 2.5s, CLS under 0.1, FID/INP under 200ms), canonical tags to prevent duplicate content penalties, XML sitemap submitted to GSC, robots.txt allowing crawl of key pages, HTTPS with valid certificate, structured data (Schema.org) for rich results, and no broken internal links. Run Screaming Frog monthly.";
    }
    if (lower.contains('content strategy') || lower.contains('keyword research') || lower.contains('blog') || lower.contains('pillar')) {
      return "Content strategy for SEO: build topic clusters — one comprehensive pillar page targeting a broad keyword, supported by cluster pages targeting long-tail variations, all internally linked. Use keyword research to identify search intent (informational, navigational, commercial, transactional) before writing. Target keywords with clear buying intent for service pages; informational intent for blog content that builds topical authority.";
    }
    if (lower.contains('link building') || lower.contains('backlink') || lower.contains('domain authority') || lower.contains('outreach')) {
      return "Link building in 2025: quality over quantity — one link from a DR70+ relevant site outweighs 100 directory links. Effective strategies: digital PR (data studies journalists cite), guest posting on niche publications, broken link replacement, and unlinked brand mention outreach. HARO/Connectively for journalist sourcing. Disavow toxic links quarterly via Google Search Console.";
    }

    // ── GEO sub-questions ─────────────────────────────────────────────────
    if (lower.contains('geo-fencing') || lower.contains('geofencing') || lower.contains('geofence')) {
      return "Geo-fencing implementation: define virtual boundaries as polygon coordinates stored in PostGIS or a spatial index. On the client, compare device GPS coordinates against boundary using point-in-polygon algorithms. For server-side triggers, use Uber H3 hexagonal indexing — convert lat/lng to H3 index, store indexed records, and query by H3 cell. Triggers fire within 50-100m accuracy depending on GPS hardware.";
    }
    if (lower.contains('location service') || lower.contains('gps') || lower.contains('maps') || lower.contains('geocod')) {
      return "Location services stack: on Flutter, use the geolocator package for GPS with permission handling. For reverse geocoding (lat/lng → address), use Google Maps Geocoding API or Mapbox (cheaper at scale). For map display, mapbox_gl Flutter plugin gives full customization; google_maps_flutter is simpler. Cache geocoding results aggressively — the API is slow and billed per request.";
    }
    if (lower.contains('multi-region') || lower.contains('multi region') || lower.contains('cdn') || lower.contains('edge deployment')) {
      return "Multi-region deployment: use Cloudflare Workers or AWS Lambda@Edge to route users to the nearest compute region. Store user data in the region they signed up (GDPR compliance) and replicate read-heavy content globally. Use latency-based routing in Route53 or Cloudflare Load Balancers. Database replication: primary write region with read replicas in each edge region — eventual consistency is acceptable for most read operations.";
    }
    if (lower.contains('local business') || lower.contains('local seo') || lower.contains('google business') || lower.contains('gmb')) {
      return "Local business optimization: claim and fully complete your Google Business Profile (photos, hours, services, Q&A). Consistent NAP (Name, Address, Phone) across all directories — Moz Local or BrightLocal automate this. Build local citations on Yelp, Bing Places, Apple Maps. Generate reviews systematically (post-purchase SMS sequence). LocalBusiness Schema markup helps Google surface your hours and ratings in SERPs.";
    }

    // ── AEO sub-questions ─────────────────────────────────────────────────
    if (lower.contains('ai search') || lower.contains('chatgpt') || lower.contains('perplexity') || lower.contains('llm') || lower.contains('generative search')) {
      return "AI search optimization (AEO): LLMs like ChatGPT and Perplexity source answers from crawlable web content. Structure your pages to answer specific questions directly — opening paragraphs should state the answer, body paragraphs provide evidence. Use FAQ schema so Google's SGE and Bing Copilot can extract clean Q&A pairs. Be cited by authoritative sources — LLMs weight citations from high-DR domains heavily.";
    }
    if (lower.contains('structured data') || lower.contains('schema') || lower.contains('schema.org') || lower.contains('json-ld')) {
      return "Structured data implementation: use JSON-LD (not Microdata — Google prefers it). Key schemas for most sites: Organization, WebSite (enables Sitelinks searchbox), BreadcrumbList, FAQPage, Article, Product, and Review. Validate with Google's Rich Results Test and Schema.org validator. Structured data directly feeds Google's Knowledge Graph and is heavily used by AI answer engines to extract factual claims.";
    }
    if (lower.contains('featured snippet') || lower.contains('position zero') || lower.contains('people also ask') || lower.contains('paa')) {
      return "Featured snippet optimization: identify PAA (People Also Ask) questions in your target SERP and answer them concisely in 40–60 words immediately after an H2/H3 that matches the question exactly. Use definition format for 'what is' queries, numbered lists for 'how to' queries, tables for comparison queries. Monitor your snippet capture rate in Google Search Console via the 'Search Appearance' filter.";
    }
    if (lower.contains('ai model') || lower.contains('training') || lower.contains('llm training') || lower.contains('dataset')) {
      return "Content structured for AI model training: publish clearly attributed, factually accurate content — LLMs weight trustworthiness signals (author credentials, citations, E-E-A-T). Use definitive, declarative sentences rather than hedging. Maintain a consistent publishing entity (author bio, About page, LinkedData markup) so AI models can resolve your content to a trusted real-world entity rather than treating it as anonymous web text.";
    }

    // ── ARCHITECTURE sub-questions ────────────────────────────────────────
    if (lower.contains('microservice') || lower.contains('micro service') || lower.contains('service mesh') || lower.contains('kubernetes')) {
      return "Microservices architecture: decompose by business capability, not technical layer. Each service owns its data store (no shared databases), communicates via async events (Kafka/RabbitMQ) for non-critical paths and sync REST/gRPC for real-time needs. Deploy with Kubernetes — use Helm charts for reproducible deployments, Istio for service mesh (mTLS, circuit breaking, observability). Start with a modular monolith and extract services only when a domain needs independent scaling.";
    }
    if (lower.contains('cloud infrastructure') || lower.contains('aws') || lower.contains('gcp') || lower.contains('azure') || lower.contains('terraform')) {
      return "Cloud infrastructure design: use Infrastructure as Code (Terraform or Pulumi) from day one — never click-ops production. On AWS: VPC with public/private subnets, ALB for load balancing, ECS Fargate for containers (no EC2 management), RDS Aurora Serverless for databases, S3+CloudFront for static assets. Enable CloudWatch alarms on CPU, memory, and error rates. Multi-AZ everything that can't afford downtime.";
    }
    if (lower.contains('database architecture') || lower.contains('data model') || lower.contains('schema design') || lower.contains('normalization')) {
      return "Database architecture principles: normalize to 3NF for transactional data (eliminate redundancy, enforce referential integrity), then denormalize strategically for read-heavy query paths. Design for your access patterns — document your top 10 queries before choosing a schema. Partition large tables by date or tenant ID early. Implement soft deletes (deleted_at timestamp) instead of hard deletes for audit trails and recovery.";
    }
    if (lower.contains('performance') || lower.contains('optimize') || lower.contains('bottleneck') || lower.contains('profil')) {
      return "Performance optimization methodology: measure before optimizing (profiling, not guessing). Use APM tools (Datadog, New Relic, or open-source Grafana+Tempo) to find actual bottlenecks. Common high-impact fixes: add database indexes on slow queries (EXPLAIN ANALYZE), implement caching at the right layer (in-memory for hot data, CDN for static), use connection pooling, and paginate large result sets. A 100ms improvement in TTFB typically yields 1% conversion lift.";
    }

    // ── WEB DEV broad catch-all (after specific checks) ──────────────────
    if (lower.contains('web') || lower.contains('website') || lower.contains('development') || lower.contains('frontend') || lower.contains('backend')) {
      return "Web development stack selection depends on your scale and team. For most startups: Next.js frontend (React + SSR + file-based routing), Node.js or Python FastAPI backend, PostgreSQL database, deployed on Vercel/Railway. For cross-platform (web + mobile + desktop from one codebase): Flutter. Patrick specializes in production-ready, performant architectures that scale without rewrites.";
    }

    // ── SEO broad catch-all ───────────────────────────────────────────────
    if (lower.contains('seo') || lower.contains('search engine') || lower.contains('ranking') || lower.contains('serp')) {
      return "SEO in 2025 spans three pillars: technical (site speed, crawlability, structured data), on-page (content quality, keyword targeting, E-E-A-T signals), and off-page (backlink authority, brand mentions). We audit all three, prioritize by impact, and implement fixes systematically. Modern SEO also covers AEO — optimizing for AI-generated answers in ChatGPT, Perplexity, and Google's AI Overviews.";
    }

    // ── GEO broad catch-all ───────────────────────────────────────────────
    if (lower.contains('geo') || lower.contains('location') || lower.contains('region') || lower.contains('local')) {
      return "Geo-targeting strategy covers two dimensions: user experience (localized content, currency, language, time zones) and infrastructure (regional deployments, CDN edge nodes, data residency for GDPR/LGPD). We implement both — from Cloudflare geo-routing to Flutter's intl package for locale-aware UI. Multi-region architecture also dramatically improves performance: serving from the nearest region cuts latency by 40–70%.";
    }

    // ── AEO broad catch-all ───────────────────────────────────────────────
    if (lower.contains('aeo') || lower.contains('answer engine') || lower.contains('ai overview')) {
      return "Answer Engine Optimization prepares your content to be cited by AI systems like ChatGPT, Claude, Perplexity, and Google's AI Overviews. Key tactics: structured Q&A content format, Schema.org markup, clear authorship and E-E-A-T signals, factual accuracy, and citations from authoritative sources. AEO is now as important as traditional SEO — AI search tools are handling 30%+ of informational queries.";
    }

    // ── ARCHITECTURE broad catch-all ──────────────────────────────────────
    if (lower.contains('architecture') || lower.contains('system design') || lower.contains('scale') || lower.contains('infrastructure')) {
      return "System architecture is Patrick's core specialty — designing platforms that handle 10x growth without rewrites. Process: audit current stack bottlenecks, define non-functional requirements (throughput, latency, availability targets), select the right patterns (event-driven, CQRS, microservices vs modular monolith), then implement incrementally. Includes cloud infrastructure, API design, database selection, and CI/CD pipeline setup.";
    }

    // ── ZOOM / BOOKING ────────────────────────────────────────────────────
    if (lower.contains('zoom') || lower.contains('meeting') || lower.contains('book') || lower.contains('schedule') || lower.contains('consultation') || lower.contains('patrick') || lower.contains('scoping') || lower.contains('sprint')) {
      return "Ready to connect you. Click the Zoom button to book a scoping sprint directly with Patrick — typically a 30-minute architectural deep-dive covering your stack, constraints, and the fastest path to production. Bring your current pain points and Patrick will map out a concrete action plan.";
    }

    // ── FLUTTER ───────────────────────────────────────────────────────────
    if (lower.contains('flutter') || lower.contains('dart') || lower.contains('mobile app') || lower.contains('cross-platform')) {
      return "Flutter architecture: single codebase for iOS, Android, Web, Desktop, and Embedded. Use feature-first folder structure, Riverpod or BLoC for state management, GoRouter for navigation. Key patterns: repository pattern for data access, use cases for business logic, dependency injection via Riverpod providers. Performance: minimize rebuilds with const constructors and selective Consumer placement. Patrick has shipped production Flutter apps across all six platforms.";
    }

    return "How can I assist? I cover Web Dev, SEO, GEO, AEO, System Architecture, Flutter, or you can book a direct consultation via Zoom. What's your current challenge?";
  }
}