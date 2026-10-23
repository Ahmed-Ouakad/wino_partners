import 'package:equatable/equatable.dart';
import '../../domain/entities/grouped_posts.dart';
import '../../domain/entities/post.dart';

enum PostListStatus { initial, loading, success, failure }

class PostListState extends Equatable {
  final PostListStatus status;
  final List<Post> posts;
  final List<GroupedPosts> groups;
  final bool isRefreshing;
  final String? deletingPostId;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const PostListState({
    this.status = PostListStatus.initial,
    this.posts = const [],
    this.groups = const [],
    this.isRefreshing = false,
    this.deletingPostId,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  int get totalCount => posts.length;
  bool get isEmpty => posts.isEmpty;

  PostListState copyWith({
    PostListStatus? status,
    List<Post>? posts,
    List<GroupedPosts>? groups,
    bool? isRefreshing,
    String? deletingPostId,
    bool clearDeletingPostId = false,
    String? errorMessage,
    bool clearError = false,
    String? actionSuccessMessage,
    bool clearActionSuccess = false,
  }) {
    return PostListState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      groups: groups ?? this.groups,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      deletingPostId: clearDeletingPostId
          ? null
          : (deletingPostId ?? this.deletingPostId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSuccessMessage: clearActionSuccess
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        groups,
        isRefreshing,
        deletingPostId,
        errorMessage,
        actionSuccessMessage,
      ];
}
