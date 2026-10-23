import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/onboarding_params.dart';
import '../entities/service_category.dart';

/// Contract for onboarding operations in the domain layer.
abstract class OnboardingRepository {
  /// Fetches the list of service categories from the remote server.
  Future<Either<Failure, List<ServiceCategory>>> getServiceCategories();

  /// Submits the onboarding configuration (category and business description).
  Future<Either<Failure, void>> submitOnboarding(OnboardingParams params);
}
