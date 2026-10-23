import 'package:equatable/equatable.dart';

/// Represents a vendor post entity (Reel, Video, Image, or Story).
class Post extends Equatable {
  final String id;
  final String title;
  final String caption;
  final String mediaUrl;
  final String mediaType;
  final bool isStory;
  final int viewsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Post({
    required this.id,
    required this.title,
    required this.caption,
    required this.mediaUrl,
    required this.mediaType,
    this.isStory = false,
    this.viewsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool get isVideo => mediaType.toLowerCase() == 'video';
  bool get isImage => mediaType.toLowerCase() == 'image';

  @override
  List<Object?> get props => [
        id,
        title,
        caption,
        mediaUrl,
        mediaType,
        isStory,
        viewsCount,
        createdAt,
        updatedAt,
      ];
}
