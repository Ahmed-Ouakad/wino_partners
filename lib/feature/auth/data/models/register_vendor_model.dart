import '../../domain/entities/register_vendor_params.dart';

/// Data model representing the vendor registration request payload,
/// extending [RegisterVendorParams] for clean architecture mapping.
class RegisterVendorModel extends RegisterVendorParams {
  const RegisterVendorModel({
    required super.email,
    required super.password,
    required super.fullname,
    required super.phoneNumber,
    required super.vendorType,
  });

  /// Factory constructor to instantiate [RegisterVendorModel] from domain params.
  factory RegisterVendorModel.fromParams(RegisterVendorParams params) {
    return RegisterVendorModel(
      email: params.email,
      password: params.password,
      fullname: params.fullname,
      phoneNumber: params.phoneNumber,
      vendorType: params.vendorType,
    );
  }

  /// Factory constructor to parse JSON data into [RegisterVendorModel].
  factory RegisterVendorModel.fromJson(Map<String, dynamic> json) {
    return RegisterVendorModel(
      email: json['email'] as String,
      password: json['password'] as String,
      fullname: json['fullname'] as String,
      phoneNumber: json['phone_number'] as String,
      vendorType: json['vendor_type'] as String,
    );
  }

  /// Converts this model into a JSON map matching the backend API keys:
  /// `email`, `password`, `fullname`, `phone_number`, `vendor_type`.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullname': fullname,
      'phone_number': phoneNumber,
      'vendor_type': vendorType,
    };
  }
}
