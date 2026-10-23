import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class CreateReelEvent extends Equatable {
  const CreateReelEvent();

  @override
  List<Object?> get props => [];
}

class InitReelEvent extends CreateReelEvent {
  final File? initialVideo;

  const InitReelEvent({this.initialVideo});

  @override
  List<Object?> get props => [initialVideo];
}

class PickVideoEvent extends CreateReelEvent {
  final ImageSource source;

  const PickVideoEvent(this.source);

  @override
  List<Object?> get props => [source];
}

class RemoveVideoEvent extends CreateReelEvent {
  const RemoveVideoEvent();
}

class ReelTitleChangedEvent extends CreateReelEvent {
  final String title;

  const ReelTitleChangedEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class ReelCaptionChangedEvent extends CreateReelEvent {
  final String caption;

  const ReelCaptionChangedEvent(this.caption);

  @override
  List<Object?> get props => [caption];
}

class SubmitReelEvent extends CreateReelEvent {
  const SubmitReelEvent();
}
