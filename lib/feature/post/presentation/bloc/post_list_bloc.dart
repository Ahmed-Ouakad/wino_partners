import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/grouped_posts.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/delete_post_usecase.dart';
import '../../domain/usecases/get_vendor_posts_usecase.dart';
import 'post_list_event.dart';
import 'post_list_state.dart';

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final GetVendorPostsUseCase getVendorPostsUseCase;
  final DeletePostUseCase deletePostUseCase;

  PostListBloc({
    required this.getVendorPostsUseCase,
    required this.deletePostUseCase,
  }) : super(const PostListState()) {
    on<LoadVendorPostsEvent>(_onLoadVendorPosts);
    on<RefreshVendorPostsEvent>(_onRefreshVendorPosts);
    on<DeletePostEvent>(_onDeletePost);
  }

  Future<void> _onLoadVendorPosts(
    LoadVendorPostsEvent event,
    Emitter<PostListState> emit,
  ) async {
    emit(state.copyWith(
      status: PostListStatus.loading,
      clearError: true,
    ));

    final result = await getVendorPostsUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostListStatus.failure,
        errorMessage: failure.message,
      )),
      (posts) {
        final groups = _groupPosts(posts);
        emit(state.copyWith(
          status: PostListStatus.success,
          posts: posts,
          groups: groups,
          clearError: true,
        ));
      },
    );
  }

  Future<void> _onRefreshVendorPosts(
    RefreshVendorPostsEvent event,
    Emitter<PostListState> emit,
  ) async {
    emit(state.copyWith(
      isRefreshing: true,
      clearError: true,
    ));

    final result = await getVendorPostsUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isRefreshing: false,
        errorMessage: failure.message,
      )),
      (posts) {
        final groups = _groupPosts(posts);
        emit(state.copyWith(
          status: PostListStatus.success,
          posts: posts,
          groups: groups,
          isRefreshing: false,
          clearError: true,
        ));
      },
    );
  }

  Future<void> _onDeletePost(
    DeletePostEvent event,
    Emitter<PostListState> emit,
  ) async {
    emit(state.copyWith(
      deletingPostId: event.postId,
      clearError: true,
      clearActionSuccess: true,
    ));

    final result = await deletePostUseCase(event.postId);

    result.fold(
      (failure) => emit(state.copyWith(
        clearDeletingPostId: true,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedPosts =
            state.posts.where((p) => p.id != event.postId).toList();
        final updatedGroups = _groupPosts(updatedPosts);
        emit(state.copyWith(
          posts: updatedPosts,
          groups: updatedGroups,
          clearDeletingPostId: true,
          actionSuccessMessage: 'Média supprimé avec succès',
        ));
      },
    );
  }

  List<GroupedPosts> _groupPosts(List<Post> posts) {
    final videos = posts.where((p) => p.isVideo).toList();
    final images = posts.where((p) => p.isImage).toList();
    final others = posts.where((p) => !p.isVideo && !p.isImage).toList();

    final List<GroupedPosts> grouped = [];
    if (videos.isNotEmpty) {
      grouped.add(GroupedPosts(
        mediaType: 'Video',
        typeTitle: 'Vidéos & Reels',
        posts: videos,
      ));
    }
    if (images.isNotEmpty) {
      grouped.add(GroupedPosts(
        mediaType: 'Image',
        typeTitle: 'Images',
        posts: images,
      ));
    }
    if (others.isNotEmpty) {
      grouped.add(GroupedPosts(
        mediaType: 'Autre',
        typeTitle: 'Autres Médias',
        posts: others,
      ));
    }
    return grouped;
  }
}
