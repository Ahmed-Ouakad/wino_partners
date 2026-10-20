/// Parameters and domain entity representing vendor registration data.
class RegisterVendorParams {
  final String email;
  final String password;
  final String fullname;
  final String phoneNumber;
  final String vendorType;

  const RegisterVendorParams({
    required this.email,
    required this.password,
    required this.fullname,
    required this.phoneNumber,
    required this.vendorType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterVendorParams &&
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

  @override
  String toString() {
    return 'RegisterVendorParams(email: $email, fullname: $fullname, phoneNumber: $phoneNumber, vendorType: $vendorType)';
  }
}
