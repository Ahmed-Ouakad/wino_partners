// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/secure_caching_service.dart';
import '../../../product/data/models/upload_url_model.dart';
import '../../domain/entities/create_post_params.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<UploadUrlModel> getUploadUrl({
    required String filename,
    required String folder,
  });

  Future<void> uploadFile({
    required String uploadUrl,
    required String? token,
    required File file,
  });

  Future<void> createPost(CreatePostParams params);

  Future<List<PostModel>> getVendorPosts();

  Future<void> deletePost(String id);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final http.Client client;
  final http.Client? rawHttpClient;
  final SecureCachingService? secureCachingService;
  final String baseUrl;

  PostRemoteDataSourceImpl({
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
    print('[API REQUEST - POST STORAGE UPLOAD URL]');
    print('URL     : $uri');
    print('METHOD  : POST');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.post(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - POST STORAGE UPLOAD URL]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return UploadUrlModel.fromJson(decoded);
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
        message: 'Error generating storage upload url: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> uploadFile({
    required String uploadUrl,
    required String? token,
    required File file,
  }) async {
    final uri = Uri.parse(uploadUrl);
    final headers = <String, String>{
      'Content-Type': 'application/octet-stream',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('================================================================');
    print('[STORAGE UPLOAD REQUEST - PUT MEDIA]');
    print('URL     : $uri');
    print('METHOD  : PUT');
    print('FILE SIZE: ${await file.length()} bytes');
    print('================================================================');

    try {
      final uploadClient = rawHttpClient ?? http.Client();
      final bytes = await file.readAsBytes();
      final response = await uploadClient.put(uri, headers: headers, body: bytes);

      print('================================================================');
      print('[STORAGE UPLOAD RESPONSE - PUT MEDIA]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw ServerException(
          message: 'Failed to upload media to storage: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('Unable to connect to storage service: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Storage upload network error: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Error uploading media file: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> createPost(CreatePostParams params) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorPostsEndpoint}');
    final headers = await _getAuthHeaders();
    final body = jsonEncode(params.toJson());

    print('================================================================');
    print('[API REQUEST - CREATE VENDOR POST]');
    print('URL     : $uri');
    print('METHOD  : POST');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.post(uri, headers: headers, body: body);

      print('================================================================');
      print('[API RESPONSE - CREATE VENDOR POST]');
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
        message: 'Error creating post: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PostModel>> getVendorPosts() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorPostsEndpoint}');
    final headers = await _getAuthHeaders();

    print('================================================================');
    print('[API REQUEST - GET VENDOR POSTS]');
    print('URL     : $uri');
    print('METHOD  : GET');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.get(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - GET VENDOR POSTS]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
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
        message: 'Error fetching vendor posts: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePost(String id) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.vendorPostDetailEndpoint(id)}');
    final headers = await _getAuthHeaders();

    print('================================================================');
    print('[API REQUEST - DELETE VENDOR POST]');
    print('URL     : $uri');
    print('METHOD  : DELETE');
    print('HEADERS : $headers');
    print('================================================================');

    try {
      final response = await client.delete(uri, headers: headers);

      print('================================================================');
      print('[API RESPONSE - DELETE VENDOR POST]');
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
        message: 'Error deleting post: ${e.toString()}',
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
