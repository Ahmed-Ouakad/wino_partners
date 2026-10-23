import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/feature/post/domain/entities/create_post_params.dart';
import 'package:wino_partners/feature/post/domain/entities/post.dart';
import 'package:wino_partners/feature/post/domain/repositories/post_repository.dart';
import 'package:wino_partners/feature/post/domain/usecases/create_post_usecase.dart';
import 'package:wino_partners/feature/post/domain/usecases/get_post_upload_url_usecase.dart';
import 'package:wino_partners/feature/post/domain/usecases/upload_post_file_usecase.dart';
import 'package:wino_partners/feature/post/presentation/bloc/create_reel_bloc.dart';
import 'package:wino_partners/feature/post/presentation/bloc/create_reel_event.dart';
import 'package:wino_partners/feature/post/presentation/bloc/create_reel_state.dart';
import 'package:wino_partners/feature/product/domain/entities/upload_url_response.dart';

class MockPostRepository implements PostRepository {
  Either<Failure, UploadUrlResponse> getUploadUrlResult = const Right(
    UploadUrlResponse(
      uploadUrl: 'https://storage.supabase.co/upload/sign',
      token: 'jwt-token',
      path: 'posts/fade.mp4',
      publicUrl: 'https://xyz.supabase.co/storage/v1/object/public/wino-media/posts/fade.mp4',
    ),
  );

  Either<Failure, void> uploadFileResult = const Right(null);
  Either<Failure, void> createPostResult = const Right(null);
  Either<Failure, List<Post>> getVendorPostsResult = const Right([]);

  CreatePostParams? capturedPostParams;

  @override
  Future<Either<Failure, UploadUrlResponse>> getUploadUrl({
    required String filename,
    required String folder,
  }) async {
    return getUploadUrlResult;
  }

  @override
  Future<Either<Failure, void>> uploadFile({
    required String uploadUrl,
    required String? token,
    required File file,
  }) async {
    return uploadFileResult;
  }

  @override
  Future<Either<Failure, void>> createPost(CreatePostParams params) async {
    capturedPostParams = params;
    return createPostResult;
  }

  @override
  Future<Either<Failure, List<Post>>> getVendorPosts() async {
    return getVendorPostsResult;
  }

  @override
  Future<Either<Failure, void>> deletePost(String id) async {
    return const Right(null);
  }
}

void main() {
  late MockPostRepository mockRepository;
  late CreateReelBloc bloc;

  final testVideo = File('test_video.mp4');

  setUp(() {
    mockRepository = MockPostRepository();
    bloc = CreateReelBloc(
      createPostUseCase: CreatePostUseCase(mockRepository),
      getUploadUrlUseCase: GetPostUploadUrlUseCase(mockRepository),
      uploadFileUseCase: UploadPostFileUseCase(mockRepository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state has empty fields and not submitting', () {
    expect(bloc.state.videoFile, isNull);
    expect(bloc.state.title, isEmpty);
    expect(bloc.state.caption, isEmpty);
    expect(bloc.state.isSubmitting, isFalse);
    expect(bloc.state.isSuccess, isFalse);
  });

  test('InitReelEvent sets initial video file', () async {
    bloc.add(InitReelEvent(initialVideo: testVideo));

    await expectLater(
      bloc.stream,
      emits(
        predicate<CreateReelState>((s) => s.videoFile == testVideo),
      ),
    );
  });

  test('ReelTitleChangedEvent and ReelCaptionChangedEvent update fields', () async {
    bloc.add(const ReelTitleChangedEvent('Dégradé classique'));
    await expectLater(
      bloc.stream,
      emits(predicate<CreateReelState>((s) => s.title == 'Dégradé classique')),
    );

    bloc.add(const ReelCaptionChangedEvent('Coupe homme moderne'));
    await expectLater(
      bloc.stream,
      emits(predicate<CreateReelState>((s) => s.caption == 'Coupe homme moderne')),
    );
  });

  test('SubmitReelEvent validates missing video file', () async {
    bloc.add(const ReelTitleChangedEvent('Titre'));
    await bloc.stream.first;
    bloc.add(const ReelCaptionChangedEvent('Légende'));
    await bloc.stream.first;

    bloc.add(const SubmitReelEvent());

    await expectLater(
      bloc.stream,
      emits(
        predicate<CreateReelState>((s) =>
            s.isSubmitting == false &&
            s.errorMessage == 'Veuillez sélectionner une vidéo pour votre réel.'),
      ),
    );
  });

  test('SubmitReelEvent validates missing title', () async {
    bloc.add(InitReelEvent(initialVideo: testVideo));
    await bloc.stream.first;
    bloc.add(const ReelCaptionChangedEvent('Légende'));
    await bloc.stream.first;

    bloc.add(const SubmitReelEvent());

    await expectLater(
      bloc.stream,
      emits(
        predicate<CreateReelState>((s) =>
            s.isSubmitting == false &&
            s.errorMessage == 'Veuillez renseigner un titre pour le réel.'),
      ),
    );
  });

  test('SubmitReelEvent validates missing caption', () async {
    bloc.add(InitReelEvent(initialVideo: testVideo));
    await bloc.stream.first;
    bloc.add(const ReelTitleChangedEvent('Titre'));
    await bloc.stream.first;

    bloc.add(const SubmitReelEvent());

    await expectLater(
      bloc.stream,
      emits(
        predicate<CreateReelState>((s) =>
            s.isSubmitting == false &&
            s.errorMessage == 'Veuillez ajouter une légende (caption) à votre réel.'),
      ),
    );
  });

  test('SubmitReelEvent executes full upload and post creation pipeline successfully', () async {
    bloc.add(InitReelEvent(initialVideo: testVideo));
    await bloc.stream.first;
    bloc.add(const ReelTitleChangedEvent('Special fade haircut showcase'));
    await bloc.stream.first;
    bloc.add(const ReelCaptionChangedEvent('Check out our classic low fade styling, now available at the shop.'));
    await bloc.stream.first;

    bloc.add(const SubmitReelEvent());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<CreateReelState>((s) => s.isSubmitting == true),
        predicate<CreateReelState>((s) => s.statusMessage == 'Téléversement de la vidéo en cours...'),
        predicate<CreateReelState>((s) => s.statusMessage == 'Publication du réel...'),
        predicate<CreateReelState>((s) => s.isSubmitting == false && s.isSuccess == true),
      ]),
    );

    expect(mockRepository.capturedPostParams?.title, equals('Special fade haircut showcase'));
    expect(mockRepository.capturedPostParams?.caption,
        equals('Check out our classic low fade styling, now available at the shop.'));
    expect(mockRepository.capturedPostParams?.mediaUrl,
        equals('https://xyz.supabase.co/storage/v1/object/public/wino-media/posts/fade.mp4'));
    expect(mockRepository.capturedPostParams?.mediaType, equals('Video'));
    expect(mockRepository.capturedPostParams?.isStory, isFalse);
  });
}
