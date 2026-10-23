import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class ActivateProfilePictureUseCase {
  final ProfileRepository repository;

  const ActivateProfilePictureUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.activateProfilePicture(id);
  }
}
