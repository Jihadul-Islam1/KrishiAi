import '../models/crop.dart';
import 'local_store.dart';

class CropRepository {
  CropRepository(this._store);

  static const _key = 'crops';
  final LocalStore _store;

  /// Returns the user's crops. Empty list if none have been added yet.
  /// The app does not seed demo data; users build their own crop list.
  Future<List<Crop>> crops() async {
    final raw = _store.readJson(_key);
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().map(Crop.fromJson).toList();
    }
    return const <Crop>[];
  }

  Future<List<Crop>> cropsForFarm(String farmId) async {
    final all = await crops();
    return all.where((c) => c.farmId == farmId).toList();
  }

  Future<Crop?> cropById(String id) async {
    final all = await crops();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(Crop crop) async {
    final all = await crops();
    final idx = all.indexWhere((c) => c.id == crop.id);
    if (idx >= 0) {
      all[idx] = crop;
    } else {
      all.add(crop);
    }
    await _saveList(all);
  }

  Future<void> delete(String id) async {
    final all = await crops();
    all.removeWhere((c) => c.id == id);
    await _saveList(all);
  }

  Future<void> _saveList(List<Crop> crops) async {
    await _store.writeJson(_key, crops.map((c) => c.toJson()).toList());
  }
}
