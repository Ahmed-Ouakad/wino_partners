import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class DeleteProfilePictureUseCase {
  final ProfileRepository repository;

  const DeleteProfilePictureUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteProfilePicture(id);
  }
}
