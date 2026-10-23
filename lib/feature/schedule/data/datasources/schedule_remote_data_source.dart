// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/secure_caching_service.dart';
import '../../domain/entities/day_schedule.dart';

/// Contract for schedule remote data operations.
abstract class ScheduleRemoteDataSource {
  /// Submits the availability for a single day to the backend.
  Future<void> submitDayAvailability({
    required String serviceId,
    required DaySchedule schedule,
  });

  /// Submits all enabled availability days one by one.
  Future<void> submitFullSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  });

  /// Updates availability with an array of all availabilities using PUT.
  Future<void> updateFullSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  });
}

/// Implementation of [ScheduleRemoteDataSource] using [http.Client].
class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final http.Client client;
  final SecureCachingService? secureCachingService;
  final String baseUrl;

  ScheduleRemoteDataSourceImpl({
    required this.client,
    this.secureCachingService,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Future<void> submitDayAvailability({
    required String serviceId,
    required DaySchedule schedule,
  }) async {
    final uri = Uri.parse(
      '$baseUrl${ApiConstants.serviceAvailabilityEndpoint(serviceId)}',
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
      'day': schedule.apiDay,
      'open_time': schedule.openTime,
      'close_time': schedule.closeTime,
    });

    print('================================================================');
    print('[API REQUEST - SUBMIT AVAILABILITY FOR ${schedule.apiDay}]');
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
      print('[API RESPONSE - SUBMIT AVAILABILITY FOR ${schedule.apiDay}]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        String errorMessage =
            'Failed to save schedule for ${schedule.dayName} (Status ${response.statusCode})';
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
        message: 'An unexpected error occurred for ${schedule.dayName}: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> submitFullSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  }) async {
    final activeDays = schedules.where((s) => s.isOpen).toList();
    for (final daySchedule in activeDays) {
      await submitDayAvailability(
        serviceId: serviceId,
        schedule: daySchedule,
      );
    }
  }

  @override
  Future<void> updateFullSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  }) async {
    final uri = Uri.parse(
      '$baseUrl${ApiConstants.serviceAvailabilityEndpoint(serviceId)}',
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

    final activeDays = schedules.where((s) => s.isOpen).toList();
    final body = jsonEncode(
      activeDays.map((s) => {
        'day': s.apiDay,
        'open_time': s.openTime,
        'close_time': s.closeTime,
      }).toList(),
    );

    print('================================================================');
    print('[API REQUEST - UPDATE AVAILABILITY (PUT ARRAY)]');
    print('URL     : $uri');
    print('METHOD  : PUT');
    print('HEADERS : $headers');
    print('BODY    : $body');
    print('================================================================');

    try {
      final response = await client.put(
        uri,
        headers: headers,
        body: body,
      );

      print('================================================================');
      print('[API RESPONSE - UPDATE AVAILABILITY]');
      print('STATUS CODE : ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        String errorMessage =
            'Failed to update schedule (Status ${response.statusCode})';
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
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
