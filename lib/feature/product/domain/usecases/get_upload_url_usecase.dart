import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/upload_url_response.dart';
import '../repositories/product_repository.dart';

class GetUploadUrlParams {
  final String filename;
  final String folder;

  const GetUploadUrlParams({
    required this.filename,
    this.folder = 'products',
  });
}

class GetUploadUrlUseCase {
  final ProductRepository repository;

  const GetUploadUrlUseCase(this.repository);

  Future<Either<Failure, UploadUrlResponse>> call(GetUploadUrlParams params) async {
    return await repository.getUploadUrl(
      filename: params.filename,
      folder: params.folder,
    );
  }
}
