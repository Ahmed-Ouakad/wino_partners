import 'package:equatable/equatable.dart';

/// Parameters for updating a vendor product.
class UpdateProductParams extends Equatable {
  final String productId;
  final String title;
  final double price;
  final String description;
  final String imageUrl;

  const UpdateProductParams({
    required this.productId,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [productId, title, price, description, imageUrl];
}
