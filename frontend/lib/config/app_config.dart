class AppConfig {
  AppConfig._();

  static const String appName = 'EV Connect India';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.evconnectindia.app';

  // API Configuration
  static const String baseUrl = 'http://192.168.0.108:5000/api';
  static const String stagingBaseUrl = 'https://staging-api.evconnectindia.com/v1';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50 MB

  // Location
  static const double defaultLatitude = 20.5937;
  static const double defaultLongitude = 78.9629;
  static const double defaultRadiusKm = 10.0;
  static const double maxRadiusKm = 100.0;

  // Station filters
  static const List<String> availableChargerTypes = [
    'CCS2',
    'CHAdeMO',
    'Type 2',
    'GB/T',
    'Bharat AC-001',
    'Bharat DC-001',
  ];
  static const List<String> chargingSpeeds = [
    'Slow (< 22 kW)',
    'Fast (22-50 kW)',
    'Rapid (50-150 kW)',
    'Ultra-Rapid (> 150 kW)',
  ];

  // Features
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = false;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = true;
  static const bool enablePhoneAuth = true;
  static const bool enableGoogleAuth = true;

  // Firebase
  static const String defaultFirebaseProjectId = 'ev-connect-india';
  static const String fcmTopicAll = 'all_users';
  static const String fcmTopicStationUpdates = 'station_updates';
}
