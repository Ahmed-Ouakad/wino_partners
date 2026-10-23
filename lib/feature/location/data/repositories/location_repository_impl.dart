import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/caching_service.dart';
import '../../domain/entities/city_suggestion.dart';
import '../../domain/entities/location_coordinate.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final CachingService cachingService;
  final LocationRemoteDataSource remoteDataSource;
  final http.Client? client;

  LocationRepositoryImpl({
    required this.cachingService,
    required this.remoteDataSource,
    this.client,
  });

  @override
  Future<Either<Failure, LocationCoordinate>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return Left(const LocationServiceDisabled());

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return Left(const PermissionFailure());
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      return Right(LocationCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocationCoordinates(
    LocationCoordinate locationCoordinate, {
    String? street,
  }) async {
    try {
      // 1. Cache coordinates locally
      await cachingService.saveDouble(latitudeKey, locationCoordinate.latitude);
      await cachingService.saveDouble(longitudeKey, locationCoordinate.longitude);

      // 2. Resolve street address: use provided street or reverse geocode
      String resolvedStreet = street?.trim() ?? '';
      if (resolvedStreet.isEmpty) {
        resolvedStreet = await remoteDataSource.reverseGeocode(
          latitude: locationCoordinate.latitude,
          longitude: locationCoordinate.longitude,
        );
      }

      // 3. Send address to backend server
      final addressId = await remoteDataSource.saveVendorAddress(
        title: 'adresse principale',
        street: resolvedStreet,
        latitude: locationCoordinate.latitude,
        longitude: locationCoordinate.longitude,
      );

      if (addressId != null) {
        await cachingService.saveString(addressIdKey, addressId);
      }
      await cachingService.saveString(addressStreetKey, resolvedStreet);
      await cachingService.saveString(addressTitleKey, 'adresse principale');

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An error occurred while saving address: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocationCoordinates(
    LocationCoordinate locationCoordinate, {
    String? street,
    required String addressId,
  }) async {
    try {
      // 1. Cache coordinates locally
      await cachingService.saveDouble(latitudeKey, locationCoordinate.latitude);
      await cachingService.saveDouble(longitudeKey, locationCoordinate.longitude);

      // 2. Resolve street address: use provided street or reverse geocode
      String resolvedStreet = street?.trim() ?? '';
      if (resolvedStreet.isEmpty) {
        resolvedStreet = await remoteDataSource.reverseGeocode(
          latitude: locationCoordinate.latitude,
          longitude: locationCoordinate.longitude,
        );
      }

      // 3. Update address on backend server via PATCH
      await remoteDataSource.updateVendorAddress(
        addressId: addressId,
        title: 'Downtown Central Branch',
        street: resolvedStreet,
        latitude: locationCoordinate.latitude,
        longitude: locationCoordinate.longitude,
      );

      await cachingService.saveString(addressIdKey, addressId);
      await cachingService.saveString(addressStreetKey, resolvedStreet);
      await cachingService.saveString(addressTitleKey, 'Downtown Central Branch');

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An error occurred while updating address: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LocationCoordinate>> searchForCityCoordinates(
    String cityName,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(cityName)}&format=json&limit=1&countrycodes=tn',
      );
      final httpClient = client ?? http.Client();
      final response = await httpClient.get(url, headers: {
        'User-Agent': 'com.yourcompany.wino',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Right(LocationCoordinate(
            latitude: double.parse(data.first['lat']),
            longitude: double.parse(data.first['lon']),
          ));
        }
      }
      return Left(const NoLocationFailure());
    } catch (e) {
      return Left(const NoLocationFailure());
    }
  }

  @override
  Future<Either<Failure, List<CitySuggestion>>> getCitySuggestions(
    String query,
  ) async {
    if (query.length < 2) return const Right([]);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5&countrycodes=tn',
      );
      final httpClient = client ?? http.Client();
      final response = await httpClient.get(url, headers: {
        'User-Agent': 'com.yourcompany.wino',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final suggestions = data
            .map((item) => CitySuggestion(
                  name: item['display_name'] ?? 'Unknown',
                  latitude: double.parse(item['lat']),
                  longitude: double.parse(item['lon']),
                ))
            .toList();

        return Right(suggestions);
      } else {
        return Left(const NetworkFailure());
      }
    } catch (e) {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, LocationCoordinate>> getSavedLocationCoordinates() async {
    try {
      double? latitude = cachingService.getDouble(latitudeKey);
      double? longitude = cachingService.getDouble(longitudeKey);
      if (longitude != null && latitude != null) {
        return Right(
          LocationCoordinate(latitude: latitude, longitude: longitude),
        );
      }
      return Left(const CacheFailure());
    } catch (e) {
      return Left(const CacheFailure());
    }
  }
}
