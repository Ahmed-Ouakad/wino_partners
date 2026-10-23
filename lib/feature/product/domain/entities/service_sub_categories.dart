import 'package:equatable/equatable.dart';
import 'sub_category.dart';

/// Entity representing sub-categories associated with a service, including the root category ID.
class ServiceSubCategories extends Equatable {
  final String categoryId;
  final List<SubCategory> subCategories;

  const ServiceSubCategories({
    required this.categoryId,
    required this.subCategories,
  });

  @override
  List<Object?> get props => [categoryId, subCategories];
}
