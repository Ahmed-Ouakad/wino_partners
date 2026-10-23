import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_picture.dart';
import '../repositories/profile_repository.dart';

class GetProfilePicturesUseCase {
  final ProfileRepository repository;

  const GetProfilePicturesUseCase(this.repository);

  Future<Either<Failure, List<ProfilePicture>>> call() async {
    return await repository.getProfilePictures();
  }
}
