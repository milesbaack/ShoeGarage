import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'services/app_group_service.dart';
import 'services/assignment_queue_processor.dart';
import 'services/health_kit_service.dart';
import 'services/historical_sync_service.dart';
import 'services/notification_service.dart';
import 'services/shoe_photo_service.dart';
import 'services/tip_jar_service.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/rotation_analytics_calculator.dart';
import '../core/utils/unit_formatter.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final shoePhotoServiceProvider = Provider<ShoePhotoService>((ref) {
  return ShoePhotoService();
});

final appGroupServiceProvider = Provider<AppGroupService>((ref) {
  return AppGroupService();
});

final healthKitServiceProvider = Provider<HealthKitService>((ref) {
  return HealthKitService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final assignmentQueueProcessorProvider = Provider<AssignmentQueueProcessor>((ref) {
  return AssignmentQueueProcessor(
    appGroupService: ref.watch(appGroupServiceProvider),
    database: ref.watch(databaseProvider),
    healthKitService: ref.watch(healthKitServiceProvider),
  );
});

final historicalSyncServiceProvider = Provider<HistoricalSyncService>((ref) {
  return HistoricalSyncService(
    healthKitService: ref.watch(healthKitServiceProvider),
    database: ref.watch(databaseProvider),
  );
});

// Stream provider for active shoes
final activeShoesProvider = StreamProvider<List<Shoe>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchActiveShoes();
});

// Stream provider for retired shoes
final retiredShoesProvider = StreamProvider<List<Shoe>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRetiredShoes();
});

// Stream provider for unassigned activities (Inbox)
final unassignedActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchUnassignedActivities();
});

// Stream provider for a single shoe by ID
final shoeByIdProvider = StreamProvider.family<Shoe?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.watchShoeById(id);
});

// Stream provider for activities belonging to a specific shoe
final activitiesForShoeProvider = StreamProvider.family<List<Activity>, String>((ref, shoeId) {
  final db = ref.watch(databaseProvider);
  return db.watchActivitiesForShoe(shoeId);
});

// Stream provider for assigned activities (History)
final assignedActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAssignedActivities();
});

// Stream provider for workout defaults
final workoutDefaultsProvider = StreamProvider<List<WorkoutDefault>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchWorkoutDefaults();
});

// Map provider mapping workoutType -> shoeId
final defaultShoeMapProvider = Provider<Map<String, String>>((ref) {
  final defaultsAsync = ref.watch(workoutDefaultsProvider);
  final defaults = defaultsAsync.asData?.value ?? [];
  return {for (final d in defaults) d.workoutType: d.shoeId};
});

// Stream provider for raw distance unit setting ('mi' or 'km')
final distanceUnitSettingProvider = StreamProvider<String?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSetting('distance_unit');
});

// DistanceUnit enum provider (defaults to DistanceUnit.miles)
final unitPreferenceProvider = Provider<DistanceUnit>((ref) {
  final settingAsync = ref.watch(distanceUnitSettingProvider);
  final settingValue = settingAsync.asData?.value;
  return UnitFormatter.parseUnit(settingValue);
});

// Provider calculating rotation analytics from active shoes and assigned activities
final rotationAnalyticsProvider = Provider<RotationAnalytics>((ref) {
  final activeShoes = ref.watch(activeShoesProvider).asData?.value ?? [];
  final assignedActivities = ref.watch(assignedActivitiesProvider).asData?.value ?? [];
  return RotationAnalyticsCalculator.calculate(
    activeShoes: activeShoes,
    assignedActivities: assignedActivities,
  );
});

// Family provider for individual shoe projection by shoeId
final shoeProjectionProvider = Provider.family<ShoeProjection?, String>((ref, shoeId) {
  final analytics = ref.watch(rotationAnalyticsProvider);
  return analytics.shoeProjections.where((p) => p.shoe.id == shoeId).firstOrNull;
});

// Tip Jar Service Provider (StoreKit In-App Purchases)
final tipJarServiceProvider = Provider<TipJarService>((ref) {
  final service = TipJarService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider streaming whether the user has completed the onboarding tour
final hasCompletedOnboardingProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSetting(AppConstants.onboardingCompletedKey).map((val) => val == 'true');
});


