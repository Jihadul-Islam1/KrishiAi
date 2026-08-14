import '../models/farmer.dart';
import 'local_store.dart';

class FarmerRepository {
  FarmerRepository(this._store);

  static const _key = 'farmer_profile';
  final LocalStore _store;

  /// Returns the saved farmer, or `null` if the user has not completed
  /// profile setup yet. Callers must handle the null case (route to
  /// profile setup, show "tap to create your profile", etc.).
  Future<Farmer?> currentFarmer() async {
    final raw = _store.readJson(_key);
    if (raw is Map<String, dynamic>) {
      return Farmer.fromJson(raw);
    }
    return null;
  }

  Future<void> saveFarmer(Farmer farmer) async {
    await _store.writeJson(_key, farmer.toJson());
  }

  Future<void> clear() async {
    await _store.remove(_key);
  }
}
