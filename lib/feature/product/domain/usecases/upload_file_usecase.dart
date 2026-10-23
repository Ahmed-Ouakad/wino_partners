import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class UploadFileParams {
  final String uploadUrl;
  final String? token;
  final File file;

  const UploadFileParams({
    required this.uploadUrl,
    this.token,
    required this.file,
  });
}

class UploadFileUseCase {
  final ProductRepository repository;

  const UploadFileUseCase(this.repository);

  Future<Either<Failure, void>> call(UploadFileParams params) async {
    return await repository.uploadFile(
      uploadUrl: params.uploadUrl,
      token: params.token,
      file: params.file,
    );
  }
}
