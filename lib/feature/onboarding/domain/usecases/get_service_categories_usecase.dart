import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_category.dart';
import '../repositories/onboarding_repository.dart';

/// Use case responsible for retrieving service categories from the repository.
class GetServiceCategoriesUseCase {
  final OnboardingRepository repository;

  const GetServiceCategoriesUseCase(this.repository);

  Future<Either<Failure, List<ServiceCategory>>> call() async {
    return await repository.getServiceCategories();
  }
}
