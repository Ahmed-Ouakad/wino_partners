/// Base state class for registration feature.
abstract class RegisterState {
  const RegisterState();
}

/// Initial state before any registration action has been triggered.
class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

/// State emitted while the registration request is ongoing.
class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

/// State emitted when registration completes successfully.
class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

/// State emitted when registration fails, carrying an error [message].
class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
