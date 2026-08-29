// lib/models/suggestion_pill.dart

/// Represents a suggestion pill with main action and submenu options
class SuggestionPill {
  final String title;
  final String mainAction;
  final List<String> submenuOptions;
  final String icon; // emoji or icon name

  const SuggestionPill({
    required this.title,
    required this.mainAction,
    required this.submenuOptions,
    required this.icon,
  });
}

/// Profile-specific suggestions
class SuggestionProfiles {
  /// LaunchByPatrick profile suggestions
  static const List<SuggestionPill> patrickSuggestions = [
    SuggestionPill(
      title: 'Web Dev',
      mainAction: 'Tell me about web development services and capabilities',
      submenuOptions: [
        'Flutter for web applications',
        'React/Next.js architecture',
        'Backend API design',
        'Database optimization',
      ],
      icon: '🌐',
    ),
    SuggestionPill(
      title: 'SEO',
      mainAction: 'How can I improve my website SEO?',
      submenuOptions: [
        'On-page SEO optimization',
        'Technical SEO audit',
        'Content strategy for SEO',
        'Link building strategies',
      ],
      icon: '🔍',
    ),
    SuggestionPill(
      title: 'GEO',
      mainAction: 'Explain geo-targeting and location-based features',
      submenuOptions: [
        'Geo-fencing implementation',
        'Location services integration',
        'Multi-region deployment',
        'Local business optimization',
      ],
      icon: '📍',
    ),
    SuggestionPill(
      title: 'AEO',
      mainAction: 'What is Answer Engine Optimization for AI search?',
      submenuOptions: [
        'AI search engine optimization',
        'Structured data markup',
        'Featured snippet optimization',
        'AI model training considerations',
      ],
      icon: '🤖',
    ),
    SuggestionPill(
      title: 'Architecture',
      mainAction: 'Design a scalable system architecture for my project',
      submenuOptions: [
        'Microservices architecture',
        'Cloud infrastructure design',
        'Database architecture',
        'Performance optimization',
      ],
      icon: '🏗️',
    ),
    SuggestionPill(
      title: 'Zoom Call',
      mainAction: 'I want to book a consultation with Patrick',
      submenuOptions: [
        'Schedule architecture review',
        'Product strategy session',
        'Team technical training',
        'Project scope discussion',
      ],
      icon: '📹',
    ),
  ];

  /// Sentinel profile suggestions
  static const List<SuggestionPill> sentinelSuggestions = [
    SuggestionPill(
      title: 'ESP32',
      mainAction: 'Help me configure and optimize my ESP32 device',
      submenuOptions: [
        'GPIO configuration',
        'WiFi/BLE connectivity',
        'Power management',
        'Firmware flashing process',
      ],
      icon: '🔧',
    ),
    SuggestionPill(
      title: 'Firmware',
      mainAction: 'Guide me through firmware updates and management',
      submenuOptions: [
        'OTA update process',
        'Version compatibility',
        'Rollback procedures',
        'Custom firmware building',
      ],
      icon: '⚙️',
    ),
    SuggestionPill(
      title: 'Security',
      mainAction: 'Implement security measures for my IoT system',
      submenuOptions: [
        'Encryption protocols',
        'Authentication methods',
        'Secure boot configuration',
        'Network security hardening',
      ],
      icon: '🔒',
    ),
    SuggestionPill(
      title: 'Diagnostics',
      mainAction: 'Run hardware diagnostics and troubleshooting',
      submenuOptions: [
        'Sensor health checks',
        'Connection diagnostics',
        'Performance metrics',
        'Error log analysis',
      ],
      icon: '📊',
    ),
    SuggestionPill(
      title: 'Sensors',
      mainAction: 'Configure and calibrate sensor networks',
      submenuOptions: [
        'Temperature sensor setup',
        'Humidity calibration',
        'Distance/proximity sensors',
        'Data collection optimization',
      ],
      icon: '📡',
    ),
    SuggestionPill(
      title: 'Sync',
      mainAction: 'Schedule a hardware synchronization meeting via Zoom',
      submenuOptions: [
        'Technical deep-dive consultation',
        'System architecture review',
        'Deployment planning',
        'Performance optimization session',
      ],
      icon: '🛰️',
    ),
  ];

  /// Get suggestions based on profile name
  static List<SuggestionPill> getSuggestions(String assistantName) {
    if (assistantName == "CORTEX_AI") {
      return sentinelSuggestions;
    }
    return patrickSuggestions;
  }
}