/// Base event class for login feature.
abstract class LoginEvent {
  const LoginEvent();
}

/// Event dispatched when the vendor login form is submitted.
class LoginVendorSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginVendorSubmitted({
    required this.email,
    required this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginVendorSubmitted &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => email.hashCode ^ password.hashCode;

  @override
  String toString() => 'LoginVendorSubmitted(email: $email)';
}
