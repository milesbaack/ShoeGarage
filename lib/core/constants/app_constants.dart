class AppConstants {
  static const String appGroupId = 'group.com.shoegarage.shared';
  static const String appGroupShoesKey = 'active_shoes';
  static const String appGroupPendingAssignmentsKey = 'pending_assignments';
  
  static const String methodChannelName = 'com.shoegarage/app_group';
  
  // Default target distance in miles for new shoes
  static const double defaultTargetLifespanMiles = 400.0;

  // Web & Legal URLs
  static const String websiteUrl = 'https://milesbaack.github.io/ShoeGarage/';
  static const String privacyPolicyUrl = 'https://milesbaack.github.io/ShoeGarage/privacy.html';
  static const String termsUrl = 'https://milesbaack.github.io/ShoeGarage/terms.html';
  static const String supportUrl = 'https://milesbaack.github.io/ShoeGarage/#support';
  static const String supportEmail = 'support@shoegarage.app';

  // StoreKit In-App Purchase Tip Jar Product IDs
  static const String tipSmallId = 'com.shoegarage.tip.small';
  static const String tipMediumId = 'com.shoegarage.tip.medium';
  static const String tipLargeId = 'com.shoegarage.tip.large';
  static const Set<String> tipProductIds = {
    tipSmallId,
    tipMediumId,
    tipLargeId,
  };

  // App Settings Keys
  static const String onboardingCompletedKey = 'has_completed_onboarding';
}

