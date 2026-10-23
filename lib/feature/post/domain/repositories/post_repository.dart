import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../product/domain/entities/upload_url_response.dart';
import '../entities/create_post_params.dart';
import '../entities/post.dart';

/// Contract for vendor media post operations (Reels & Stories).
abstract class PostRepository {
  /// Requests a signed upload URL from storage service.
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

  /// Creates a new vendor post (Reel or Story).
  Future<Either<Failure, void>> createPost(CreatePostParams params);

  /// Retrieves all posts (Reels, Videos, Images) created by this vendor.
  Future<Either<Failure, List<Post>>> getVendorPosts();

  /// Deletes a vendor post by ID.
  Future<Either<Failure, void>> deletePost(String id);
}
