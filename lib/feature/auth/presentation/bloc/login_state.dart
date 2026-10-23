/// Base state class for login feature.
abstract class LoginState {
  const LoginState();
}

/// Initial state before any login action has been triggered.
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// State emitted while the login request is ongoing.
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// State emitted when login completes successfully.
class LoginSuccess extends LoginState {
  final bool hasService;

  const LoginSuccess({this.hasService = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginSuccess &&
          runtimeType == other.runtimeType &&
          hasService == other.hasService;

  @override
  int get hashCode => hasService.hashCode;
}

/// State emitted when login fails, carrying an error [message].
class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'LoginFailure(message: $message)';
}
