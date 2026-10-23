import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sub_category.dart';
import '../repositories/product_repository.dart';

class CreateSubCategoryParams {
  final String categoryId;
  final String title;

  const CreateSubCategoryParams({
    required this.categoryId,
    required this.title,
  });
}

class CreateSubCategoryUseCase {
  final ProductRepository repository;

  const CreateSubCategoryUseCase(this.repository);

  Future<Either<Failure, SubCategory>> call(CreateSubCategoryParams params) async {
    return await repository.createSubCategory(
      categoryId: params.categoryId,
      title: params.title,
    );
  }
}
