import 'package:campus/core/cache/in_memory_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryCache Tests', () {
    late InMemoryCache cache;

    setUp(() {
      cache = InMemoryCache();
      cache.clear();
    });

    test('Sets and retrieves cached values within TTL', () {
      cache.set('key1', 'sample_data', ttl: const Duration(minutes: 5));
      final value = cache.get<String>('key1');
      expect(value, equals('sample_data'));
    });

    test('Returns null and removes expired cache entries', () async {
      cache.set('key2', 'expiring_data', ttl: const Duration(milliseconds: 50));
      await Future<void>.delayed(const Duration(milliseconds: 60));

      final value = cache.get<String>('key2');
      expect(value, isNull);
    });

    test('Invalidates specific key cleanly', () {
      cache.set('key3', 'data_to_remove');
      cache.invalidate('key3');
      expect(cache.get<String>('key3'), isNull);
    });
  });
}
