import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/onboarding_params.dart';
import '../repositories/onboarding_repository.dart';

/// Use case responsible for submitting vendor onboarding details.
class SubmitOnboardingUseCase {
  final OnboardingRepository repository;

  const SubmitOnboardingUseCase(this.repository);

  Future<Either<Failure, void>> call(OnboardingParams params) async {
    return await repository.submitOnboarding(params);
  }
}
