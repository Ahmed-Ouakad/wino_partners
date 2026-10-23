import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/caching_service.dart';
import '../../../../core/services/secure_caching_service.dart';
import '../../../product/domain/usecases/get_upload_url_usecase.dart';
import '../../../product/domain/usecases/upload_file_usecase.dart';
import '../../domain/entities/profile_picture.dart';
import '../../domain/usecases/activate_profile_picture_usecase.dart';
import '../../domain/usecases/add_profile_picture_usecase.dart';
import '../../domain/usecases/delete_profile_picture_usecase.dart';
import '../../domain/usecases/get_profile_pictures_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_business_service_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final UpdateBusinessServiceUseCase updateBusinessServiceUseCase;
  final GetProfilePicturesUseCase? getProfilePicturesUseCase;
  final AddProfilePictureUseCase? addProfilePictureUseCase;
  final ActivateProfilePictureUseCase? activateProfilePictureUseCase;
  final DeleteProfilePictureUseCase? deleteProfilePictureUseCase;
  final GetUploadUrlUseCase? getUploadUrlUseCase;
  final UploadFileUseCase? uploadFileUseCase;
  final CachingService cachingService;
  final SecureCachingService secureCachingService;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.updatePasswordUseCase,
    required this.updateBusinessServiceUseCase,
    this.getProfilePicturesUseCase,
    this.addProfilePictureUseCase,
    this.activateProfilePictureUseCase,
    this.deleteProfilePictureUseCase,
    this.getUploadUrlUseCase,
    this.uploadFileUseCase,
    required this.cachingService,
    required this.secureCachingService,
  }) : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<LoadProfilePicturesEvent>(_onLoadProfilePictures);
    on<UploadProfilePictureEvent>(_onUploadProfilePicture);
    on<ActivateProfilePictureEvent>(_onActivateProfilePicture);
    on<DeleteProfilePictureEvent>(_onDeleteProfilePicture);
    on<UpdateProfileInfoEvent>(_onUpdateProfileInfo);
    on<ChangePasswordEvent>(_onChangePassword);
    on<UpdateBusinessInfoEvent>(_onUpdateBusinessInfo);
    on<RefreshCachedDetailsEvent>(_onRefreshCachedDetails);
    on<LogoutEvent>(_onLogout);
  }

  void _loadCachedData(Emitter<ProfileState> emit) {
    final bTitle = cachingService.getString(businessTitleKey);
    final bDesc = cachingService.getString(businessDescriptionKey);
    final bCatId = cachingService.getString(businessCategoryIdKey);
    final aStreet = cachingService.getString(addressStreetKey);
    final aTitle = cachingService.getString(addressTitleKey);

    emit(state.copyWith(
      businessTitle: bTitle,
      businessDescription: bDesc,
      businessCategoryId: bCatId,
      addressStreet: aStreet,
      addressTitle: aTitle,
    ));
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    _loadCachedData(emit);
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    final result = await getUserProfileUseCase();
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (profile) {
        emit(state.copyWith(
          isLoading: false,
          userProfile: profile,
          businessTitle: profile.businessTitle ?? state.businessTitle,
          businessDescription:
              profile.businessDescription ?? state.businessDescription,
          businessCategoryId: profile.categoryId ?? state.businessCategoryId,
          addressStreet: profile.addressStreet ?? state.addressStreet,
          addressTitle: profile.addressTitle ?? state.addressTitle,
        ));
      },
    );

    // Also load profile pictures if usecase is available
    if (getProfilePicturesUseCase != null) {
      final picturesResult = await getProfilePicturesUseCase!();
      picturesResult.fold(
        (_) {},
        (pictures) {
          emit(state.copyWith(profilePictures: pictures));
        },
      );
    }
  }

  Future<void> _onLoadProfilePictures(
    LoadProfilePicturesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (getProfilePicturesUseCase == null) return;

    final result = await getProfilePicturesUseCase!();
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (pictures) {
        emit(state.copyWith(profilePictures: pictures));
      },
    );
  }

  Future<void> _onUploadProfilePicture(
    UploadProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (getUploadUrlUseCase == null ||
        uploadFileUseCase == null ||
        addProfilePictureUseCase == null) {
      emit(state.copyWith(
        errorMessage: 'Cas d\'utilisation d\'upload non configuré.',
      ));
      return;
    }

    emit(state.copyWith(
      isUploadingPicture: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final extension = event.imageFile.path.split('.').last;
      final filename =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // 1. Get upload URL
      final uploadUrlResult = await getUploadUrlUseCase!(
        GetUploadUrlParams(filename: filename, folder: 'avatars'),
      );

      final uploadData = uploadUrlResult.fold(
        (failure) {
          emit(state.copyWith(
            isUploadingPicture: false,
            errorMessage: failure.message,
          ));
          return null;
        },
        (data) => data,
      );

      if (uploadData == null) return;

      // 2. Upload file
      final uploadResult = await uploadFileUseCase!(
        UploadFileParams(
          uploadUrl: uploadData.uploadUrl,
          token: uploadData.token,
          file: event.imageFile,
        ),
      );

      final uploadSuccess = uploadResult.fold(
        (failure) {
          emit(state.copyWith(
            isUploadingPicture: false,
            errorMessage: failure.message,
          ));
          return false;
        },
        (_) => true,
      );

      if (!uploadSuccess) return;

      // 3. Post to /v1/users/me/profile-pictures
      final addResult = await addProfilePictureUseCase!(uploadData.publicUrl);

      addResult.fold(
        (failure) {
          emit(state.copyWith(
            isUploadingPicture: false,
            errorMessage: failure.message,
          ));
        },
        (newPicture) async {
          // Add to current pictures
          final updatedPictures = List<ProfilePicture>.from(state.profilePictures);
          // If this is the only picture or we want it active, activate it
          if (updatedPictures.isEmpty && activateProfilePictureUseCase != null) {
            await activateProfilePictureUseCase!(newPicture.id);
            updatedPictures.add(newPicture.copyWith(isActive: true));
          } else {
            updatedPictures.add(newPicture);
          }

          emit(state.copyWith(
            isUploadingPicture: false,
            profilePictures: updatedPictures,
            successMessage: 'Photo de profil ajoutée avec succès !',
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isUploadingPicture: false,
        errorMessage: 'Erreur lors de l\'upload : ${e.toString()}',
      ));
    }
  }

  Future<void> _onActivateProfilePicture(
    ActivateProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (activateProfilePictureUseCase == null) return;

    emit(state.copyWith(
      isManagingPicture: true,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await activateProfilePictureUseCase!(event.pictureId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isManagingPicture: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        final updated = state.profilePictures.map((pic) {
          return pic.copyWith(isActive: pic.id == event.pictureId);
        }).toList();

        emit(state.copyWith(
          isManagingPicture: false,
          profilePictures: updated,
          successMessage: 'Photo de profil activée avec succès !',
        ));
      },
    );
  }

  Future<void> _onDeleteProfilePicture(
    DeleteProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (deleteProfilePictureUseCase == null) return;

    emit(state.copyWith(
      isManagingPicture: true,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await deleteProfilePictureUseCase!(event.pictureId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isManagingPicture: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        final updated = state.profilePictures
            .where((pic) => pic.id != event.pictureId)
            .toList();

        emit(state.copyWith(
          isManagingPicture: false,
          profilePictures: updated,
          successMessage: 'Photo de profil supprimée avec succès !',
        ));
      },
    );
  }

  Future<void> _onUpdateProfileInfo(
    UpdateProfileInfoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      isUpdatingProfile: true,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await updateUserProfileUseCase(
      UpdateUserProfileParams(
        fullname: event.fullname,
        phoneNumber: event.phoneNumber,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isUpdatingProfile: false,
          errorMessage: failure.message,
        ));
      },
      (updatedProfile) {
        final mergedProfile = state.userProfile != null
            ? state.userProfile!.copyWith(
                fullname: updatedProfile.fullname,
                phoneNumber: updatedProfile.phoneNumber,
              )
            : updatedProfile;
        emit(state.copyWith(
          isUpdatingProfile: false,
          userProfile: mergedProfile,
          successMessage: 'Profil mis à jour avec succès !',
        ));
      },
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      isUpdatingPassword: true,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await updatePasswordUseCase(
      UpdatePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isUpdatingPassword: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(
          isUpdatingPassword: false,
          successMessage: 'Mot de passe modifié avec succès !',
        ));
      },
    );
  }

  Future<void> _onUpdateBusinessInfo(
    UpdateBusinessInfoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final serviceId = cachingService.getString(serviceIdKey);
    final categoryId = cachingService.getString(businessCategoryIdKey) ?? '';

    if (serviceId == null || serviceId.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Identifiant du commerce introuvable.',
      ));
      return;
    }

    emit(state.copyWith(
      isUpdatingBusiness: true,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await updateBusinessServiceUseCase(
      UpdateBusinessServiceParams(
        serviceId: serviceId,
        title: event.title,
        description: event.description,
        categoryId: categoryId,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isUpdatingBusiness: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(
          isUpdatingBusiness: false,
          businessTitle: event.title,
          businessDescription: event.description,
          successMessage: 'Informations du commerce mises à jour avec succès !',
        ));
      },
    );
  }

  void _onRefreshCachedDetails(
    RefreshCachedDetailsEvent event,
    Emitter<ProfileState> emit,
  ) {
    _loadCachedData(emit);
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await secureCachingService.clearAll();
    await cachingService.clear();
    emit(state.copyWith(isLoggedOut: true));
  }
}
