import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/create_product_params.dart';
import '../entities/service_sub_categories.dart';
import '../entities/sub_category.dart';
import '../entities/sub_category_products.dart';
import '../entities/update_product_params.dart';
import '../entities/upload_url_response.dart';

/// Contract for product catalog and media management operations.
abstract class ProductRepository {
  /// Fetches sub-categories and root category ID for a given service.
  Future<Either<Failure, ServiceSubCategories>> getSubCategories(String serviceId);

  /// Creates a new sub-category under a parent category ID.
  Future<Either<Failure, SubCategory>> createSubCategory({
    required String categoryId,
    required String title,
  });

  /// Requests a signed upload URL from the storage service.
  Future<Either<Failure, UploadUrlResponse>> getUploadUrl({
    required String filename,
    required String folder,
  });

  /// Uploads binary file bytes directly to the signed upload URL.
  Future<Either<Failure, void>> uploadFile({
    required String uploadUrl,
    required String? token,
    required File file,
  });

  /// Creates the final product record on the backend.
  Future<Either<Failure, void>> createProduct(CreateProductParams params);

  /// Fetches all vendor products grouped by sub-categories.
  Future<Either<Failure, List<SubCategoryProducts>>> getVendorProducts();

  /// Updates an existing vendor product by ID.
  Future<Either<Failure, void>> updateProduct(UpdateProductParams params);

  /// Deletes a vendor product by ID.
  Future<Either<Failure, void>> deleteProduct(String productId);
}
