import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfileParams extends Equatable {
  final String fullname;
  final String phoneNumber;

  const UpdateUserProfileParams({
    required this.fullname,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullname, phoneNumber];
}

class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  const UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(
      fullname: params.fullname,
      phoneNumber: params.phoneNumber,
    );
  }
}
