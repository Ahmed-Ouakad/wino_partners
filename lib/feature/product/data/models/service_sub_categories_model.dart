import '../../domain/entities/service_sub_categories.dart';
import 'sub_category_model.dart';

class ServiceSubCategoriesModel extends ServiceSubCategories {
  const ServiceSubCategoriesModel({
    required super.categoryId,
    required super.subCategories,
  });

  factory ServiceSubCategoriesModel.fromJson(Map<String, dynamic> json) {
    final categoryId = (json['category_id'] ?? json['categoryId'] ?? '').toString();
    final rawList = json['sub_categories'] ?? json['subCategories'] ?? [];

    final List<SubCategoryModel> subCategories = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          subCategories.add(SubCategoryModel.fromJson(item));
        }
      }
    }

    return ServiceSubCategoriesModel(
      categoryId: categoryId,
      subCategories: subCategories,
    );
  }
}
