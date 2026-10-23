import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_product_params.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  const CreateProductUseCase(this.repository);

  Future<Either<Failure, void>> call(CreateProductParams params) async {
    return await repository.createProduct(params);
  }
}
