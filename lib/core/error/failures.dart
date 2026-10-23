/// Base Failure class for domain and presentation layers.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => '$runtimeType: $message';
}

/// Represents failure responses returned by remote server APIs.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});
}

/// Represents connection/socket failures when contacting the remote server.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please try again.']);
}

/// Represents location services disabled failure.
class LocationServiceDisabled extends Failure {
  const LocationServiceDisabled([super.message = 'Location services are disabled. Please enable them in settings.']);
}

/// Represents location permission failure.
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Location permission denied.']);
}

/// Represents failure when no location is found for a city query.
class NoLocationFailure extends Failure {
  const NoLocationFailure([super.message = 'Could not find that city. Please try another name.']);
}

/// Represents local storage or caching failure.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to save location data locally.']);
}
