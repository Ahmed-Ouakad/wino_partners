import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/city_suggestion.dart';
import '../repositories/location_repository.dart';

class GetCitySuggestions {
  final LocationRepository repository;

  const GetCitySuggestions(this.repository);

  Future<Either<Failure, List<CitySuggestion>>> call(String query) async {
    return await repository.getCitySuggestions(query);
  }
}
