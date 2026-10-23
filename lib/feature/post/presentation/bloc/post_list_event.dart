import 'package:equatable/equatable.dart';

abstract class PostListEvent extends Equatable {
  const PostListEvent();

  @override
  List<Object?> get props => [];
}

class LoadVendorPostsEvent extends PostListEvent {
  const LoadVendorPostsEvent();
}

class RefreshVendorPostsEvent extends PostListEvent {
  const RefreshVendorPostsEvent();
}

class DeletePostEvent extends PostListEvent {
  final String postId;

  const DeletePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}
