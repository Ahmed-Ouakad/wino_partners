import '../../domain/entities/upload_url_response.dart';

class UploadUrlModel extends UploadUrlResponse {
  const UploadUrlModel({
    required super.uploadUrl,
    required super.token,
    required super.path,
    required super.publicUrl,
  });

  factory UploadUrlModel.fromJson(Map<String, dynamic> json) {
    return UploadUrlModel(
      uploadUrl: (json['uploadUrl'] ?? json['upload_url'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
      publicUrl: (json['publicUrl'] ?? json['public_url'] ?? '').toString(),
    );
  }
}
