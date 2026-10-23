import 'package:equatable/equatable.dart';

/// Represents a vendor product entity.
class Product extends Equatable {
  final String id;
  final String title;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final String? serviceId;
  final String? subCategoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.serviceId,
    this.subCategoryId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        imageUrl,
        isAvailable,
        serviceId,
        subCategoryId,
        createdAt,
        updatedAt,
      ];
}
