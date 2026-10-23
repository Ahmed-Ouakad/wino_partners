import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/post_repository.dart';

class DeletePostUseCase {
  final PostRepository repository;

  const DeletePostUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deletePost(id);
  }
}
