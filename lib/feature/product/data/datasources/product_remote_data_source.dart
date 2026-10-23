// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/secure_caching_service.dart';
import '../../domain/entities/create_product_params.dart';
import '../../domain/entities/update_product_params.dart';
import '../models/service_sub_categories_model.dart';
import '../models/sub_category_model.dart';
import '../models/sub_category_products_model.dart';
import '../models/upload_url_model.dart';

abstract class ProductRemoteDataSource {
  Future<ServiceSubCategoriesModel> getSubCategories(String serviceId);
  Future<SubCategoryModel> createSubCategory({
    required String categoryId,
    required String title,
  });
  Future<UploadUrlModel> getUploadUrl({
    required String filename,
    required String folder,
  });
  Future<void> uploadFile({
    required String uploadUrl,
    required String? token,
    required File file,
  });
  Future<void> createProduct(CreateProductParams params);
  Future<List<SubCategoryProductsModel>> getVendorProducts();
  Future<void> updateProduct(UpdateProductParams params);
  Future<void> deleteProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  final http.Client? rawHttpClient;
  final SecureCachingService? secureCachingService;
  final String baseUrl;

  ProductRemoteDataSourceImpl({
    required this.client,
    this.rawHttpClient,
    this.secureCachingService,
    this.baseUrl = ApiConstants.baseUrl,
  });

  Future<Map<String, String>> _getAuthHeaders() async {
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
    return headers;
  }

  @override
  Future<ServiceSubCategoriesModel> getSubCategories(String serviceId) async {
    final uri = Uri.parse(
      '$baseUrl${ApiConstants.serviceSubCategoriesEndpoint(serviceId)}',
    );
    final headers = await _getAuthHeaders();

    print('================================================================');
    print('[API REQUEST - GET SUB-CATEGORIES]');
    print('URL     : $uri');
    print('METHOD  : GET');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.get(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - GET SUB-CATEGORIES]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ServiceSubCategoriesModel.fromJson(decoded);
        } else {
          throw const ServerException(message: 'Invalid response format for sub-categories.');
        }
      } else {
        throw ServerException(
          message: _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error fetching sub-categories: ${e.toString()}');
    }
  }

  @override
  Future<SubCategoryModel> createSubCategory({
    required String categoryId,
    required String title,
  }) async {
    final uri = Uri.parse(
      '$baseUrl${ApiConstants.createSubCategoryEndpoint(categoryId)}',
    );
    final headers = await _getAuthHeaders();
    final body = jsonEncode({'title': title});

    print('================================================================');
    print('[API REQUEST - CREATE SUB-CATEGORY]');
    print('URL     : $uri');
    print('METHOD  : POST');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.post(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - CREATE SUB-CATEGORY]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        final Map<String, dynamic> source = (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : {});

        return SubCategoryModel.fromJson(source);
      } else {
        throw ServerException(
          message: _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error creating sub-category: ${e.toString()}');
    }
  }

  @override
  Future<UploadUrlModel> getUploadUrl({
    required String filename,
    required String folder,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.storageUploadUrlEndpoint}');
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'filename': filename,
      'folder': folder,
    });

    print('================================================================');
    print('[API REQUEST - GET STORAGE UPLOAD URL]');
    print('URL     : $uri');
    print('METHOD  : POST');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.post(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - GET STORAGE UPLOAD URL]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        final Map<String, dynamic> source = (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : {});

        return UploadUrlModel.fromJson(source);
      } else {
        throw ServerException(
          message: _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error obtaining upload URL: ${e.toString()}');
    }
  }

  @override
  Future<void> uploadFile({
    required String uploadUrl,
    required String? token,
    required File file,
  }) async {
    final uri = Uri.parse(uploadUrl);
    final fileBytes = await file.readAsBytes();

    String contentType = 'image/jpeg';
    final lowerPath = file.path.toLowerCase();
    if (lowerPath.endsWith('.png')) {
      contentType = 'image/png';
    } else if (lowerPath.endsWith('.webp')) {
      contentType = 'image/webp';
    }

    final headers = <String, String>{
      'Content-Type': contentType,
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('================================================================');
    print('[API REQUEST - UPLOAD FILE TO STORAGE]');
    print('URL     : $uri');
    print('METHOD  : PUT');
    print('BYTES   : ${fileBytes.length}');
    print('================================================================');

    try {
      final uploadClient = rawHttpClient ?? http.Client();
      final response = await uploadClient.put(
        uri,
        headers: headers,
        body: fileBytes,
      );

      print('================================================================');
      print('[API RESPONSE - UPLOAD FILE TO STORAGE]');
      print('STATUS CODE : ${response.statusCode}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw ServerException(
          message: 'Storage upload failed with HTTP status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Failed to connect to storage: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error during file upload: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Unexpected error uploading file: ${e.toString()}');
    }
  }

  @override
  Future<void> createProduct(CreateProductParams params) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorProductsEndpoint}');
    final headers = await _getAuthHeaders();
    final body = jsonEncode(params.toJson());

    print('================================================================');
    print('[API REQUEST - CREATE VENDOR PRODUCT]');
    print('URL     : $uri');
    print('METHOD  : POST');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.post(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - CREATE VENDOR PRODUCT]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw ServerException(
          message: _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error creating product: ${e.toString()}');
    }
  }

  @override
  Future<List<SubCategoryProductsModel>> getVendorProducts() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorProductsEndpoint}');
    final headers = await _getAuthHeaders();

    print('================================================================');
    print('[API REQUEST - GET VENDOR PRODUCTS]');
    print('URL     : $uri');
    print('METHOD  : GET');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.get(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - GET VENDOR PRODUCTS]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => SubCategoryProductsModel.fromJson(item))
              // Skip categories with no products as requested by user
              .where((group) => group.products.isNotEmpty)
              .toList();
        }
        return [];
      } else {
        throw ServerException(
          message: _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Error fetching vendor products: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateProduct(UpdateProductParams params) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorProductDetailEndpoint(params.productId)}');
    final headers = await _getAuthHeaders();
    final body = jsonEncode(params.toJson());

    print('================================================================');
    print('[API REQUEST - UPDATE VENDOR PRODUCT]');
    print('URL     : $uri');
    print('METHOD  : PATCH');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.patch(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - UPDATE VENDOR PRODUCT]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw ServerException(
          message: _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Error updating product: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorProductDetailEndpoint(productId)}');
    final headers = await _getAuthHeaders();

    print('================================================================');
    print('[API REQUEST - DELETE VENDOR PRODUCT]');
    print('URL     : $uri');
    print('METHOD  : DELETE');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.delete(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - DELETE VENDOR PRODUCT]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw ServerException(
          message: _extractErrorMessage(response.body, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Error deleting product: ${e.toString()}',
      );
    }
  }

  String _extractErrorMessage(String responseBody, int statusCode) {
    try {
      final dynamic decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('message') && decoded['message'] != null) {
          final msg = decoded['message'];
          if (msg is List) return msg.join(', ');
          return msg.toString();
        } else if (decoded.containsKey('error') && decoded['error'] != null) {
          return decoded['error'].toString();
        }
      }
    } catch (_) {}
    return 'Server error (Status $statusCode)';
  }
}
