import 'package:equatable/equatable.dart';
import 'post.dart';

/// Group of posts categorized by their media type (e.g. Video, Image).
class GroupedPosts extends Equatable {
  final String mediaType;
  final String typeTitle;
  final List<Post> posts;

  const GroupedPosts({
    required this.mediaType,
    required this.typeTitle,
    required this.posts,
  });

  @override
  List<Object?> get props => [mediaType, typeTitle, posts];
}
