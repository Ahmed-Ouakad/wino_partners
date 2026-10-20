/// Custom exceptions thrown by data sources in the data layer.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection. Please check your network.']);

  @override
  String toString() => 'NetworkException: $message';
}
