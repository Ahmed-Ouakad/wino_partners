import '../../domain/entities/product.dart';

/// Data model for vendor product with JSON serialization.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    super.description,
    required super.price,
    super.imageUrl,
    super.isAvailable = true,
    super.serviceId,
    super.subCategoryId,
    super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      serviceId: json['service_id'] as String?,
      subCategoryId: json['sub_category_id'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'price': price,
      if (imageUrl != null) 'image_url': imageUrl,
      'is_available': isAvailable,
      if (serviceId != null) 'service_id': serviceId,
      if (subCategoryId != null) 'sub_category_id': subCategoryId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
