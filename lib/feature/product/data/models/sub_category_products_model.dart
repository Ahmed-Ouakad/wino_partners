import '../../domain/entities/sub_category_products.dart';
import 'product_model.dart';

/// Data model for SubCategoryProducts with JSON serialization.
class SubCategoryProductsModel extends SubCategoryProducts {
  const SubCategoryProductsModel({
    required super.subCategoryId,
    required super.subCategoryTitle,
    required super.products,
  });

  factory SubCategoryProductsModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];
    final productsList = rawProducts
        .whereType<Map<String, dynamic>>()
        .map((p) => ProductModel.fromJson(p))
        .toList();

    return SubCategoryProductsModel(
      subCategoryId: json['sub_category_id'] as String? ?? '',
      subCategoryTitle: json['sub_category_title'] as String? ?? '',
      products: productsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_category_id': subCategoryId,
      'sub_category_title': subCategoryTitle,
      'products': products.map((p) {
        if (p is ProductModel) return p.toJson();
        return {
          'id': p.id,
          'title': p.title,
          'description': p.description,
          'price': p.price,
          'image_url': p.imageUrl,
          'is_available': p.isAvailable,
          'service_id': p.serviceId,
          'sub_category_id': p.subCategoryId,
        };
      }).toList(),
    };
  }
}
