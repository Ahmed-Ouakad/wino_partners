import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Loads user profile and cached vendor data.
class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

/// Loads all profile pictures for the user.
class LoadProfilePicturesEvent extends ProfileEvent {
  const LoadProfilePicturesEvent();
}

/// Uploads a new profile picture and sets it on the server.
class UploadProfilePictureEvent extends ProfileEvent {
  final File imageFile;

  const UploadProfilePictureEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile.path];
}

/// Activates a profile picture via /v1/users/me/profile-pictures/{id}/activate.
class ActivateProfilePictureEvent extends ProfileEvent {
  final String pictureId;

  const ActivateProfilePictureEvent(this.pictureId);

  @override
  List<Object?> get props => [pictureId];
}

/// Deletes a profile picture via /v1/users/me/profile-pictures/{id}.
class DeleteProfilePictureEvent extends ProfileEvent {
  final String pictureId;

  const DeleteProfilePictureEvent(this.pictureId);

  @override
  List<Object?> get props => [pictureId];
}

/// Updates personal user info (fullname and phone_number).
class UpdateProfileInfoEvent extends ProfileEvent {
  final String fullname;
  final String phoneNumber;

  const UpdateProfileInfoEvent({
    required this.fullname,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullname, phoneNumber];
}

/// Updates password via /users/me/password.
class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Updates business details (title and description) via /v1/vendor/services/{id}.
class UpdateBusinessInfoEvent extends ProfileEvent {
  final String title;
  final String description;

  const UpdateBusinessInfoEvent({
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [title, description];
}

/// Refreshes local cached values (e.g. after returning from location picker or schedule screen).
class RefreshCachedDetailsEvent extends ProfileEvent {
  const RefreshCachedDetailsEvent();
}

/// Logs out the user by clearing local cache and secure tokens.
class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}
