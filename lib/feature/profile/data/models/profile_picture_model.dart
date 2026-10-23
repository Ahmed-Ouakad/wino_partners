import '../../domain/entities/profile_picture.dart';

class ProfilePictureModel extends ProfilePicture {
  const ProfilePictureModel({
    required super.id,
    required super.mediaUrl,
    super.isActive,
    super.userId,
    super.createdAt,
  });

  factory ProfilePictureModel.fromJson(Map<String, dynamic> json) {
    return ProfilePictureModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      mediaUrl: (json['mediaUrl'] ?? json['media_url'] ?? '').toString(),
      isActive: (json['isActive'] ?? json['is_active'] ?? false) as bool,
      userId: (json['userId'] ?? json['user_id'])?.toString(),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaUrl': mediaUrl,
      'isActive': isActive,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}
