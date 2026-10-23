/// Domain entity representing the result of an authentication operation (login or signup).
class AuthResponse {
  final bool hasService;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.hasService,
    this.accessToken = '',
    this.refreshToken = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResponse &&
          runtimeType == other.runtimeType &&
          hasService == other.hasService &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode =>
      hasService.hashCode ^ accessToken.hashCode ^ refreshToken.hashCode;

  @override
  String toString() =>
      'AuthResponse(hasService: $hasService, accessToken: ${accessToken.isNotEmpty}, refreshToken: ${refreshToken.isNotEmpty})';
}
