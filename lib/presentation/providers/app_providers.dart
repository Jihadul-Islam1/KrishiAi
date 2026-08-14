import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/ai_chat.dart';
import '../../data/models/app_notification.dart';
import '../../data/models/crop.dart';
import '../../data/models/diagnosis.dart';
import '../../data/models/disease.dart';
import '../../data/models/expense.dart';
import '../../data/models/farm.dart';
import '../../data/models/farmer.dart';
import '../../data/models/market_price.dart';
import '../../data/models/recommendation.dart';
import '../../data/models/subscription.dart';
import '../../data/models/weather.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/crop_repository.dart';
import '../../data/repositories/disease_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/farm_repository.dart';
import '../../data/repositories/farmer_repository.dart';
import '../../data/repositories/local_store.dart';
import '../../data/repositories/market_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/recommendation_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/weather_repository.dart';
import '../../services/permission_service.dart';
import '../../services/speech_service.dart';
import '../router/app_router.dart';

/// Async-initialized dependencies ----------------------------------------------------

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

final localStoreProvider = FutureProvider<LocalStore>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalStore(prefs);
});

/// Repositories ---------------------------------------------------------------------

final farmerRepoProvider = FutureProvider<FarmerRepository>((ref) async {
  final store = await ref.watch(localStoreProvider.future);
  return FarmerRepository(store);
});

final farmRepoProvider = FutureProvider<FarmRepository>((ref) async {
  final store = await ref.watch(localStoreProvider.future);
  return FarmRepository(store);
});

final cropRepoProvider = FutureProvider<CropRepository>((ref) async {
  final store = await ref.watch(localStoreProvider.future);
  return CropRepository(store);
});

final diseaseRepoProvider = Provider<DiseaseLibraryRepository>((ref) {
  return DiseaseLibraryRepository();
});

final diagnosisRepoProvider = FutureProvider<DiagnosisRepository>((ref) async {
  final store = await ref.watch(localStoreProvider.future);
  return DiagnosisRepository(store);
});

final weatherRepoProvider = Provider<WeatherRepository>((ref) {
  // The provider is sync but the LocalStore comes from a FutureProvider.
  // We expose a thin adapter that lazily resolves the store on first use.
  final storeAsync = ref.watch(localStoreProvider);
  return WeatherRepository(store: storeAsync.valueOrNull);
});

final marketRepoProvider = Provider<MarketRepository>((ref) {
  final storeAsync = ref.watch(localStoreProvider);
  return MarketRepository(store: storeAsync.valueOrNull);
});

final expenseRepoProvider = FutureProvider<ExpenseRepository>((ref) async {
  final store = await ref.watch(localStoreProvider.future);
  return ExpenseRepository(store);
});

final recommendationRepoProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepository();
});

final notificationRepoProvider = FutureProvider<NotificationRepository>((
  ref,
) async {
  final store = await ref.watch(localStoreProvider.future);
  return NotificationRepository(store);
});

final subscriptionRepoProvider = FutureProvider<SubscriptionRepository>((
  ref,
) async {
  final store = await ref.watch(localStoreProvider.future);
  return SubscriptionRepository(store);
});

final aiRepoProvider = FutureProvider<AIRepository>((ref) async {
  final diseaseRepo = ref.watch(diseaseRepoProvider);
  final store = await ref.watch(localStoreProvider.future);
  return AIRepository(diseaseRepo, store);
});

/// Services -------------------------------------------------------------------------

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});

/// Async data providers --------------------------------------------------------------

/// Returns the saved farmer, or `null` if profile setup hasn't been done.
final currentFarmerProvider = FutureProvider<Farmer?>((ref) async {
  final repo = await ref.watch(farmerRepoProvider.future);
  return repo.currentFarmer();
});

final farmsProvider = FutureProvider<List<Farm>>((ref) async {
  final repo = await ref.watch(farmRepoProvider.future);
  return repo.farms();
});

final cropsProvider = FutureProvider<List<Crop>>((ref) async {
  final repo = await ref.watch(cropRepoProvider.future);
  return repo.crops();
});

final diagnosesProvider = FutureProvider<List<Diagnosis>>((ref) async {
  final repo = await ref.watch(diagnosisRepoProvider.future);
  return repo.all();
});

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = await ref.watch(expenseRepoProvider.future);
  return repo.all();
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final repo = await ref.watch(notificationRepoProvider.future);
  return repo.all();
});

final weatherProvider = FutureProvider<WeatherSnapshot?>((ref) async {
  final repo = ref.watch(weatherRepoProvider);
  final farmer = await ref.watch(currentFarmerProvider.future);
  // Falls back to a generic location string when the user hasn't set a
  // district yet (first-run before profile setup).
  return repo.current(farmer?.district ?? 'ঢাকা');
});

final recommendationsProvider = FutureProvider<List<Recommendation>>((ref) async {
  final repo = ref.watch(recommendationRepoProvider);
  return repo.all();
});

final marketPricesProvider = FutureProvider<List<MarketPrice>>((ref) async {
  final repo = ref.watch(marketRepoProvider);
  final farmer = await ref.watch(currentFarmerProvider.future);
  return repo.all(farmer?.district ?? 'ঢাকা');
});

final marketFavoritesProvider = FutureProvider<List<MarketPrice>>((ref) async {
  final repo = ref.watch(marketRepoProvider);
  final farmer = await ref.watch(currentFarmerProvider.future);
  return repo.favorites(farmer?.district ?? 'ঢাকা');
});

final marketCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(marketRepoProvider);
  final farmer = await ref.watch(currentFarmerProvider.future);
  return repo.categories(farmer?.district ?? 'ঢাকা');
});

final diseaseLibraryProvider = FutureProvider<List<Disease>>((ref) async {
  final repo = ref.watch(diseaseRepoProvider);
  return repo.all();
});

final currentSubscriptionProvider = FutureProvider<UserSubscription>((ref) async {
  final repo = await ref.watch(subscriptionRepoProvider.future);
  return repo.current();
});

final aiConversationProvider = FutureProvider<AIConversation>((ref) async {
  final repo = await ref.watch(aiRepoProvider.future);
  return repo.loadConversation();
});

/// Onboarding / first-run gate -------------------------------------------------------

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getBool('onboarding_complete') ?? false;
});

/// ---------------------------------------------------------------------------
/// Router (depends on onboardingCompleteProvider + currentFarmerProvider, so
/// it rebuilds when those values change).
/// ---------------------------------------------------------------------------
final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));