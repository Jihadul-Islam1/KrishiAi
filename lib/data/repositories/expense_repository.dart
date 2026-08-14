import '../models/expense.dart';
import 'local_store.dart';

class ExpenseRepository {
  ExpenseRepository(this._store);

  static const _key = 'expenses';
  final LocalStore _store;

  /// Returns the user's expenses. Empty list if none have been added yet.
  Future<List<Expense>> all() async {
    final raw = _store.readJson(_key);
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Expense.fromJson)
          .toList();
    }
    return const <Expense>[];
  }

  Future<List<Expense>> forCrop(String cropId) async {
    final all = await this.all();
    return all.where((e) => e.cropId == cropId).toList();
  }

  Future<void> add(Expense expense) async {
    final all = await this.all();
    all.insert(0, expense);
    await _saveList(all);
  }

  Future<void> delete(String id) async {
    final all = await this.all();
    all.removeWhere((e) => e.id == id);
    await _saveList(all);
  }

  Future<void> _saveList(List<Expense> items) async {
    await _store.writeJson(_key, items.map((e) => e.toJson()).toList());
  }
}
