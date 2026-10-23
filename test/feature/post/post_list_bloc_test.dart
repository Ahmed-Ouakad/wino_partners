import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/feature/post/data/models/post_model.dart';
import 'package:wino_partners/feature/post/domain/entities/create_post_params.dart';
import 'package:wino_partners/feature/post/domain/entities/post.dart';
import 'package:wino_partners/feature/post/domain/repositories/post_repository.dart';
import 'package:wino_partners/feature/post/domain/usecases/delete_post_usecase.dart';
import 'package:wino_partners/feature/post/domain/usecases/get_vendor_posts_usecase.dart';
import 'package:wino_partners/feature/post/presentation/bloc/post_list_bloc.dart';
import 'package:wino_partners/feature/post/presentation/bloc/post_list_event.dart';
import 'package:wino_partners/feature/post/presentation/bloc/post_list_state.dart';
import 'package:wino_partners/feature/product/domain/entities/upload_url_response.dart';
import 'dart:io';

class MockPostRepository implements PostRepository {
  Either<Failure, List<Post>> getVendorPostsResult = const Right([]);
  Either<Failure, void> deletePostResult = const Right(null);
  String? capturedDeletedId;

  @override
  Future<Either<Failure, List<Post>>> getVendorPosts() async {
    return getVendorPostsResult;
  }

  @override
  Future<Either<Failure, void>> deletePost(String id) async {
    capturedDeletedId = id;
    return deletePostResult;
  }

  @override
  Future<Either<Failure, void>> createPost(CreatePostParams params) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, UploadUrlResponse>> getUploadUrl({
    required String filename,
    required String folder,
  }) async {
    return const Right(
      UploadUrlResponse(
        uploadUrl: 'https://storage.supabase.co/upload/sign',
        token: 'token',
        path: 'posts/test.mp4',
        publicUrl: 'https://xyz.supabase.co/storage/v1/object/public/wino-media/posts/test.mp4',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> uploadFile({
    required String uploadUrl,
    required String? token,
    required File file,
  }) async {
    return const Right(null);
  }
}

void main() {
  late MockPostRepository mockRepository;
  late GetVendorPostsUseCase getVendorPostsUseCase;
  late DeletePostUseCase deletePostUseCase;
  late PostListBloc bloc;

  final samplePostJson = {
    'id': 'eb924c57-4a3c-4945-9b6e-cc1d0df4113a',
    'title': 'Emborg milk is finally here',
    'caption': 'taste this delicious milk at our store',
    'media_url': 'https://bzvjjcxssqppwpumkrsh.supabase.co/storage/v1/object/public/wino-media/posts/reel.mp4',
    'media_type': 'Video',
    'is_story': false,
    'expires_at': null,
    'user_id': 'fb0ee2a0-99fa-4e2a-9709-97af6fd6291a',
    'product_id': null,
    'views_count': 42,
    'createdAt': '2026-10-22T15:54:16.899Z',
    'updatedAt': '2026-10-22T15:54:16.899Z',
    'product': null,
    'viewsCount': 42,
  };

  final testVideoPost = PostModel.fromJson(samplePostJson);

  final testImagePost = PostModel(
    id: 'image-1',
    title: 'Image Showcase',
    caption: 'Great discount image',
    mediaUrl: 'https://xyz.supabase.co/storage/image.png',
    mediaType: 'Image',
    isStory: false,
    viewsCount: 15,
    createdAt: DateTime.parse('2026-10-22T16:00:00.000Z'),
  );

  setUp(() {
    mockRepository = MockPostRepository();
    getVendorPostsUseCase = GetVendorPostsUseCase(mockRepository);
    deletePostUseCase = DeletePostUseCase(mockRepository);
    bloc = PostListBloc(
      getVendorPostsUseCase: getVendorPostsUseCase,
      deletePostUseCase: deletePostUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('PostModel Deserialization', () {
    test('should correctly deserialize sample vendor post json', () {
      final model = PostModel.fromJson(samplePostJson);

      expect(model.id, 'eb924c57-4a3c-4945-9b6e-cc1d0df4113a');
      expect(model.title, 'Emborg milk is finally here');
      expect(model.caption, 'taste this delicious milk at our store');
      expect(model.mediaUrl, 'https://bzvjjcxssqppwpumkrsh.supabase.co/storage/v1/object/public/wino-media/posts/reel.mp4');
      expect(model.mediaType, 'Video');
      expect(model.isVideo, isTrue);
      expect(model.isImage, isFalse);
      expect(model.isStory, isFalse);
      expect(model.viewsCount, 42);
      expect(model.createdAt, isNotNull);
    });

    test('toJson produces valid map representation', () {
      final map = testVideoPost.toJson();
      expect(map['id'], testVideoPost.id);
      expect(map['title'], testVideoPost.title);
      expect(map['media_type'], 'Video');
    });
  });

  group('PostListBloc', () {
    test('initial state has empty posts and groups', () {
      expect(bloc.state.status, PostListStatus.initial);
      expect(bloc.state.posts, isEmpty);
      expect(bloc.state.groups, isEmpty);
      expect(bloc.state.isRefreshing, isFalse);
      expect(bloc.state.deletingPostId, isNull);
    });

    test('emits [loading, success] with grouped items on successful LoadVendorPostsEvent', () async {
      mockRepository.getVendorPostsResult = Right([testVideoPost, testImagePost]);

      expectLater(
        bloc.stream,
        emitsInOrder([
          const PostListState(status: PostListStatus.loading),
          predicate<PostListState>((s) {
            return s.status == PostListStatus.success &&
                s.posts.length == 2 &&
                s.groups.length == 2 &&
                s.groups[0].mediaType == 'Video' &&
                s.groups[0].posts.first.id == testVideoPost.id &&
                s.groups[1].mediaType == 'Image' &&
                s.groups[1].posts.first.id == testImagePost.id;
          }),
        ]),
      );

      bloc.add(const LoadVendorPostsEvent());
    });

    test('emits [loading, failure] on failed LoadVendorPostsEvent', () async {
      mockRepository.getVendorPostsResult = const Left(ServerFailure('Erreur serveur'));

      expectLater(
        bloc.stream,
        emitsInOrder([
          const PostListState(status: PostListStatus.loading),
          predicate<PostListState>((s) {
            return s.status == PostListStatus.failure &&
                s.errorMessage == 'Erreur serveur';
          }),
        ]),
      );

      bloc.add(const LoadVendorPostsEvent());
    });

    test('emits [isRefreshing: true, success with isRefreshing: false] on RefreshVendorPostsEvent', () async {
      mockRepository.getVendorPostsResult = Right([testVideoPost]);

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PostListState>((s) => s.isRefreshing == true),
          predicate<PostListState>((s) {
            return s.status == PostListStatus.success &&
                s.isRefreshing == false &&
                s.groups.length == 1 &&
                s.groups[0].mediaType == 'Video';
          }),
        ]),
      );

      bloc.add(const RefreshVendorPostsEvent());
    });

    test('emits updated posts without deleted post on DeletePostEvent', () async {
      // First prime the bloc with two posts
      mockRepository.getVendorPostsResult = Right([testVideoPost, testImagePost]);
      bloc.add(const LoadVendorPostsEvent());
      await pumpEventQueue();

      mockRepository.deletePostResult = const Right(null);

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PostListState>((s) => s.deletingPostId == testVideoPost.id),
          predicate<PostListState>((s) {
            return s.posts.length == 1 &&
                s.posts.first.id == testImagePost.id &&
                s.groups.length == 1 &&
                s.groups.first.mediaType == 'Image' &&
                s.deletingPostId == null &&
                s.actionSuccessMessage == 'Média supprimé avec succès';
          }),
        ]),
      );

      bloc.add(DeletePostEvent(testVideoPost.id));
      await pumpEventQueue();

      expect(mockRepository.capturedDeletedId, testVideoPost.id);
    });

    test('emits failure message and clears deletingPostId on failed DeletePostEvent', () async {
      mockRepository.getVendorPostsResult = Right([testVideoPost]);
      bloc.add(const LoadVendorPostsEvent());
      await pumpEventQueue();

      mockRepository.deletePostResult = const Left(ServerFailure('Erreur suppression'));

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PostListState>((s) => s.deletingPostId == testVideoPost.id),
          predicate<PostListState>((s) {
            return s.deletingPostId == null &&
                s.errorMessage == 'Erreur suppression' &&
                s.posts.length == 1;
          }),
        ]),
      );

      bloc.add(DeletePostEvent(testVideoPost.id));
    });
  });
}
