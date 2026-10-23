import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.title,
    required super.caption,
    required super.mediaUrl,
    required super.mediaType,
    super.isStory = false,
    super.viewsCount = 0,
    super.createdAt,
    super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? json['mediaUrl'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? json['mediaType'] as String? ?? 'Video',
      isStory: json['is_story'] as bool? ?? json['isStory'] as bool? ?? false,
      viewsCount: (json['views_count'] ?? json['viewsCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'caption': caption,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'is_story': isStory,
      'views_count': viewsCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
