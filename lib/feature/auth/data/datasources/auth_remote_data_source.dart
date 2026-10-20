// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/login_vendor_model.dart';
import '../models/register_vendor_model.dart';

/// Contract for authentication remote data operations.
abstract class AuthRemoteDataSource {
  /// Calls the POST /auth/register/vendor API endpoint with [model].
  ///
  /// Throws a [ServerException] on API or remote server errors.
  /// Throws a [NetworkException] on connection failures.
  Future<void> registerVendor(RegisterVendorModel model);

  /// Calls the POST /auth/login/vendor API endpoint with [model].
  ///
  /// Returns a map containing `'access_token'` and `'refresh_token'`.
  /// Throws a [ServerException] on API or remote server errors.
  /// Throws a [NetworkException] on connection failures.
  Future<Map<String, String>> loginVendor(LoginVendorModel model);
}

/// Implementation of [AuthRemoteDataSource] using the `http` client.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Future<void> registerVendor(RegisterVendorModel model) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.registerVendorEndpoint}');
    final requestBody = jsonEncode(model.toJson());

    developer.log('API Request POST: $uri, Body: $requestBody', name: 'AuthRemoteDataSource');

    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      developer.log(
        'API Response Status: ${response.statusCode}, Body: ${response.body}',
        name: 'AuthRemoteDataSource',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
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
      developer.log('SocketException: ${e.message}', name: 'AuthRemoteDataSource');
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      developer.log('ClientException: ${e.message}', name: 'AuthRemoteDataSource');
      throw NetworkException('Network error: ${e.message}');
    } on ServerException catch (e) {
      developer.log('ServerException: ${e.message} (status: ${e.statusCode})', name: 'AuthRemoteDataSource');
      rethrow;
    } on NetworkException catch (e) {
      developer.log('NetworkException: ${e.message}', name: 'AuthRemoteDataSource');
      rethrow;
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'AuthRemoteDataSource');
      throw ServerException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, String>> loginVendor(LoginVendorModel model) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.loginVendorEndpoint}');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final requestBody = jsonEncode(model.toJson());

    // -------------------------------------------------------------------------
    // 1. API REQUEST PRINT BLOCK
    // -------------------------------------------------------------------------
    print('================================================================');
    print('[API REQUEST]');
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

      // -----------------------------------------------------------------------
      // 2. API RESPONSE PRINT BLOCK
      // -----------------------------------------------------------------------
      print('================================================================');
      print('[API RESPONSE]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String accessToken = '';
        String refreshToken = '';

        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final Map<String, dynamic> source =
                (decoded['data'] is Map<String, dynamic>)
                    ? decoded['data'] as Map<String, dynamic>
                    : (decoded['tokens'] is Map<String, dynamic>)
                        ? decoded['tokens'] as Map<String, dynamic>
                        : decoded;

            accessToken = (source['access_token'] ??
                    source['accessToken'] ??
                    source['token'] ??
                    '')
                .toString();

            refreshToken = (source['refresh_token'] ??
                    source['refreshToken'] ??
                    '')
                .toString();
          }
        } catch (_) {}

        return {
          'access_token': accessToken,
          'refresh_token': refreshToken,
        };
      } else {
        // Parse error message from body if available
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

        // ---------------------------------------------------------------------
        // 3. PARSED ERROR PRINT BLOCK (Non-2xx Status Code)
        // ---------------------------------------------------------------------
        print('================================================================');
        print('[PARSED ERROR MESSAGE]');
        print('STATUS CODE   : ${response.statusCode}');
        print('PARSED MESSAGE: $errorMessage');
        print('================================================================');

        throw ServerException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      // -----------------------------------------------------------------------
      // 4a. EXCEPTION BLOCK: SocketException
      // -----------------------------------------------------------------------
      print('================================================================');
      print('[EXCEPTION: SocketException]');
      print('Message : ${e.message}');
      print('OS Error: ${e.osError}');
      print('Address : ${e.address?.host}');
      print('Port    : ${e.port}');
      print('================================================================');
      throw NetworkException('Unable to connect to the server: ${e.message}');
    } on http.ClientException catch (e) {
      // -----------------------------------------------------------------------
      // 4b. EXCEPTION BLOCK: http.ClientException
      // -----------------------------------------------------------------------
      print('================================================================');
      print('[EXCEPTION: http.ClientException]');
      print('Message : ${e.message}');
      print('URI     : ${e.uri}');
      print('================================================================');
      throw NetworkException('Network client error: ${e.message}');
    } on ServerException catch (e) {
      // -----------------------------------------------------------------------
      // 4c. EXCEPTION BLOCK: ServerException
      // -----------------------------------------------------------------------
      print('================================================================');
      print('[EXCEPTION: ServerException]');
      print('Message    : ${e.message}');
      print('Status Code: ${e.statusCode}');
      print('================================================================');
      rethrow;
    } catch (e, stackTrace) {
      // -----------------------------------------------------------------------
      // 4d. EXCEPTION BLOCK: Unexpected Errors
      // -----------------------------------------------------------------------
      print('================================================================');
      print('[EXCEPTION: Unexpected Error]');
      print('Error     : $e');
      print('StackTrace: $stackTrace');
      print('================================================================');
      throw ServerException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}