import '../../domain/entities/service_category.dart';

/// Data model representing a service category, extending [ServiceCategory].
class ServiceCategoryModel extends ServiceCategory {
  const ServiceCategoryModel({
    required super.id,
    required super.title,
    super.subCategories,
  });

  /// Factory constructor to parse JSON data into [ServiceCategoryModel].
  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedSubCategories = [];
    final rawSubCats = json['sub_categories'] ?? json['subCategories'];
    if (rawSubCats is List) {
      parsedSubCategories = rawSubCats.map((item) {
        if (item is Map<String, dynamic>) {
          return item['title']?.toString() ?? item['name']?.toString() ?? '';
        }
        return item.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    return ServiceCategoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      subCategories: parsedSubCategories,
    );
  }

  /// Converts this model into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sub_categories': subCategories,
    };
  }
}
