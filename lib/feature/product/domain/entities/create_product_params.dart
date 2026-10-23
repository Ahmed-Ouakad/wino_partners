import 'package:equatable/equatable.dart';

/// Parameters for creating a vendor product.
class CreateProductParams extends Equatable {
  final String title;
  final double price;
  final String subCategoryId;
  final String description;
  final String imageUrl;

  const CreateProductParams({
    required this.title,
    required this.price,
    required this.subCategoryId,
    required this.description,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'sub_category_id': subCategoryId,
      'description': description,
      'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
        title,
        price,
        subCategoryId,
        description,
        imageUrl,
      ];
}
