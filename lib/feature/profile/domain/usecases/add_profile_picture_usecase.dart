import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_picture.dart';
import '../repositories/profile_repository.dart';

class AddProfilePictureUseCase {
  final ProfileRepository repository;

  const AddProfilePictureUseCase(this.repository);

  Future<Either<Failure, ProfilePicture>> call(String mediaUrl) async {
    return await repository.addProfilePicture(mediaUrl);
  }
}
