import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_sub_categories.dart';
import '../repositories/product_repository.dart';

class GetSubCategoriesUseCase {
  final ProductRepository repository;

  const GetSubCategoriesUseCase(this.repository);

  Future<Either<Failure, ServiceSubCategories>> call(String serviceId) async {
    return await repository.getSubCategories(serviceId);
  }
}
