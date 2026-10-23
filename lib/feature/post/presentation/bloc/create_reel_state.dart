import 'dart:io';
import 'package:equatable/equatable.dart';

class CreateReelState extends Equatable {
  final File? videoFile;
  final String title;
  final String caption;
  final bool isSubmitting;
  final String? statusMessage;
  final bool isSuccess;
  final String? errorMessage;

  const CreateReelState({
    this.videoFile,
    this.title = '',
    this.caption = '',
    this.isSubmitting = false,
    this.statusMessage,
    this.isSuccess = false,
    this.errorMessage,
  });

  CreateReelState copyWith({
    File? videoFile,
    bool clearVideo = false,
    String? title,
    String? caption,
    bool? isSubmitting,
    String? statusMessage,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateReelState(
      videoFile: clearVideo ? null : (videoFile ?? this.videoFile),
      title: title ?? this.title,
      caption: caption ?? this.caption,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      statusMessage: statusMessage ?? this.statusMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        videoFile,
        title,
        caption,
        isSubmitting,
        statusMessage,
        isSuccess,
        errorMessage,
      ];
}
