import '../models/app_notification.dart';
import 'local_store.dart';

class NotificationRepository {
  NotificationRepository(this._store);

  static const _key = 'notifications';
  final LocalStore _store;

  /// Returns the user's notifications. Empty list if none exist yet.
  Future<List<AppNotification>> all() async {
    final raw = _store.readJson(_key);
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
    }
    return const <AppNotification>[];
  }

  Future<void> add(AppNotification notification) async {
    final all = await this.all();
    all.insert(0, notification);
    await _saveList(all);
  }

  /// Marks every notification as read.
  Future<void> markAllRead() async {
    final all = await this.all();
    final updated = all.map((n) => n.copyWith(isRead: true)).toList();
    await _saveList(updated);
  }

  /// Marks a single notification read by id. No-op if it is not present.
  Future<void> markRead(String id) async {
    final all = await this.all();
    final updated = [
      for (final n in all)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    await _saveList(updated);
  }

  Future<int> unreadCount() async {
    final all = await this.all();
    return all.where((n) => !n.isRead).length;
  }

  Future<void> _saveList(List<AppNotification> items) async {
    await _store.writeJson(_key, items.map((n) => n.toJson()).toList());
  }
}