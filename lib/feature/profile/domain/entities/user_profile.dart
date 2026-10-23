import 'package:equatable/equatable.dart';

/// Entity representing the vendor user profile.
class UserProfile extends Equatable {
  final String id;
  final String email;
  final String fullname;
  final String? phoneNumber;
  final String? role;
  final String? vendorProfileId;
  final String? vendorType;
  final bool isAvailable;
  final bool isValidated;

  // Service details (from the first element of services)
  final String? serviceId;
  final String? businessTitle;
  final String? businessDescription;
  final String? categoryId;

  // Address details (from the first element of addresses)
  final String? addressId;
  final String? addressTitle;
  final String? addressStreet;
  final double? latitude;
  final double? longitude;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullname,
    this.phoneNumber,
    this.role,
    this.vendorProfileId,
    this.vendorType,
    this.isAvailable = true,
    this.isValidated = false,
    this.serviceId,
    this.businessTitle,
    this.businessDescription,
    this.categoryId,
    this.addressId,
    this.addressTitle,
    this.addressStreet,
    this.latitude,
    this.longitude,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullname,
    String? phoneNumber,
    String? role,
    String? vendorProfileId,
    String? vendorType,
    bool? isAvailable,
    bool? isValidated,
    String? serviceId,
    String? businessTitle,
    String? businessDescription,
    String? categoryId,
    String? addressId,
    String? addressTitle,
    String? addressStreet,
    double? latitude,
    double? longitude,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      vendorProfileId: vendorProfileId ?? this.vendorProfileId,
      vendorType: vendorType ?? this.vendorType,
      isAvailable: isAvailable ?? this.isAvailable,
      isValidated: isValidated ?? this.isValidated,
      serviceId: serviceId ?? this.serviceId,
      businessTitle: businessTitle ?? this.businessTitle,
      businessDescription: businessDescription ?? this.businessDescription,
      categoryId: categoryId ?? this.categoryId,
      addressId: addressId ?? this.addressId,
      addressTitle: addressTitle ?? this.addressTitle,
      addressStreet: addressStreet ?? this.addressStreet,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullname,
        phoneNumber,
        role,
        vendorProfileId,
        vendorType,
        isAvailable,
        isValidated,
        serviceId,
        businessTitle,
        businessDescription,
        categoryId,
        addressId,
        addressTitle,
        addressStreet,
        latitude,
        longitude,
      ];
}
