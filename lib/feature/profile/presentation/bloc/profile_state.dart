import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_picture.dart';
import '../../domain/entities/user_profile.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final bool isUpdatingProfile;
  final bool isUpdatingPassword;
  final bool isUpdatingBusiness;
  final bool isUploadingPicture;
  final bool isManagingPicture;
  final bool isLoggedOut;

  final UserProfile? userProfile;
  final List<ProfilePicture> profilePictures;

  // Cached business & address metadata
  final String? businessTitle;
  final String? businessDescription;
  final String? businessCategoryId;
  final String? addressStreet;
  final String? addressTitle;

  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.isUpdatingProfile = false,
    this.isUpdatingPassword = false,
    this.isUpdatingBusiness = false,
    this.isUploadingPicture = false,
    this.isManagingPicture = false,
    this.isLoggedOut = false,
    this.userProfile,
    this.profilePictures = const [],
    this.businessTitle,
    this.businessDescription,
    this.businessCategoryId,
    this.addressStreet,
    this.addressTitle,
    this.errorMessage,
    this.successMessage,
  });

  /// The activated picture that should be displayed on the avatar.
  ProfilePicture? get activeProfilePicture {
    try {
      return profilePictures.firstWhere((p) => p.isActive);
    } catch (_) {
      return profilePictures.isNotEmpty ? profilePictures.first : null;
    }
  }

  ProfileState copyWith({
    bool? isLoading,
    bool? isUpdatingProfile,
    bool? isUpdatingPassword,
    bool? isUpdatingBusiness,
    bool? isUploadingPicture,
    bool? isManagingPicture,
    bool? isLoggedOut,
    UserProfile? userProfile,
    List<ProfilePicture>? profilePictures,
    String? businessTitle,
    String? businessDescription,
    String? businessCategoryId,
    String? addressStreet,
    String? addressTitle,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
      isUpdatingPassword: isUpdatingPassword ?? this.isUpdatingPassword,
      isUpdatingBusiness: isUpdatingBusiness ?? this.isUpdatingBusiness,
      isUploadingPicture: isUploadingPicture ?? this.isUploadingPicture,
      isManagingPicture: isManagingPicture ?? this.isManagingPicture,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      userProfile: userProfile ?? this.userProfile,
      profilePictures: profilePictures ?? this.profilePictures,
      businessTitle: businessTitle ?? this.businessTitle,
      businessDescription: businessDescription ?? this.businessDescription,
      businessCategoryId: businessCategoryId ?? this.businessCategoryId,
      addressStreet: addressStreet ?? this.addressStreet,
      addressTitle: addressTitle ?? this.addressTitle,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isUpdatingProfile,
        isUpdatingPassword,
        isUpdatingBusiness,
        isUploadingPicture,
        isManagingPicture,
        isLoggedOut,
        userProfile,
        profilePictures,
        businessTitle,
        businessDescription,
        businessCategoryId,
        addressStreet,
        addressTitle,
        errorMessage,
        successMessage,
      ];
}
