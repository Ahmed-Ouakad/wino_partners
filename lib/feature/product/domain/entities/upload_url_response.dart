import 'package:equatable/equatable.dart';

/// Entity representing the signed upload URL response from the backend.
class UploadUrlResponse extends Equatable {
  final String uploadUrl;
  final String token;
  final String path;
  final String publicUrl;

  const UploadUrlResponse({
    required this.uploadUrl,
    required this.token,
    required this.path,
    required this.publicUrl,
  });

  @override
  List<Object?> get props => [uploadUrl, token, path, publicUrl];
}
