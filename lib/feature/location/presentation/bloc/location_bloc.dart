import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/location_coordinate.dart';
import '../../domain/usecases/get_city_suggestions.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_saved_location_coordinates.dart';
import '../../domain/usecases/save_location_coordinates.dart';
import '../../domain/usecases/search_for_city_coordinates.dart';
import '../../domain/usecases/update_location_coordinates.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetCurrentLocation getCurrentLocation;
  final SearchForCityCoordinates searchForCityCoordinates;
  final SaveLocationCoordinates saveLocationCoordinates;
  final GetCitySuggestions getCitySuggestions;
  final GetSavedLocationCoordinates getSavedLocation;
  final UpdateLocationCoordinates? updateLocationCoordinates;

  LocationBloc({
    required this.getCurrentLocation,
    required this.searchForCityCoordinates,
    required this.saveLocationCoordinates,
    required this.getCitySuggestions,
    required this.getSavedLocation,
    this.updateLocationCoordinates,
  }) : super(LocationInitial()) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<SearchCityEvent>(_onSearchCity);
    on<SaveLocationEvent>(_onSaveLocation);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<GetSuggestionsEvent>(_onGetSuggestions);
    on<SelectSuggestionEvent>(_onSelectSuggestion);
    on<CheckSavedLocationEvent>(_onCheckSavedLocation);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final failureOrCoordinate = await getCurrentLocation();

    failureOrCoordinate.fold(
      (failure) => emit(LocationError(_mapFailureToMessage(failure))),
      (coordinate) => emit(LocationLoaded(coordinate)),
    );
  }

  Future<void> _onSearchCity(
    SearchCityEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final failureOrCoordinate = await searchForCityCoordinates(event.cityName);

    failureOrCoordinate.fold(
      (failure) => emit(LocationError(_mapFailureToMessage(failure))),
      (coordinate) => emit(LocationLoaded(coordinate)),
    );
  }

  Future<void> _onSaveLocation(
    SaveLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final failureOrSuccess = await saveLocationCoordinates(
      event.coordinate,
      street: event.street,
    );

    failureOrSuccess.fold(
      (failure) => emit(LocationError(_mapFailureToMessage(failure))),
      (_) => emit(LocationSaved()),
    );
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    if (updateLocationCoordinates != null) {
      final failureOrSuccess = await updateLocationCoordinates!(
        event.coordinate,
        street: event.street,
        addressId: event.addressId,
      );

      failureOrSuccess.fold(
        (failure) => emit(LocationError(_mapFailureToMessage(failure))),
        (_) => emit(LocationSaved()),
      );
    } else {
      // Fallback to save if usecase wasn't provided
      final failureOrSuccess = await saveLocationCoordinates(
        event.coordinate,
        street: event.street,
      );
      failureOrSuccess.fold(
        (failure) => emit(LocationError(_mapFailureToMessage(failure))),
        (_) => emit(LocationSaved()),
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is LocationServiceDisabled) {
      return 'Les services de localisation sont désactivés. Veuillez les activer.';
    } else if (failure is PermissionFailure) {
      return 'Permission de localisation refusée.';
    } else if (failure is NetworkFailure) {
      return 'Veuillez vérifier votre connexion internet.';
    } else if (failure is NoLocationFailure) {
      return 'Impossible de trouver cette ville. Veuillez réessayer.';
    } else if (failure is CacheFailure) {
      return 'Échec de la sauvegarde locale.';
    }
    return failure.message.isNotEmpty ? failure.message : 'Une erreur inattendue est survenue.';
  }

  Future<void> _onGetSuggestions(
    GetSuggestionsEvent event,
    Emitter<LocationState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(LocationInitial());
      return;
    }

    final failureOrSuggestions = await getCitySuggestions(event.query);

    failureOrSuggestions.fold(
      (failure) => emit(LocationError(_mapFailureToMessage(failure))),
      (suggestions) => emit(LocationSuggestionsLoaded(suggestions)),
    );
  }

  void _onSelectSuggestion(
    SelectSuggestionEvent event,
    Emitter<LocationState> emit,
  ) {
    final coordinate = LocationCoordinate(
      latitude: event.suggestion.latitude,
      longitude: event.suggestion.longitude,
    );

    emit(LocationLoaded(coordinate));
  }

  void _onCheckSavedLocation(
    CheckSavedLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    final failureOrLocation = await getSavedLocation();

    failureOrLocation.fold(
      (failure) => emit(LocationCheckEmpty()),
      (location) => emit(LocationCheckSuccess()),
    );
  }
}
