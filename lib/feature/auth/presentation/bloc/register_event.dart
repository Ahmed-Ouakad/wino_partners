/// Base event class for registration feature.
abstract class RegisterEvent {
  const RegisterEvent();
}

/// Event dispatched when the vendor registration form is submitted.
class RegisterVendorSubmitted extends RegisterEvent {
  final String email;
  final String password;
  final String fullname;
  final String phoneNumber;
  final String vendorType;

  const RegisterVendorSubmitted({
    required this.email,
    required this.password,
    required this.fullname,
    required this.phoneNumber,
    required this.vendorType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterVendorSubmitted &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password &&
          fullname == other.fullname &&
          phoneNumber == other.phoneNumber &&
          vendorType == other.vendorType;

  @override
  int get hashCode =>
      email.hashCode ^
      password.hashCode ^
      fullname.hashCode ^
      phoneNumber.hashCode ^
      vendorType.hashCode;
}
