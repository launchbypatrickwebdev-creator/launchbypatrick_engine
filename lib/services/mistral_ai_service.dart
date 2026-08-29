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
    if (config.assistantName == "SENTINEL_CORE_AI") {
      return _getSentinelMockResponse(lower);
    }

    // ── LAUNCHBYPATRICK PROFILE ───────────────────────────────────────────────
    return _getPatrickMockResponse(lower);
  }

  // ---------------------------------------------------------------------------
  // SENTINEL mock responses — specific sub-questions matched first
  // ---------------------------------------------------------------------------
  String _getSentinelMockResponse(String lower) {

    // ESP32 sub-questions
    if (lower.contains('gpio') || lower.contains('pin configuration') || lower.contains('pin mapping')) {
      return "GPIO configuration starts with mapping your pin roles: INPUT, OUTPUT, or INPUT_PULLUP. On the ESP32, pins 34–39 are input-only. Use digitalWrite() for outputs and digitalRead() for inputs. Always check your specific board's pinout diagram — the NodeMCU-32S and WROOM-32 differ in physical layout.";
    }
    if (lower.contains('wifi') || lower.contains('ble') || lower.contains('bluetooth') || lower.contains('connectivity')) {
      return "The ESP32 supports dual-mode WiFi (802.11 b/g/n) and Bluetooth 4.2 BLE simultaneously. For WiFi: use WiFi.begin(ssid, password) and poll WiFi.status() until WL_CONNECTED. For BLE: use the BLEDevice library. Running both simultaneously increases power draw — consider sleep cycles if on battery.";
    }
    if (lower.contains('power') || lower.contains('battery') || lower.contains('deep sleep') || lower.contains('low power')) {
      return "ESP32 power management is critical for battery deployments. Deep sleep can reduce current from ~240mA active to ~10µA. Use esp_deep_sleep_start() and configure wake sources (timer, GPIO, touchpad). Typical battery life goes from hours to months with proper sleep cycles implemented.";
    }
    if (lower.contains('firmware flashing') || lower.contains('flash') || lower.contains('upload') || lower.contains('esptool')) {
      return "Firmware flashing via esptool.py: ensure you have the correct COM port, set baud rate to 115200 or 921600 for speed, and hold the BOOT button during upload if auto-reset fails. For OTA flashing, ArduinoOTA or the ESP-IDF OTA partition scheme handles wireless updates without physical access.";
    }

    // Firmware sub-questions
    if (lower.contains('ota') || lower.contains('over-the-air')) {
      return "OTA update flow: partition your flash into OTA_0 and OTA_1 slots. The running firmware validates and writes the new binary to the inactive slot, then sets it as boot target and resets. If the new firmware fails its health check, the bootloader rolls back to the previous slot automatically. Always validate checksums before committing.";
    }
    if (lower.contains('version') || lower.contains('compatibility') || lower.contains('rollback')) {
      return "Version management: embed a semantic version string in your firmware binary and expose it via a /version endpoint or BLE characteristic. Before flashing, compare versions and block downgrades unless explicitly authorized. Keep the previous OTA slot intact as your rollback target for at least one update cycle.";
    }
    if (lower.contains('custom firmware') || lower.contains('build') || lower.contains('compile')) {
      return "Custom firmware builds use either Arduino IDE (easier, slower) or ESP-IDF (full control, faster, recommended for production). ESP-IDF uses CMake-based builds — configure via menuconfig, then idf.py build. Partition tables, component dependencies, and linker scripts give you precise control over memory layout and feature inclusion.";
    }

    // Security sub-questions
    if (lower.contains('encryption') || lower.contains('tls') || lower.contains('ssl') || lower.contains('mbedtls')) {
      return "ESP32 hardware accelerates AES, SHA, RSA, and ECC via the cryptographic co-processor. For TLS connections use WiFiClientSecure with mbedTLS — embed your CA certificate as a PEM string. For local data, use AES-256-GCM for authenticated encryption. Never store raw keys in flash; use the NVS encrypted partition instead.";
    }
    if (lower.contains('secure boot') || lower.contains('signed')) {
      return "Secure Boot V2 on ESP32 uses RSA-PSS signature verification — the bootloader checks each firmware stage before execution. Generate your signing key offline, burn the public key hash to eFuse (one-time write), and sign every binary before flashing. Once enabled, unsigned firmware is rejected at boot — there is no override without physical eFuse access.";
    }
    if (lower.contains('authentication') || lower.contains('auth') || lower.contains('token') || lower.contains('certificate')) {
      return "IoT authentication layers: device-level (X.509 certificates or pre-shared keys), session-level (JWT tokens with short TTL), and transport-level (mutual TLS). For MQTT: use client certificates with your broker. For HTTP APIs: HMAC-signed requests prevent replay attacks. Rotate credentials on a schedule and revoke immediately on device compromise.";
    }
    if (lower.contains('network security') || lower.contains('hardening') || lower.contains('firewall')) {
      return "Network hardening for IoT: isolate devices on a dedicated VLAN, disable unused services (Telnet, FTP, UPnP), enforce allowlists for outbound connections, and monitor traffic for anomalies. On the firmware side, validate all incoming payloads, enforce size limits to prevent buffer overflows, and log failed authentication attempts.";
    }

    // Diagnostics sub-questions
    if (lower.contains('sensor health') || lower.contains('health check')) {
      return "Sensor health checks: read each sensor at startup and log baseline values. During operation, flag readings outside ±3σ of historical mean as suspect. For critical sensors, implement dual-sensor cross-validation. Report health status via a heartbeat payload every 60 seconds — silence for >2 cycles triggers an alert.";
    }
    if (lower.contains('connection diagnostic') || lower.contains('ping') || lower.contains('latency') || lower.contains('packet')) {
      return "Connection diagnostics: measure round-trip latency with ICMP ping or application-level echo packets. Track packet loss percentage over a rolling 100-packet window. Log RSSI for WiFi signal strength — below -70 dBm causes reliability issues. For MQTT, monitor reconnection frequency as a proxy for connection stability.";
    }
    if (lower.contains('performance metric') || lower.contains('throughput') || lower.contains('benchmark')) {
      return "Performance metrics to track: heap free memory (alert if below 20KB), CPU load per core (use esp_cpu_get_core_id()), task stack high-water marks, and interrupt latency. Use FreeRTOS task stats (vTaskGetRunTimeStats()) to identify CPU hogs. Log to serial during development, push to your telemetry backend in production.";
    }
    if (lower.contains('error log') || lower.contains('crash') || lower.contains('coredump') || lower.contains('stack trace')) {
      return "Error logging: use ESP-IDF's esp_log system with log levels (ESP_LOGE for errors, ESP_LOGW for warnings). Enable core dumps to flash or UART — on crash, the coredump captures register state and stack. Use idf.py coredump-info to decode. Store the last N error events in NVS so they survive resets for post-mortem analysis.";
    }

    // Sensor sub-questions
    if (lower.contains('temperature') || lower.contains('dht') || lower.contains('ds18b20') || lower.contains('thermal')) {
      return "Temperature sensors: DHT22 gives ±0.5°C accuracy over I2C/1-Wire, DS18B20 gives ±0.5°C on 1-Wire with multiple sensors per pin. For industrial accuracy, use a PT100 RTD with a MAX31865 amplifier (±0.1°C). Always read twice and discard if the delta exceeds your calibration tolerance — single-point reads miss transient spikes.";
    }
    if (lower.contains('humidity') || lower.contains('moisture') || lower.contains('hygrometer')) {
      return "Humidity measurement: DHT22 and SHT31 are common choices — SHT31 is more accurate (±2% RH) and has better long-term stability. Calibrate against a saturated salt solution reference (75% RH for NaCl). Shield the sensor from direct airflow and condensation. Compensate readings with the Sonntag formula when temperature varies rapidly.";
    }
    if (lower.contains('distance') || lower.contains('proximity') || lower.contains('ultrasonic') || lower.contains('lidar') || lower.contains('hc-sr04')) {
      return "Distance sensing options: HC-SR04 ultrasonic works 2cm–4m with ±3mm accuracy, suitable for most presence detection. For precision, TF-Luna LiDAR gives ±6cm up to 8m. VL53L1X ToF sensor handles 1mm–4m in a tiny I2C package. For liquid level, JSN-SR04T is waterproof. Average multiple readings to filter ultrasonic interference.";
    }
    if (lower.contains('data collection') || lower.contains('sampling') || lower.contains('frequency') || lower.contains('interval')) {
      return "Data collection strategy: match your sampling rate to the physical phenomenon — temperature changes slowly (1/min is fine), vibration needs 1kHz+. Use circular buffers in RAM for high-frequency bursts, flush to NVS or transmit via MQTT periodically. Timestamp every reading with NTP-synchronized time. Delta encoding reduces transmission size by 60–80% for slowly-changing signals.";
    }

    // Schedule/Sync
    if (lower.contains('zoom') || lower.contains('meeting') || lower.contains('sync') || lower.contains('schedule') || lower.contains('consultation') || lower.contains('deep-dive') || lower.contains('deployment')) {
      return "Ready to coordinate. Click the Zoom button above to lock in a hardware synchronization session with the Sentinel team — we'll cover your specific firmware, sensor, or security requirements in depth.";
    }

    return "SENTINEL_CORE_OS operational. Specify your challenge: ESP32 configuration, firmware, security, sensors, or diagnostics. Or click Zoom to book a direct technical sync.";
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