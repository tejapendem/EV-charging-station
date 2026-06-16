import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'EV Connect India';
  static const String appTagline = 'Powering India\'s EV Revolution';
  static const String appDescription =
      'Find, compare, and navigate to EV charging stations across India. '
      'Supporting all major charger types including CCS2, CHAdeMO, Type 2, GB/T, '
      'Bharat AC-001, and Bharat DC-001.';

  // Shared Preferences Keys
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefThemeMode = 'theme_mode';
  static const String prefSearchHistory = 'search_history';
  static const String prefFcmToken = 'fcm_token';
  static const String prefLastKnownLatitude = 'last_known_lat';
  static const String prefLastKnownLongitude = 'last_known_lng';
  static const String prefNotificationEnabled = 'notification_enabled';
  static const String prefLocationEnabled = 'location_enabled';
  static const String prefBiometricEnabled = 'biometric_enabled';

  // Secure Storage Keys
  static const String secureAuthToken = 'auth_token';
  static const String secureRefreshToken = 'refresh_token';
  static const String secureUserId = 'user_id';
  static const String secureUserEmail = 'user_email';

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Padding & Margins
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 999.0;

  // Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Station List
  static const double stationCardImageSize = 80.0;
  static const double stationCardHeight = 180.0;
  static const double mapCardHeight = 120.0;

  // Bottom Navigation
  static const int bottomNavHome = 0;
  static const int bottomNavFavorites = 1;
  static const int bottomNavBookings = 2;
  static const int bottomNavProfile = 3;

  // Charging Tips
  static const List<String> chargingTips = [
    'Charge your EV between 20% to 80% for optimal battery health',
    'Use DC fast charging only when needed to preserve battery life',
    'Pre-condition your battery while navigating to a charger',
    'Avoid charging in extreme temperatures when possible',
    'Register for multiple charging networks for wider access',
    'Keep your charging cable clean and properly stored',
    'Plan charging stops for long trips using our route planner',
    'Check charger availability before heading to a station',
  ];

  // EV Facts
  static const List<String> evFacts = [
    'EVs convert over 77% of electrical energy to wheel power',
    'India aims for 30% EV penetration by 2030',
    'EVs have 70% lower maintenance costs than ICE vehicles',
    'FAME II scheme provides subsidies for EV purchases in India',
    'One liter of petrol produces 2.3 kg of CO2',
    'EV batteries can be recycled up to 95%',
    'India has over 5,000 public charging stations (2024)',
  ];

  // Error Messages
  static const String errorNetwork = 'No internet connection';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnauthorized = 'Session expired. Please login again.';
  static const String errorUnknown = 'Something went wrong. Please try again.';
  static const String errorLocationDenied = 'Location permission is required to find nearby stations.';
  static const String errorLocationDisabled = 'Please enable GPS to find nearby stations.';

  // Success Messages
  static const String successFavoriteAdded = 'Added to favorites';
  static const String successFavoriteRemoved = 'Removed from favorites';
  static const String successReviewAdded = 'Review submitted successfully';
  static const String successReportSubmitted = 'Report submitted successfully';
  static const String successProfileUpdated = 'Profile updated successfully';
  static const String successPasswordReset = 'Password reset link sent to your email';

  // Sharing
  static const String shareStationText = 'Check out this EV charging station on EV Connect India';
  static const String shareAppText = 'Download EV Connect India - Find EV charging stations across India';

  // Support
  static const String supportEmail = 'support@evconnectindia.com';
  static const String supportPhone = '+91-1800-EV-INDIA';
  static const String website = 'https://www.evconnectindia.com';
  static const String privacyPolicy = 'https://www.evconnectindia.com/privacy';
  static const String termsOfService = 'https://www.evconnectindia.com/terms';

  // Feature Flags
  static const bool enableBooking = true;
  static const bool enablePayment = true;
  static const bool enableRoutePlanning = true;
  static const bool enableStationRequests = true;
  static const bool enableCommunityFeatures = true;
  static const bool enableReferralProgram = true;
}

// SVG Asset paths
class AssetPaths {
  AssetPaths._();

  static const String logo = 'assets/images/logo.svg';
  static const String logoWhite = 'assets/images/logo_white.svg';
  static const String onboarding1 = 'assets/images/onboarding_1.svg';
  static const String onboarding2 = 'assets/images/onboarding_2.svg';
  static const String onboarding3 = 'assets/images/onboarding_3.svg';
  static const String emptyFavorites = 'assets/images/empty_favorites.svg';
  static const String emptyStations = 'assets/images/empty_stations.svg';
  static const String emptyBookings = 'assets/images/empty_bookings.svg';
  static const String emptyNotifications = 'assets/images/empty_notifications.svg';
  static const String chargerCCS2 = 'assets/images/charger_ccs2.svg';
  static const String chargerChademo = 'assets/images/charger_chademo.svg';
  static const String chargerType2 = 'assets/images/charger_type2.svg';
  static const String chargerGBT = 'assets/images/charger_gbt.svg';
  static const String chargerBharatAC = 'assets/images/charger_bharat_ac.svg';
  static const String chargerBharatDC = 'assets/images/charger_bharat_dc.svg';
  static const String chargerTesla = 'assets/images/charger_tesla.svg';
  static const String illustration404 = 'assets/images/illustration_404.svg';
}

// Firebase Analytics Events
class AnalyticsEvents {
  AnalyticsEvents._();

  static const String appOpen = 'app_open';
  static const String screenView = 'screen_view';
  static const String stationSearch = 'station_search';
  static const String stationView = 'station_view';
  static const String stationBook = 'station_book';
  static const String favoriteAdd = 'favorite_add';
  static const String favoriteRemove = 'favorite_remove';
  static const String reviewAdd = 'review_add';
  static const String reportSubmit = 'report_submit';
  static const String filterApplied = 'filter_applied';
  static const String navigationStarted = 'navigation_started';
  static const String shareStation = 'share_station';
  static const String signUp = 'sign_up';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String errorOccurred = 'error_occurred';
}
