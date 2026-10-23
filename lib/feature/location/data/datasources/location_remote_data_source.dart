// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/secure_caching_service.dart';

/// Contract for location remote data operations.
abstract class LocationRemoteDataSource {
  /// Sends vendor address to the backend via POST [ApiConstants.vendorAddressesEndpoint].
  Future<String?> saveVendorAddress({
    required String title,
    required String street,
    required double latitude,
    required double longitude,
  });

  /// Updates existing vendor address via PATCH [ApiConstants.vendorAddressDetailEndpoint].
  Future<void> updateVendorAddress({
    required String addressId,
    required String title,
    required String street,
    required double latitude,
    required double longitude,
  });

  /// Reverse geocodes latitude and longitude into a readable street address using OpenStreetMap Nominatim.
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}

/// Implementation of [LocationRemoteDataSource] using [http.Client].
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final http.Client client;
  final SecureCachingService? secureCachingService;
  final String baseUrl;

  LocationRemoteDataSourceImpl({
    required this.client,
    this.secureCachingService,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Future<String?> saveVendorAddress({
    required String title,
    required String street,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorAddressesEndpoint}');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (secureCachingService != null) {
      final token = await secureCachingService!.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final body = jsonEncode({
      'title': title,
      'street': street,
      'latitude': latitude,
      'longitude': longitude,
    });

    print('================================================================');
    print('[API REQUEST - SAVE VENDOR ADDRESS]');
    print('URL     : $uri');
    print('METHOD  : POST');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.post(
        uri,
        headers: headers,
        body: body,
      );

      print('================================================================');
      print('[API RESPONSE - SAVE VENDOR ADDRESS]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return (decoded['id'] ?? decoded['address_id'] ?? decoded['addressId'])?.toString();
          }
        } catch (_) {}
        return null;
      } else {
        String errorMessage = 'Failed to save address (Status ${response.statusCode})';
        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('message') && decoded['message'] != null) {
              errorMessage = decoded['message'].toString();
            } else if (decoded.containsKey('error') && decoded['error'] != null) {
              errorMessage = decoded['error'].toString();
            }
          }
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        throw ServerException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('[EXCEPTION: SocketException]: ${e.message}');
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      print('[EXCEPTION: ClientException]: ${e.message}');
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      print('[EXCEPTION: Unexpected]: $e');
      throw ServerException(
        message: 'An unexpected error occurred while saving address: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateVendorAddress({
    required String addressId,
    required String title,
    required String street,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$baseUrl${ApiConstants.vendorAddressDetailEndpoint(addressId)}',
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (secureCachingService != null) {
      final token = await secureCachingService!.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final body = jsonEncode({
      'title': title,
      'street': street,
      'latitude': latitude,
      'longitude': longitude,
    });

    print('================================================================');
    print('[API REQUEST - UPDATE VENDOR ADDRESS]');
    print('URL     : $uri');
    print('METHOD  : PATCH');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.patch(
        uri,
        headers: headers,
        body: body,
      );

      print('================================================================');
      print('[API RESPONSE - UPDATE VENDOR ADDRESS]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        String errorMessage =
            'Failed to update address (Status ${response.statusCode})';
        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('message') && decoded['message'] != null) {
              errorMessage = decoded['message'].toString();
            } else if (decoded.containsKey('error') &&
                decoded['error'] != null) {
              errorMessage = decoded['error'].toString();
            }
          }
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        throw ServerException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      print('[EXCEPTION: SocketException]: ${e.message}');
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      print('[EXCEPTION: ClientException]: ${e.message}');
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      print('[EXCEPTION: Unexpected]: $e');
      throw ServerException(
        message: 'An unexpected error occurred while updating address: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1',
      );

      final response = await client.get(uri, headers: {
        'User-Agent': 'com.yourcompany.wino',
      });

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('display_name') &&
              decoded['display_name'] != null &&
              decoded['display_name'].toString().isNotEmpty) {
            return decoded['display_name'].toString();
          }
        }
      }
    } catch (e) {
      print('[LocationRemoteDataSource] Reverse geocoding failed: $e');
    }

    // Default fallback if reverse geocoding fails or returns empty
    return '123 Avenue Habib Bourguiba, Tunis';
  }
}
