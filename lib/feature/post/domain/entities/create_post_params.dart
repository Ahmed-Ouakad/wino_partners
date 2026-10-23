import 'package:equatable/equatable.dart';

/// Parameters for creating a vendor post (Reel or Story).
class CreatePostParams extends Equatable {
  final String mediaUrl;
  final String title;
  final String caption;
  final String mediaType;
  final bool isStory;

  const CreatePostParams({
    required this.mediaUrl,
    required this.title,
    required this.caption,
    this.mediaType = 'Video',
    this.isStory = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'media_url': mediaUrl,
      'title': title,
      'caption': caption,
      'media_type': mediaType,
      'is_story': isStory,
    };
  }

  @override
  List<Object?> get props => [mediaUrl, title, caption, mediaType, isStory];
}
