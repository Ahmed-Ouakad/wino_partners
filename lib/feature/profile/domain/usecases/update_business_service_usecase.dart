import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UpdateBusinessServiceParams extends Equatable {
  final String serviceId;
  final String title;
  final String description;
  final String categoryId;

  const UpdateBusinessServiceParams({
    required this.serviceId,
    required this.title,
    required this.description,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [serviceId, title, description, categoryId];
}

class UpdateBusinessServiceUseCase {
  final ProfileRepository repository;

  const UpdateBusinessServiceUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateBusinessServiceParams params) async {
    return await repository.updateBusinessService(
      serviceId: params.serviceId,
      title: params.title,
      description: params.description,
      categoryId: params.categoryId,
    );
  }
}
