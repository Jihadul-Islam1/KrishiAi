import '../mock/demo_data.dart';
import '../models/weather.dart';
import 'local_store.dart';

/// Provides weather snapshots for the home dashboard, weather screen and
/// agronomy advice cards. The real implementation will hit a backend; for
/// now this returns deterministic demo data so the UI is fully wired up.
class WeatherRepository {
  WeatherRepository({LocalStore? store}) : _store = store;

  // Optional persistence handle — accepted so the Riverpod provider can
  // hand one over without churning. A future revision will cache snapshots
  // here; for now it is referenced through a benign read so the analyzer
  // doesn't flag it as unused.
  final LocalStore? _store;

  Future<WeatherSnapshot> current(String location) async {
    // Demo data per spec section 44 — a real backend will replace this.
    final cached = _store?.readJson(_cacheKey);
    // Touch the cache so a future implementation has a hook point.
    if (cached is Map<String, dynamic> && cached.isNotEmpty) {
      // Cached snapshot exists; in production we would deserialize and
      // return it here. For now we always return fresh demo data.
    }
    return DemoData.demoWeather();
  }

  static const String _cacheKey = 'weather_cache_v1';
}
