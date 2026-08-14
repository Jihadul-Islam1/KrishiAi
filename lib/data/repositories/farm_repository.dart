import '../models/farm.dart';
import 'local_store.dart';

class FarmRepository {
  FarmRepository(this._store);

  static const _key = 'farms';
  final LocalStore _store;

  /// Returns the user's farms. Empty list if none have been added yet.
  /// The app does not seed demo data; users add their own farms.
  Future<List<Farm>> farms() async {
    final raw = _store.readJson(_key);
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().map(Farm.fromJson).toList();
    }
    return const <Farm>[];
  }

  Future<void> saveAll(List<Farm> farms) => _saveList(farms);

  Future<Farm?> farmById(String id) async {
    final all = await farms();
    try {
      return all.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(Farm farm) async {
    final all = await farms();
    final idx = all.indexWhere((f) => f.id == farm.id);
    if (idx >= 0) {
      all[idx] = farm;
    } else {
      all.add(farm);
    }
    await _saveList(all);
  }

  Future<void> delete(String id) async {
    final all = await farms();
    all.removeWhere((f) => f.id == id);
    await _saveList(all);
  }

  Future<void> _saveList(List<Farm> farms) async {
    await _store.writeJson(_key, farms.map((f) => f.toJson()).toList());
  }
}
