// lib/data/products_data.dart

class ProductItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String longDescription;
  final String imageUrl;
  final List<String> mediaGallery; // Holds your 4 high-res showcase images
  final String? videoAssetPath;    // Holds your dedicated 360 loop or preview video
  final String detailUrl;
  final String heroTag;
  final List<String> techStack;
  final String metricLabel;
  final String metricValue;
  final List<String> variants;
  final List<String> bulletFeatures;
  final List<Map<String, String>> spatialMatrix; // Clear structure for data tables
  final String primaryActionUrl;    // Link 1: Direct Binary Delivery (.apk / .exe)
  final String primaryActionLabel;  // Text override for the primary action trigger
  final String secondaryActionUrl;  // Link 2: Open Source Repository Hub / Community Discussions

  ProductItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.longDescription,
    required this.imageUrl,
    required this.mediaGallery,
    this.videoAssetPath,
    required this.detailUrl,
    required this.heroTag,
    required this.techStack,
    required this.metricLabel,
    required this.metricValue,
    required this.variants,
    required this.bulletFeatures,
    required this.spatialMatrix,
    required this.primaryActionUrl,
    required this.primaryActionLabel,
    required this.secondaryActionUrl,
  });
}

// 🛰️ MASTER REGISTRY OF INTERNAL AND CUSTOMER-FACING PROJECTS
final List<ProductItem> productsRegistry = [
  ProductItem(
    id: 'el_daniel_keypad',
    title: 'ELDANIEL : INPUT ARCHITECTURE',
    subtitle: 'Precision and Clarity in Every Swipe.',
    description: 'An Android IME (Input Method Editor) that replaces the clutter of 30+ tiny buttons with 8 clear directional swipe paths.',
    longDescription: 'Inspired by the clarity and excellence of Daniel, this system represents a complete paradigm shift in mobile text input, swapping out a cluttered landscape of microscopic buttons for 8 fluid, high-velocity directional vectors. Organised intelligently by linguistic structure rather than randomly scattered like traditional QWERTY boards, it is built intentionally to reduce motor precision thresholds for seniors and individuals with limited manual dexterity, while simultaneously unlocking extreme typing velocities for advanced operators.\n\nOne finger anchors the direction while the second finger taps to cycle and select characters. This system is fast, reduces errors, and lowers the required motor accuracy—turning typing into both a highly accessible practical skill and an intuitive learning experience.',
    imageUrl: 'assets/images/products/el_daniel_main.jpg',
    mediaGallery: [
      'assets/images/products/el_daniel_main.jpg',
      'assets/images/products/el_daniel_layout.jpg',
      'assets/images/products/el_daniel_accessibility.jpg',
      'assets/images/products/el_daniel_metrics.jpg',
    ],
    videoAssetPath: 'assets/videos/el_daniel_pivot_360.mp4',
    detailUrl: '/products/el-daniel-keypad',
    heroTag: 'hero_el_daniel',
    techStack: ['Android IME SDK', 'Kotlin Core', 'Gesture API', 'Haptic Matrix Processing'],
    metricLabel: 'KEY CONGESTION REDUCTION',
    metricValue: '73% MATRIX EFFICIENCY',
    variants: ['ACCESSIBILITY_CORE_BETA', 'HIGH_SPEED_TYPIST_MATRIX'],
    bulletFeatures: [
      'Swift Daniel Logic: Vowels (↑), Power Consonants (→), and Flow Consonants (↓) are just an organic swipe away.',
      'Aggressive Swipe-to-Delete: A long swipe left instantly clears your text canvas—no more hunting for backspace.',
      'Two-Finger Tapdown Pivot: Anchor direction with one finger and execute sub-selections with the second across a full 360° space.',
      'Send & Return Keys: Dedicated custom buttons for instant messaging triggers and structural line breaks.'
    ],
    spatialMatrix: [
      {'zone': 'Vowels', 'dir': '↑ Up', 'array': 'A E I O U Y', 'count': '6'},
      {'zone': 'Power Consonants', 'dir': '→ Right', 'array': 'T N S R H D', 'count': '6'},
      {'zone': 'Flow Consonants', 'dir': '↓ Down', 'array': 'L C M F P B', 'count': '6'},
      {'zone': 'Complex Consonants', 'dir': '← Left', 'array': 'W G V K X Q J Z', 'count': '8'},
      {'zone': 'Numbers 1-5', 'dir': '↗ Up-Right', 'array': '1 2 3 4 5', 'count': '5'},
      {'zone': 'Numbers 6-0', 'dir': '↘ Down-Right', 'array': '6 7 8 9 0', 'count': '5'},
      {'zone': 'Punctuation', 'dir': '↖ Up-Left', 'array': '. , ? ! \'', 'count': '5'},
      {'zone': 'Symbols', 'dir': '↙ Down-Left', 'array': '@ # & / - + × ÷ = etc.', 'count': '-'},
    ],
    primaryActionUrl: 'https://github.com/yourusername/eldaniel/releases/download/v1.0-beta/el_daniel_keypad.apk',
    primaryActionLabel: 'DOWNLOAD KEYPAD APK (BETA)',
    secondaryActionUrl: 'https://github.com/yourusername/eldaniel-keypad',
  ),
  ProductItem(
    id: 'sentinel_core',
    title: 'SENTINEL : CORE IDE & STUDIO',
    subtitle: 'Unified Tactical Hardware Platform & Audit Engine',
    description: 'A professional-grade integrated environment and hardware-intelligent code diagnostics layer engineered to stop firmware debugging by trial-and-error.',
    longDescription: 'Sentinel Core IDE completes an architectural shift from a standalone companion utility into a unified development ecosystem. Built on the high-performance Monaco editor framework, it fuses automated boilerplate engines, multi-model AI auditing councils, and active workspace viewports under a single armor-plated roof. It functions as an automated Senior Systems Architect checking your firmware against strict physical silicon thresholds.\n\nBy leveraging direct native API layers instead of rigid middleware pipelines, Sentinel streams structural configurations, bills of materials, and compiled hex binaries directly to enterprise databases or tracking frameworks with minimal operational latency. It enables developers to step away from basic code patterns and start deploying scalable IoT systems with concrete security.',
    imageUrl: 'assets/images/products/sentinel_studio_main.jpg',
    mediaGallery: [
      'assets/images/products/sentinel_studio_main.jpg',
      'assets/images/products/sentinel_monaco_editor.jpg',
      'assets/images/products/sentinel_api_streams.jpg',
      'assets/images/products/sentinel_hardware_audit.jpg',
    ],
    videoAssetPath: 'assets/videos/sentinel_workspace_walkthrough.mp4',
    detailUrl: '/products/sentinel-core',
    heroTag: 'hero_sentinel_core',
    techStack: ['Monaco Framework', 'C++ / PlatformIO', 'Flutter Application Engine', 'Direct Mistral AI Key Native Call Layer', 'Groq Core'],
    metricLabel: 'FIRMWARE SECURITY GUARDRAILS',
    metricValue: '100% HARDWARE-SAFE DEPLOYMENTS',
    variants: ['STUDIO_WORKSPACE_FREE', 'ENTERPRISE_COMMAND_NODE'],
    bulletFeatures: [
      'NVS "Flash-Killer" Protection: Automatically intercepts destructive Preferences.put or EEPROM.write calls inside loops, injecting state-change logical safety frames.',
      'GPIO Conflict Detection: Evaluates runtime pin assignments straight against targeting board datasheets to freeze SPI/I2C overlaps before you connect physical cables.',
      'Native Direct API Integration: Replaces slow webhook chains with direct, low-latency HTTP/JSON data streams out of your active workspace to live databases.',
      'Unified Zero-Switch Layout: Combines the Falla7 automated boilerplate generation wizard, MiroFish AI Auditing Council, and responsive code windows into a single view.',
      'Traceable Engineering Audits: Flags every structural modification made by internal intelligence engines using clear inline // modify hooks for developer validation.'
    ],
    spatialMatrix: [
      {'zone': 'ESP32 (S2/S3/C3)', 'dir': 'Full Support', 'array': 'SPI/I2C Mapping, Native NVS Flash Interventions, Dual-Core Task Audits', 'count': 'IoT Target'},
      {'zone': 'Arduino (Uno/Nano/Mega)', 'dir': 'Full Support', 'array': 'ATmega328P Ring-Buffer Cleanups, Strict RAM Footprint Limits', 'count': 'AVR Target'},
      {'zone': 'STM32 (Nucleo/BluePill)', 'dir': 'Full Support', 'array': 'HAL Register Overlap Verifications, Hardware Interrupt Protections', 'count': 'ARM Target'},
      {'zone': 'Raspberry Pi Pico', 'dir': 'Full Support', 'array': 'RP2040 PIO Pin Conflict Audits, Dual-Core Execution Path Validations', 'count': 'ARM Target'},
    ],
    primaryActionUrl: 'https://github.com/yourusername/sentinel-studio/releases/download/v1.0/sentinel_app_portable_64bit.exe',
    primaryActionLabel: 'DOWNLOAD SENTINEL STUDIO (PORTABLE)',
    secondaryActionUrl: 'https://github.com/yourusername/sentinel-studio/discussions',
  ),
];