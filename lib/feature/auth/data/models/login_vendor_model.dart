import '../../domain/entities/login_vendor_params.dart';

/// Data model representing the vendor login request payload,
/// extending [LoginVendorParams] for clean architecture mapping.
class LoginVendorModel extends LoginVendorParams {
  const LoginVendorModel({
    required super.email,
    required super.password,
  });

  /// Factory constructor to instantiate [LoginVendorModel] from domain params.
  factory LoginVendorModel.fromParams(LoginVendorParams params) {
    return LoginVendorModel(
      email: params.email,
      password: params.password,
    );
  }

  /// Factory constructor to parse JSON data into [LoginVendorModel].
  factory LoginVendorModel.fromJson(Map<String, dynamic> json) {
    return LoginVendorModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  /// Converts this model into a JSON map matching the backend API keys:
  /// `email`, `password`.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
