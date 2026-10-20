import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for secure local caching of sensitive authentication tokens.
abstract class SecureCachingService {
  /// Persists both [accessToken] and [refreshToken] in secure storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Retrieves the cached access token, or `null` if not present.
  Future<String?> getAccessToken();

  /// Retrieves the cached refresh token, or `null` if not present.
  Future<String?> getRefreshToken();

  /// Clears all keys and authentication tokens stored securely.
  Future<void> clearAll();
}

/// Implementation of [SecureCachingService] using [FlutterSecureStorage].
class SecureCachingServiceImpl implements SecureCachingService {
  final FlutterSecureStorage secureStorage;

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  const SecureCachingServiceImpl({
    required this.secureStorage,
  });

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: accessTokenKey, value: accessToken);
    await secureStorage.write(key: refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: refreshTokenKey);
  }

  @override
  Future<void> clearAll() async {
    await secureStorage.deleteAll();
  }
}
