/// Parameters and domain entity representing vendor login credentials.
class LoginVendorParams {
  final String email;
  final String password;

  const LoginVendorParams({
    required this.email,
    required this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginVendorParams &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => email.hashCode ^ password.hashCode;

  @override
  String toString() {
    return 'LoginVendorParams(email: $email)';
  }
}
