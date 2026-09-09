class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  const CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class InMemoryCache {
  static final InMemoryCache _instance = InMemoryCache._internal();
  factory InMemoryCache() => _instance;
  InMemoryCache._internal();

  final Map<String, CacheEntry<dynamic>> _store = {};

  void set<T>(String key, T value,
      {Duration ttl = const Duration(minutes: 10)}) {
    _store[key] = CacheEntry<T>(
      data: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  void invalidate(String key) {
    _store.remove(key);
  }

  void clear() {
    _store.clear();
  }
}
