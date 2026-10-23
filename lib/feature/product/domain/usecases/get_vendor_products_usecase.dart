import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sub_category_products.dart';
import '../repositories/product_repository.dart';

/// Use case to fetch vendor products grouped by sub-categories.
class GetVendorProductsUseCase {
  final ProductRepository repository;

  GetVendorProductsUseCase(this.repository);

  Future<Either<Failure, List<SubCategoryProducts>>> call() async {
    return await repository.getVendorProducts();
  }
}
