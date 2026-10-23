import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_post_params.dart';
import '../repositories/post_repository.dart';

/// Use case to create a vendor post.
class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<Either<Failure, void>> call(CreatePostParams params) async {
    return await repository.createPost(params);
  }
}
