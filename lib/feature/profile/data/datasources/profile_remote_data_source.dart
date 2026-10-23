// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/secure_caching_service.dart';
import '../models/profile_picture_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();

  Future<UserProfileModel> updateUserProfile({
    required String fullname,
    required String phoneNumber,
  });

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> updateBusinessService({
    required String serviceId,
    required String title,
    required String description,
    required String categoryId,
  });

  Future<List<ProfilePictureModel>> getProfilePictures();

  Future<ProfilePictureModel> addProfilePicture(String mediaUrl);

  Future<void> activateProfilePicture(String id);

  Future<void> deleteProfilePicture(String id);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final SecureCachingService secureCachingService;
  final String baseUrl;

  ProfileRemoteDataSourceImpl({
    required this.client,
    required this.secureCachingService,
    this.baseUrl = ApiConstants.baseUrl,
  });

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await secureCachingService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorProfileEndpoint}');
    final headers = await _buildHeaders();

    print('================================================================');
    print('[API REQUEST - GET VENDOR PROFILE]');
    print('URL     : $uri');
    print('METHOD  : GET');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.get(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - GET USER PROFILE]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return UserProfileModel.fromJson(decoded);
        }
        throw const ServerException(message: 'Invalid profile response format');
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error fetching user profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile({
    required String fullname,
    required String phoneNumber,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.usersMeEndpoint}');
    final headers = await _buildHeaders();
    final body = jsonEncode({
      'fullname': fullname,
      'phone_number': phoneNumber,
    });

    print('================================================================');
    print('[API REQUEST - PATCH USER PROFILE]');
    print('URL     : $uri');
    print('METHOD  : PATCH');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.patch(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - PATCH USER PROFILE]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return UserProfileModel.fromJson(decoded);
        }
        return UserProfileModel(
          id: '',
          email: '',
          fullname: fullname,
          phoneNumber: phoneNumber,
        );
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error updating profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.updatePasswordEndpoint}');
    final headers = await _buildHeaders();
    final body = jsonEncode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    print('================================================================');
    print('[API REQUEST - PATCH PASSWORD]');
    print('URL     : $uri');
    print('METHOD  : PATCH');
    print('HEADERS : $headers');
    print('BODY    : {"currentPassword": "***", "newPassword": "***"}');
    print('================================================================');

    try {
      final response = await client.patch(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - PATCH PASSWORD]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error updating password: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateBusinessService({
    required String serviceId,
    required String title,
    required String description,
    required String categoryId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl${ApiConstants.vendorServiceDetailEndpoint(serviceId)}',
    );
    final headers = await _buildHeaders();
    final body = jsonEncode({
      'title': title,
      'description': description,
      'category_id': categoryId,
    });

    print('================================================================');
    print('[API REQUEST - PATCH VENDOR SERVICE]');
    print('URL     : $uri');
    print('METHOD  : PATCH');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.patch(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - PATCH VENDOR SERVICE]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error updating business details: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ProfilePictureModel>> getProfilePictures() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.userProfilePicturesEndpoint}');
    final headers = await _buildHeaders();

    print('================================================================');
    print('[API REQUEST - GET PROFILE PICTURES]');
    print('URL     : $uri');
    print('METHOD  : GET');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.get(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - GET PROFILE PICTURES]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => ProfilePictureModel.fromJson(item))
              .toList();
        } else if (decoded is Map<String, dynamic> &&
            decoded.containsKey('data') &&
            decoded['data'] is List) {
          return (decoded['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => ProfilePictureModel.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error fetching profile pictures: ${e.toString()}',
      );
    }
  }

  @override
  Future<ProfilePictureModel> addProfilePicture(String mediaUrl) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.userProfilePicturesEndpoint}');
    final headers = await _buildHeaders();
    final body = jsonEncode({
      'mediaUrl': mediaUrl,
    });

    print('================================================================');
    print('[API REQUEST - ADD PROFILE PICTURE]');
    print('URL     : $uri');
    print('METHOD  : POST');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.post(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - ADD PROFILE PICTURE]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
            return ProfilePictureModel.fromJson(decoded['data'] as Map<String, dynamic>);
          }
          return ProfilePictureModel.fromJson(decoded);
        }
        return ProfilePictureModel(id: '', mediaUrl: mediaUrl);
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error adding profile picture: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> activateProfilePicture(String id) async {
    final uri = Uri.parse(
      '$baseUrl${ApiConstants.activateProfilePictureEndpoint(id)}',
    );
    final headers = await _buildHeaders();

    print('================================================================');
    print('[API REQUEST - ACTIVATE PROFILE PICTURE]');
    print('URL     : $uri');
    print('METHOD  : PATCH');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.patch(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - ACTIVATE PROFILE PICTURE]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error activating profile picture: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteProfilePicture(String id) async {
    final uri = Uri.parse(
      '$baseUrl${ApiConstants.deleteProfilePictureEndpoint(id)}',
    );
    final headers = await _buildHeaders();

    print('================================================================');
    print('[API REQUEST - DELETE PROFILE PICTURE]');
    print('URL     : $uri');
    print('METHOD  : DELETE');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.delete(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - DELETE PROFILE PICTURE]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw _parseError(response);
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error deleting profile picture: ${e.toString()}',
      );
    }
  }

  ServerException _parseError(http.Response response) {
    String errorMessage = 'Request failed with status ${response.statusCode}';
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('message') && decoded['message'] != null) {
          if (decoded['message'] is List) {
            errorMessage = (decoded['message'] as List).join(', ');
          } else {
            errorMessage = decoded['message'].toString();
          }
        } else if (decoded.containsKey('error') && decoded['error'] != null) {
          errorMessage = decoded['error'].toString();
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        errorMessage = response.body;
      }
    }
    return ServerException(
      message: errorMessage,
      statusCode: response.statusCode,
    );
  }
}
