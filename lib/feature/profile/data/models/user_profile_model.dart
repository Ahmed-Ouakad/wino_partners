import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.fullname,
    super.phoneNumber,
    super.role,
    super.vendorProfileId,
    super.vendorType,
    super.isAvailable,
    super.isValidated,
    super.serviceId,
    super.businessTitle,
    super.businessDescription,
    super.categoryId,
    super.addressId,
    super.addressTitle,
    super.addressStreet,
    super.latitude,
    super.longitude,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // If nested in a data wrapper
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final userMap = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : null;

    final servicesList = data['services'] is List ? data['services'] as List : null;
    final firstService = (servicesList != null && servicesList.isNotEmpty && servicesList.first is Map<String, dynamic>)
        ? servicesList.first as Map<String, dynamic>
        : null;

    final addressesList = data['addresses'] is List ? data['addresses'] as List : null;
    final firstAddress = (addressesList != null && addressesList.isNotEmpty && addressesList.first is Map<String, dynamic>)
        ? addressesList.first as Map<String, dynamic>
        : null;

    final vendorProfile = data['vendor_profile'] is Map<String, dynamic>
        ? data['vendor_profile'] as Map<String, dynamic>
        : (data['vendorProfile'] is Map<String, dynamic>
            ? data['vendorProfile'] as Map<String, dynamic>
            : null);

    final userId = userMap != null
        ? (userMap['id'] ?? userMap['_id'] ?? '').toString()
        : (data['user_id'] ?? data['id'] ?? data['_id'] ?? '').toString();

    final userEmail = userMap != null
        ? (userMap['email'] ?? '').toString()
        : (data['email'] ?? '').toString();

    final userFullname = userMap != null
        ? (userMap['fullname'] ?? userMap['fullName'] ?? userMap['name'] ?? '').toString()
        : (data['fullname'] ?? data['fullName'] ?? data['name'] ?? '').toString();

    final userPhone = userMap != null
        ? (userMap['phone_number'] ?? userMap['phoneNumber'])?.toString()
        : (data['phone_number'] ?? data['phoneNumber'])?.toString();

    final vendorId = data.containsKey('vendor_type')
        ? (data['id'] ?? data['_id'])?.toString()
        : (vendorProfile != null
            ? (vendorProfile['id'] ?? vendorProfile['_id'])?.toString()
            : data['vendor_profile_id']?.toString());

    final vendorType = data['vendor_type']?.toString() ??
        (vendorProfile != null
            ? (vendorProfile['vendor_type'] ?? vendorProfile['vendorType'])?.toString()
            : null);

    final isAvailable = (data['is_available'] ??
            (vendorProfile != null ? vendorProfile['is_available'] : null) ??
            true) as bool;

    final isValidated = (data['is_validated'] ??
            (vendorProfile != null ? vendorProfile['is_validated'] : null) ??
            false) as bool;

    return UserProfileModel(
      id: userId,
      email: userEmail,
      fullname: userFullname,
      phoneNumber: userPhone,
      role: data['role']?.toString() ?? userMap?['role']?.toString(),
      vendorProfileId: vendorId,
      vendorType: vendorType,
      isAvailable: isAvailable,
      isValidated: isValidated,
      serviceId: firstService?['id']?.toString() ?? data['service_id']?.toString(),
      businessTitle: firstService?['title']?.toString() ?? data['business_title']?.toString(),
      businessDescription: firstService?['description']?.toString() ?? data['business_description']?.toString(),
      categoryId: firstService?['category_id']?.toString() ?? data['category_id']?.toString(),
      addressId: firstAddress?['id']?.toString() ?? data['address_id']?.toString(),
      addressTitle: firstAddress?['title']?.toString() ?? data['address_title']?.toString(),
      addressStreet: firstAddress?['street']?.toString() ?? data['address_street']?.toString(),
      latitude: (firstAddress?['latitude'] as num?)?.toDouble() ??
          (data['latitude'] as num?)?.toDouble(),
      longitude: (firstAddress?['longitude'] as num?)?.toDouble() ??
          (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': vendorProfileId ?? id,
      'user_id': id,
      'vendor_type': vendorType,
      'is_available': isAvailable,
      'is_validated': isValidated,
      'user': {
        'id': id,
        'email': email,
        'fullname': fullname,
        'phone_number': phoneNumber,
        'role': role,
      },
      if (serviceId != null)
        'services': [
          {
            'id': serviceId,
            'title': businessTitle,
            'description': businessDescription,
            'category_id': categoryId,
          }
        ],
      if (addressId != null)
        'addresses': [
          {
            'id': addressId,
            'title': addressTitle,
            'street': addressStreet,
            'latitude': latitude,
            'longitude': longitude,
          }
        ],
    };
  }
}
