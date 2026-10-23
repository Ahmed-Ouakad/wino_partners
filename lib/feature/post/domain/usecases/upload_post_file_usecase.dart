import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/post_repository.dart';

class UploadPostFileUseCase {
  final PostRepository repository;

  UploadPostFileUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String uploadUrl,
    required File file,
    String? token,
  }) async {
    return await repository.uploadFile(
      uploadUrl: uploadUrl,
      token: token,
      file: file,
    );
  }
}
