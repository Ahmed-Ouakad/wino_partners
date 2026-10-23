import '../../domain/entities/auth_response.dart';

/// Data model representing the authentication response payload (tokens and has_service flag).
class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.hasService,
    required super.accessToken,
    required super.refreshToken,
  });

  /// Factory constructor to parse JSON data into [AuthResponseModel].
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> source =
        (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : (json['tokens'] is Map<String, dynamic>)
                ? json['tokens'] as Map<String, dynamic>
                : json;

    final accessToken = (source['access_token'] ??
            source['accessToken'] ??
            source['token'] ??
            '')
        .toString();

    final refreshToken = (source['refresh_token'] ??
            source['refreshToken'] ??
            '')
        .toString();

    final rawHasService = source['has_service'] ?? source['hasService'];
    final bool hasService = rawHasService is bool
        ? rawHasService
        : (rawHasService != null &&
            rawHasService.toString().toLowerCase() == 'true');

    return AuthResponseModel(
      hasService: hasService,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Converts this model into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'has_service': hasService,
    };
  }
}
