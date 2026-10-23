import '../../domain/entities/sub_category.dart';

class SubCategoryModel extends SubCategory {
  const SubCategoryModel({
    required super.id,
    required super.title,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
