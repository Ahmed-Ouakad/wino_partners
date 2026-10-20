import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/services/secure_caching_service.dart';

class MockFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }
}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureCachingServiceImpl service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureCachingServiceImpl(secureStorage: mockStorage);
  });

  group('SecureCachingService', () {
    test('saveTokens stores access and refresh tokens correctly', () async {
      await service.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      final accessToken = await service.getAccessToken();
      final refreshToken = await service.getRefreshToken();

      expect(accessToken, 'access_123');
      expect(refreshToken, 'refresh_456');
    });

    test('clearAll removes all stored tokens', () async {
      await service.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      await service.clearAll();

      final accessToken = await service.getAccessToken();
      final refreshToken = await service.getRefreshToken();

      expect(accessToken, isNull);
      expect(refreshToken, isNull);
    });
  });
}
