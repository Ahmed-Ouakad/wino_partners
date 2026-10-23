// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../services/secure_caching_service.dart';

/// Custom [http.BaseClient] that automatically injects JWT access tokens,
/// intercepts 401 Unauthorized responses, triggers token refresh using
/// the stored refresh token, and safely retries the cloned request.
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client innerClient;
  final SecureCachingService secureCachingService;
  final String baseUrl;

  /// Holds an active refresh operation to coalesce concurrent 401 requests.
  Future<String>? _refreshFuture;

  AuthenticatedHttpClient({
    required this.innerClient,
    required this.secureCachingService,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('[AuthenticatedHttpClient] Intercepting request: ${request.method} ${request.url}');

    // 1. Initial Request: Attach Bearer access_token if present and not already attached
    final isRefreshEndpoint = request.url.path.endsWith(ApiConstants.refreshTokenEndpoint);
    if (!isRefreshEndpoint && !request.headers.containsKey('Authorization')) {
      final accessToken = await secureCachingService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $accessToken';
        print('[AuthenticatedHttpClient] Attached Bearer access token to request: ${request.url.path}');
      }
    }

    // 2. Clone request before sending, because http.BaseRequest stream cannot be read twice
    final clonedRequest = await _cloneRequest(request);

    // 3. Send the request
    final response = await innerClient.send(request);

    // 4. 401 Handling: Trigger token refresh and retry if unauthorized (and not already the refresh endpoint)
    if (response.statusCode == 401 && !isRefreshEndpoint) {
      print('[AuthenticatedHttpClient] 401 Unauthorized encountered on ${request.url.path}. Triggering token refresh...');

      try {
        final newAccessToken = await _refreshToken();

        print('[AuthenticatedHttpClient] Retrying original request with new token: ${clonedRequest.url.path}');
        clonedRequest.headers['Authorization'] = 'Bearer $newAccessToken';

        return await innerClient.send(clonedRequest);
      } on SessionExpiredException {
        rethrow;
      } catch (e) {
        print('[AuthenticatedHttpClient] Refresh failed with error: $e');
        await secureCachingService.clearAll();
        throw SessionExpiredException('Session expired: ${e.toString()}');
      }
    }

    return response;
  }

  /// Refreshes the access token using the stored refresh token.
  /// Deduplicates simultaneous refresh calls via [_refreshFuture].
  Future<String> _refreshToken() {
    if (_refreshFuture != null) {
      print('[AuthenticatedHttpClient] Token refresh already in progress. Awaiting existing refresh...');
      return _refreshFuture!;
    }

    _refreshFuture = _performTokenRefresh().whenComplete(() {
      _refreshFuture = null;
    });

    return _refreshFuture!;
  }

  /// Private worker for token refresh logic.
  Future<String> _performTokenRefresh() async {
    print('[AuthenticatedHttpClient] Fetching refresh token from SecureCachingService...');
    final refreshToken = await secureCachingService.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      print('[AuthenticatedHttpClient] No refresh token found in storage. Session expired.');
      await secureCachingService.clearAll();
      throw const SessionExpiredException('No refresh token available. Session expired.');
    }

    final refreshUri = Uri.parse('$baseUrl${ApiConstants.refreshTokenEndpoint}');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $refreshToken',
    };
    final body = jsonEncode({
      'refresh_token': refreshToken,
      'refreshToken': refreshToken,
    });

    print('[AuthenticatedHttpClient] Sending POST refresh request to $refreshUri');

    try {
      final response = await innerClient.post(
        refreshUri,
        headers: headers,
        body: body,
      );

      print('[AuthenticatedHttpClient] Refresh endpoint responded with status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String newAccessToken = '';
        String newRefreshToken = '';

        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final Map<String, dynamic> source =
                (decoded['data'] is Map<String, dynamic>)
                    ? decoded['data'] as Map<String, dynamic>
                    : (decoded['tokens'] is Map<String, dynamic>)
                        ? decoded['tokens'] as Map<String, dynamic>
                        : decoded;

            newAccessToken = (source['access_token'] ??
                    source['accessToken'] ??
                    source['token'] ??
                    '')
                .toString();

            newRefreshToken = (source['refresh_token'] ??
                    source['refreshToken'] ??
                    refreshToken)
                .toString();
          }
        } catch (e) {
          print('[AuthenticatedHttpClient] Error parsing JSON from refresh response: $e');
        }

        if (newAccessToken.isEmpty) {
          print('[AuthenticatedHttpClient] Refresh response did not contain a valid access_token. Body: ${response.body}');
          await secureCachingService.clearAll();
          throw const SessionExpiredException('Invalid token response received from server.');
        }

        print('[AuthenticatedHttpClient] Token refresh SUCCEEDED! Saving new tokens...');
        await secureCachingService.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken.isNotEmpty ? newRefreshToken : refreshToken,
        );

        return newAccessToken;
      } else {
        print('[AuthenticatedHttpClient] Token refresh FAILED (HTTP ${response.statusCode}): ${response.body}. Clearing session.');
        await secureCachingService.clearAll();
        throw SessionExpiredException(
          'Failed to refresh token (Status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (e is SessionExpiredException) rethrow;
      print('[AuthenticatedHttpClient] Network or unexpected error during refresh: $e. Clearing session.');
      await secureCachingService.clearAll();
      throw SessionExpiredException('Failed to refresh authentication session: $e');
    }
  }

  /// Clones an [http.BaseRequest] before execution so it can be retried safely.
  Future<http.BaseRequest> _cloneRequest(http.BaseRequest request) async {
    if (request is http.Request) {
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..maxRedirects = request.maxRedirects
        ..followRedirects = request.followRedirects
        ..persistentConnection = request.persistentConnection
        ..bodyBytes = request.bodyBytes;
      return copy;
    } else if (request is http.MultipartRequest) {
      final copy = http.MultipartRequest(request.method, request.url)
        ..headers.addAll(request.headers)
        ..maxRedirects = request.maxRedirects
        ..followRedirects = request.followRedirects
        ..persistentConnection = request.persistentConnection
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
      return copy;
    } else {
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..maxRedirects = request.maxRedirects
        ..followRedirects = request.followRedirects
        ..persistentConnection = request.persistentConnection;
      return copy;
    }
  }

  @override
  void close() {
    innerClient.close();
    super.close();
  }
}
