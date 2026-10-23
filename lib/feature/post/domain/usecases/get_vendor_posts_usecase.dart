import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetVendorPostsUseCase {
  final PostRepository repository;

  const GetVendorPostsUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call() async {
    return await repository.getVendorPosts();
  }
}
