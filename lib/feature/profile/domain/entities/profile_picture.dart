import 'package:equatable/equatable.dart';

/// Entity representing a vendor user's profile picture.
class ProfilePicture extends Equatable {
  final String id;
  final String mediaUrl;
  final bool isActive;
  final String? userId;
  final String? createdAt;

  const ProfilePicture({
    required this.id,
    required this.mediaUrl,
    this.isActive = false,
    this.userId,
    this.createdAt,
  });

  ProfilePicture copyWith({
    String? id,
    String? mediaUrl,
    bool? isActive,
    String? userId,
    String? createdAt,
  }) {
    return ProfilePicture(
      id: id ?? this.id,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isActive: isActive ?? this.isActive,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, mediaUrl, isActive, userId, createdAt];
}
