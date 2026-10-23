import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/create_post_params.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/get_post_upload_url_usecase.dart';
import '../../domain/usecases/upload_post_file_usecase.dart';
import 'create_reel_event.dart';
import 'create_reel_state.dart';

class CreateReelBloc extends Bloc<CreateReelEvent, CreateReelState> {
  final CreatePostUseCase createPostUseCase;
  final GetPostUploadUrlUseCase getUploadUrlUseCase;
  final UploadPostFileUseCase uploadFileUseCase;
  final ImagePicker imagePicker;

  CreateReelBloc({
    required this.createPostUseCase,
    required this.getUploadUrlUseCase,
    required this.uploadFileUseCase,
    ImagePicker? imagePicker,
  })  : imagePicker = imagePicker ?? ImagePicker(),
        super(const CreateReelState()) {
    on<InitReelEvent>(_onInit);
    on<PickVideoEvent>(_onPickVideo);
    on<RemoveVideoEvent>(_onRemoveVideo);
    on<ReelTitleChangedEvent>(_onTitleChanged);
    on<ReelCaptionChangedEvent>(_onCaptionChanged);
    on<SubmitReelEvent>(_onSubmitReel);
  }

  void _onInit(InitReelEvent event, Emitter<CreateReelState> emit) {
    emit(CreateReelState(
      videoFile: event.initialVideo,
      title: '',
      caption: '',
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
    ));
  }

  Future<void> _onPickVideo(PickVideoEvent event, Emitter<CreateReelState> emit) async {
    try {
      final picked = await imagePicker.pickVideo(
        source: event.source,
        maxDuration: const Duration(minutes: 3),
      );

      if (picked != null) {
        emit(state.copyWith(
          videoFile: File(picked.path),
          clearError: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Impossible de sélectionner la vidéo: ${e.toString()}',
      ));
    }
  }

  void _onRemoveVideo(RemoveVideoEvent event, Emitter<CreateReelState> emit) {
    emit(state.copyWith(clearVideo: true));
  }

  void _onTitleChanged(ReelTitleChangedEvent event, Emitter<CreateReelState> emit) {
    emit(state.copyWith(
      title: event.title,
      clearError: true,
    ));
  }

  void _onCaptionChanged(ReelCaptionChangedEvent event, Emitter<CreateReelState> emit) {
    emit(state.copyWith(
      caption: event.caption,
      clearError: true,
    ));
  }

  Future<void> _onSubmitReel(SubmitReelEvent event, Emitter<CreateReelState> emit) async {
    final video = state.videoFile;
    if (video == null) {
      emit(state.copyWith(
        errorMessage: 'Veuillez sélectionner une vidéo pour votre réel.',
      ));
      return;
    }

    final title = state.title.trim();
    if (title.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Veuillez renseigner un titre pour le réel.',
      ));
      return;
    }

    final caption = state.caption.trim();
    if (caption.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Veuillez ajouter une légende (caption) à votre réel.',
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      statusMessage: 'Génération du lien de téléversement...',
      clearError: true,
    ));

    final extension = video.path.split('.').last.toLowerCase();
    final filename = 'reel_${DateTime.now().millisecondsSinceEpoch}.$extension';

    // 1. Storage Upload URL
    final uploadUrlResult = await getUploadUrlUseCase(
      filename: filename,
      folder: 'posts',
    );

    final uploadResponse = uploadUrlResult.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: 'Erreur lors de la génération du lien: ${failure.message}',
        ));
        return null;
      },
      (data) => data,
    );

    if (uploadResponse == null) return;

    // 2. Put file to Supabase signed URL
    emit(state.copyWith(statusMessage: 'Téléversement de la vidéo en cours...'));

    final uploadFileResult = await uploadFileUseCase(
      uploadUrl: uploadResponse.uploadUrl,
      file: video,
      token: uploadResponse.token,
    );

    final uploadSuccess = uploadFileResult.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: 'Erreur lors du téléversement: ${failure.message}',
        ));
        return false;
      },
      (_) => true,
    );

    if (!uploadSuccess) return;

    // 3. Post to /v1/vendor/posts
    emit(state.copyWith(statusMessage: 'Publication du réel...'));

    final createResult = await createPostUseCase(
      CreatePostParams(
        mediaUrl: uploadResponse.publicUrl,
        title: title,
        caption: caption,
        mediaType: 'Video',
        isStory: false,
      ),
    );

    createResult.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      )),
    );
  }
}
