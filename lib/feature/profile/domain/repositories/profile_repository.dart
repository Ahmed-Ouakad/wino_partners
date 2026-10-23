import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_picture.dart';
import '../entities/user_profile.dart';

/// Contract for profile and vendor settings operations.
abstract class ProfileRepository {
  /// Fetches the profile of the current authenticated user.
  Future<Either<Failure, UserProfile>> getUserProfile();

  /// Updates personal profile information (fullname and phone_number).
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required String fullname,
    required String phoneNumber,
  });

  /// Updates user password via /users/me/password.
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Updates vendor service business name & description via /v1/vendor/services/{id}.
  Future<Either<Failure, void>> updateBusinessService({
    required String serviceId,
    required String title,
    required String description,
    required String categoryId,
  });

  /// Fetches all profile pictures for the current user via /v1/users/me/profile-pictures.
  Future<Either<Failure, List<ProfilePicture>>> getProfilePictures();

  /// Adds a new profile picture via /v1/users/me/profile-pictures.
  Future<Either<Failure, ProfilePicture>> addProfilePicture(String mediaUrl);

  /// Activates a profile picture via /v1/users/me/profile-pictures/{id}/activate.
  Future<Either<Failure, void>> activateProfilePicture(String id);

  /// Deletes a profile picture via /v1/users/me/profile-pictures/{id}.
  Future<Either<Failure, void>> deleteProfilePicture(String id);
}
