import 'package:equatable/equatable.dart';
import 'product.dart';

/// Represents a group of products belonging to a specific sub-category.
class SubCategoryProducts extends Equatable {
  final String subCategoryId;
  final String subCategoryTitle;
  final List<Product> products;

  const SubCategoryProducts({
    required this.subCategoryId,
    required this.subCategoryTitle,
    required this.products,
  });

  @override
  List<Object?> get props => [subCategoryId, subCategoryTitle, products];
}
