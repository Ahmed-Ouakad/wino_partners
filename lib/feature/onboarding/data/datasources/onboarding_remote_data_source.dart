// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/caching_service.dart';
import '../../../../core/services/secure_caching_service.dart';
import '../../domain/entities/onboarding_params.dart';
import '../models/service_category_model.dart';

/// Contract for onboarding remote data operations.
abstract class OnboardingRemoteDataSource {
  /// Calls GET on [ApiConstants.baseUrl] + [ApiConstants.serviceCategoriesEndpoint].
  ///
  /// Throws a [ServerException] on API or remote server errors.
  /// Throws a [NetworkException] on connection failures.
  Future<List<ServiceCategoryModel>> getServiceCategories();

  /// Submits the vendor onboarding details (category and description).
  ///
  /// Throws a [ServerException] on API or remote server errors.
  /// Throws a [NetworkException] on connection failures.
  Future<void> submitOnboarding(OnboardingParams params);
}

/// Implementation of [OnboardingRemoteDataSource] using [http.Client].
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final http.Client client;
  final SecureCachingService? secureCachingService;
  final CachingService? cachingService;
  final String baseUrl;

  OnboardingRemoteDataSourceImpl({
    required this.client,
    this.secureCachingService,
    this.cachingService,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Future<List<ServiceCategoryModel>> getServiceCategories() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.serviceCategoriesEndpoint}');

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

    print('================================================================');
    print('[API REQUEST - GET SERVICE CATEGORIES]');
    print('URL     : $uri');
    print('METHOD  : GET');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.get(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - GET SERVICE CATEGORIES]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> rawList = [];

        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['data'] is List) {
            rawList = decoded['data'] as List;
          } else if (decoded['categories'] is List) {
            rawList = decoded['categories'] as List;
          } else if (decoded['results'] is List) {
            rawList = decoded['results'] as List;
          }
        }

        return rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => ServiceCategoryModel.fromJson(item))
            .toList();
      } else {
        String errorMessage = 'Failed to fetch categories (Status ${response.statusCode})';
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
        message: 'An unexpected error occurred while fetching categories: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> submitOnboarding(OnboardingParams params) async {
    final uri = Uri.parse('$baseUrl/v1/vendor/services');

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

    final requestBody = jsonEncode({
      'title': params.categoryTitle,
      'category_id': params.categoryId,
      'description': params.description,
    });

    print('================================================================');
    print('[API REQUEST - SUBMIT ONBOARDING]');
    print('URL     : $uri');
    print('METHOD  : POST');
    print('HEADERS : $headers');
    print('BODY    : $requestBody');
    print('================================================================');

    try {
      final response = await client.post(
        uri,
        headers: headers,
        body: requestBody,
      );

      print('================================================================');
      print('[API RESPONSE - SUBMIT ONBOARDING]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final dynamic rawId = decoded['id'] ??
                decoded['service_id'] ??
                decoded['serviceId'] ??
                (decoded['data'] is Map ? decoded['data']['id'] : null) ??
                (decoded['service'] is Map ? decoded['service']['id'] : null);
            if (rawId != null && cachingService != null) {
              await cachingService!.saveString(serviceIdKey, rawId.toString());
              await cachingService!.saveString(businessTitleKey, params.categoryTitle);
              await cachingService!.saveString(businessDescriptionKey, params.description);
              await cachingService!.saveString(businessCategoryIdKey, params.categoryId);
              print('[OnboardingRemoteDataSource] Stored service_id ($rawId) and business info in local cache.');
            }
          }
        } catch (e) {
          print('[OnboardingRemoteDataSource] Error parsing service_id from response: $e');
        }
        return;
      } else {
        String errorMessage = 'Server error occurred with status ${response.statusCode}';
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
        message: 'An unexpected error occurred during onboarding submission: ${e.toString()}',
      );
    }
  }
}
