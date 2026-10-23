import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../product/domain/entities/upload_url_response.dart';
import '../repositories/post_repository.dart';

class GetPostUploadUrlUseCase {
  final PostRepository repository;

  GetPostUploadUrlUseCase(this.repository);

  Future<Either<Failure, UploadUrlResponse>> call({
    required String filename,
    String folder = 'posts',
  }) async {
    return await repository.getUploadUrl(filename: filename, folder: folder);
  }
}
