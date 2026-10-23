import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/caching_service.dart';
import '../../domain/entities/profile_picture.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final CachingService cachingService;

  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.cachingService,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final model = await remoteDataSource.getUserProfile();

      // Synchronize first service details to local cache
      if (model.serviceId != null && model.serviceId!.isNotEmpty) {
        await cachingService.saveString(serviceIdKey, model.serviceId!);
      }
      if (model.businessTitle != null && model.businessTitle!.isNotEmpty) {
        await cachingService.saveString(businessTitleKey, model.businessTitle!);
      }
      if (model.businessDescription != null &&
          model.businessDescription!.isNotEmpty) {
        await cachingService.saveString(
          businessDescriptionKey,
          model.businessDescription!,
        );
      }
      if (model.categoryId != null && model.categoryId!.isNotEmpty) {
        await cachingService.saveString(
          businessCategoryIdKey,
          model.categoryId!,
        );
      }

      // Synchronize first address details to local cache
      if (model.addressId != null && model.addressId!.isNotEmpty) {
        await cachingService.saveString(addressIdKey, model.addressId!);
      }
      if (model.addressTitle != null && model.addressTitle!.isNotEmpty) {
        await cachingService.saveString(addressTitleKey, model.addressTitle!);
      }
      if (model.addressStreet != null && model.addressStreet!.isNotEmpty) {
        await cachingService.saveString(addressStreetKey, model.addressStreet!);
      }
      if (model.latitude != null) {
        await cachingService.saveDouble(latitudeKey, model.latitude!);
      }
      if (model.longitude != null) {
        await cachingService.saveDouble(longitudeKey, model.longitude!);
      }

      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required String fullname,
    required String phoneNumber,
  }) async {
    try {
      final model = await remoteDataSource.updateUserProfile(
        fullname: fullname,
        phoneNumber: phoneNumber,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBusinessService({
    required String serviceId,
    required String title,
    required String description,
    required String categoryId,
  }) async {
    try {
      await remoteDataSource.updateBusinessService(
        serviceId: serviceId,
        title: title,
        description: description,
        categoryId: categoryId,
      );
      await cachingService.saveString(businessTitleKey, title);
      await cachingService.saveString(businessDescriptionKey, description);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProfilePicture>>> getProfilePictures() async {
    try {
      final pictures = await remoteDataSource.getProfilePictures();
      return Right(pictures);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProfilePicture>> addProfilePicture(String mediaUrl) async {
    try {
      final picture = await remoteDataSource.addProfilePicture(mediaUrl);
      return Right(picture);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> activateProfilePicture(String id) async {
    try {
      await remoteDataSource.activateProfilePicture(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfilePicture(String id) async {
    try {
      await remoteDataSource.deleteProfilePicture(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
