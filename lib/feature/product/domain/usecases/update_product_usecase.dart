import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/update_product_params.dart';
import '../repositories/product_repository.dart';

/// Use case to update an existing vendor product.
class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateProductParams params) async {
    return await repository.updateProduct(params);
  }
}
