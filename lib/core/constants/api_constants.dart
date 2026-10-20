/// Centralized API endpoint constants.
class ApiConstants {
  /// Base URL for the backend API services.
  /// Configure this with your actual server host (e.g., http://10.0.2.2:8000 for Android emulator).
  static const String baseUrl = 'http://10.0.2.2:3000';

  /// Endpoint for vendor registration
  static const String registerVendorEndpoint = '/auth/register/vendor';

  /// Endpoint for vendor login
  static const String loginVendorEndpoint = '/auth/login/vendor';
}
