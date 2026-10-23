import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/core/services/caching_service.dart';
import 'package:wino_partners/feature/location/data/datasources/location_remote_data_source.dart';
import 'package:wino_partners/feature/location/data/repositories/location_repository_impl.dart';
import 'package:wino_partners/feature/location/domain/entities/city_suggestion.dart';
import 'package:wino_partners/feature/location/domain/entities/location_coordinate.dart';
import 'package:wino_partners/feature/location/domain/repositories/location_repository.dart';
import 'package:wino_partners/feature/location/domain/usecases/get_city_suggestions.dart';
import 'package:wino_partners/feature/location/domain/usecases/get_current_location.dart';
import 'package:wino_partners/feature/location/domain/usecases/get_saved_location_coordinates.dart';
import 'package:wino_partners/feature/location/domain/usecases/save_location_coordinates.dart';
import 'package:wino_partners/feature/location/domain/usecases/search_for_city_coordinates.dart';
import 'package:wino_partners/feature/location/presentation/bloc/location_bloc.dart';
import 'package:wino_partners/feature/location/presentation/bloc/location_event.dart';
import 'package:wino_partners/feature/location/presentation/bloc/location_state.dart';

class MockCachingService implements CachingService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> clear() async => _storage.clear();

  @override
  double? getDouble(String key) => _storage[key] as double?;

  @override
  String? getString(String key) => _storage[key] as String?;

  @override
  Future<void> remove(String key) async => _storage.remove(key);

  @override
  Future<void> saveDouble(String key, double value) async => _storage[key] = value;

  @override
  Future<void> saveString(String key, String value) async => _storage[key] = value;
}

class MockLocationRemoteDataSource implements LocationRemoteDataSource {
  String? savedTitle;
  String? savedStreet;
  double? savedLat;
  double? savedLon;
  String reverseGeocodeResult = '123 Avenue Habib Bourguiba, Tunis';
  int reverseGeocodeCallCount = 0;

  @override
  Future<String?> saveVendorAddress({
    required String title,
    required String street,
    required double latitude,
    required double longitude,
  }) async {
    savedTitle = title;
    savedStreet = street;
    savedLat = latitude;
    savedLon = longitude;
    return 'mock_addr_id_123';
  }

  @override
  Future<void> updateVendorAddress({
    required String addressId,
    required String title,
    required String street,
    required double latitude,
    required double longitude,
  }) async {
    savedTitle = title;
    savedStreet = street;
    savedLat = latitude;
    savedLon = longitude;
  }

  @override
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    reverseGeocodeCallCount++;
    return reverseGeocodeResult;
  }
}

class MockLocationRepository implements LocationRepository {
  LocationCoordinate? savedCoordinate;
  String? savedStreet;

  @override
  Future<Either<Failure, void>> saveLocationCoordinates(
    LocationCoordinate locationCoordinate, {
    String? street,
  }) async {
    savedCoordinate = locationCoordinate;
    savedStreet = street;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateLocationCoordinates(
    LocationCoordinate locationCoordinate, {
    required String addressId,
    String? street,
  }) async {
    savedCoordinate = locationCoordinate;
    savedStreet = street;
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<CitySuggestion>>> getCitySuggestions(String query) async =>
      const Right([]);

  @override
  Future<Either<Failure, LocationCoordinate>> getCurrentLocation() async =>
      const Right(LocationCoordinate(latitude: 36.8, longitude: 10.1));

  @override
  Future<Either<Failure, LocationCoordinate>> getSavedLocationCoordinates() async =>
      const Right(LocationCoordinate(latitude: 36.8, longitude: 10.1));

  @override
  Future<Either<Failure, LocationCoordinate>> searchForCityCoordinates(
    String cityName,
  ) async =>
      const Right(LocationCoordinate(latitude: 36.8, longitude: 10.1));
}

void main() {
  group('LocationRepositoryImpl - saveLocationCoordinates', () {
    late MockCachingService mockCache;
    late MockLocationRemoteDataSource mockRemote;
    late LocationRepositoryImpl repository;

    setUp(() {
      mockCache = MockCachingService();
      mockRemote = MockLocationRemoteDataSource();
      repository = LocationRepositoryImpl(
        cachingService: mockCache,
        remoteDataSource: mockRemote,
      );
    });

    test('saves coordinates to cache and posts address to backend with provided street', () async {
      const coord = LocationCoordinate(latitude: 36.8065, longitude: 10.1815);

      final result = await repository.saveLocationCoordinates(
        coord,
        street: 'Rue de Paris, Tunis',
      );

      expect(result.isRight(), true);
      expect(mockCache.getDouble(latitudeKey), 36.8065);
      expect(mockCache.getDouble(longitudeKey), 10.1815);
      expect(mockRemote.savedTitle, 'adresse principale');
      expect(mockRemote.savedStreet, 'Rue de Paris, Tunis');
      expect(mockRemote.savedLat, 36.8065);
      expect(mockRemote.savedLon, 10.1815);
      expect(mockRemote.reverseGeocodeCallCount, 0);
    });

    test('reverse geocodes street when no street is provided', () async {
      const coord = LocationCoordinate(latitude: 36.8065, longitude: 10.1815);

      final result = await repository.saveLocationCoordinates(coord);

      expect(result.isRight(), true);
      expect(mockRemote.savedTitle, 'adresse principale');
      expect(mockRemote.savedStreet, '123 Avenue Habib Bourguiba, Tunis');
      expect(mockRemote.reverseGeocodeCallCount, 1);
    });
  });

  group('LocationBloc - SaveLocationEvent', () {
    test('emits [LocationLoading, LocationSaved] on successful save', () async {
      final mockRepo = MockLocationRepository();
      final bloc = LocationBloc(
        getCurrentLocation: GetCurrentLocation(mockRepo),
        searchForCityCoordinates: SearchForCityCoordinates(mockRepo),
        saveLocationCoordinates: SaveLocationCoordinates(mockRepo),
        getCitySuggestions: GetCitySuggestions(mockRepo),
        getSavedLocation: GetSavedLocationCoordinates(mockRepo),
      );

      const coord = LocationCoordinate(latitude: 36.8065, longitude: 10.1815);

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LocationLoading>(),
          isA<LocationSaved>(),
        ]),
      );

      bloc.add(const SaveLocationEvent(coord, street: 'Centre Ville'));
    });
  });
}
