import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/feature/product/domain/entities/create_product_params.dart';
import 'package:wino_partners/feature/product/domain/entities/product.dart';
import 'package:wino_partners/feature/product/domain/entities/service_sub_categories.dart';
import 'package:wino_partners/feature/product/domain/entities/sub_category.dart';
import 'package:wino_partners/feature/product/domain/entities/sub_category_products.dart';
import 'package:wino_partners/feature/product/domain/entities/update_product_params.dart';
import 'package:wino_partners/feature/product/domain/entities/upload_url_response.dart';
import 'package:wino_partners/feature/product/domain/repositories/product_repository.dart';
import 'package:wino_partners/feature/product/domain/usecases/delete_product_usecase.dart';
import 'package:wino_partners/feature/product/domain/usecases/get_upload_url_usecase.dart';
import 'package:wino_partners/feature/product/domain/usecases/update_product_usecase.dart';
import 'package:wino_partners/feature/product/domain/usecases/upload_file_usecase.dart';
import 'package:wino_partners/feature/product/presentation/bloc/edit_product_bloc.dart';
import 'package:wino_partners/feature/product/presentation/bloc/edit_product_event.dart';
import 'package:wino_partners/feature/product/presentation/bloc/edit_product_state.dart';

class MockProductRepository implements ProductRepository {
  Either<Failure, void> updateProductResult = const Right(null);
  Either<Failure, void> deleteProductResult = const Right(null);
  Either<Failure, UploadUrlResponse> getUploadUrlResult = const Right(
    UploadUrlResponse(
      uploadUrl: 'https://storage.supabase.co/upload/sign',
      token: 'jwt-token',
      path: 'products/updated.jpg',
      publicUrl: 'https://storage.supabase.co/public/products/updated.jpg',
    ),
  );
  Either<Failure, void> uploadFileResult = const Right(null);

  UpdateProductParams? capturedUpdateParams;
  String? capturedDeleteId;

  @override
  Future<Either<Failure, void>> updateProduct(UpdateProductParams params) async {
    capturedUpdateParams = params;
    return updateProductResult;
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    capturedDeleteId = productId;
    return deleteProductResult;
  }

  @override
  Future<Either<Failure, UploadUrlResponse>> getUploadUrl({
    required String filename,
    required String folder,
  }) async {
    return getUploadUrlResult;
  }

  @override
  Future<Either<Failure, void>> uploadFile({
    required String uploadUrl,
    required File file,
    String? token,
  }) async {
    return uploadFileResult;
  }

  @override
  Future<Either<Failure, List<SubCategoryProducts>>> getVendorProducts() async =>
      const Right([]);

  @override
  Future<Either<Failure, ServiceSubCategories>> getSubCategories(String serviceId) async =>
      const Left(ServerFailure('unimplemented'));

  @override
  Future<Either<Failure, SubCategory>> createSubCategory({
    required String categoryId,
    required String title,
  }) async =>
      const Left(ServerFailure('unimplemented'));

  @override
  Future<Either<Failure, void>> createProduct(CreateProductParams params) async =>
      const Left(ServerFailure('unimplemented'));
}

void main() {
  late MockProductRepository mockRepository;
  late EditProductBloc bloc;

  const initialProduct = Product(
    id: 'prod-123',
    title: 'Lait Frais 1L',
    price: 1.35,
    description: 'Bouteille 1L',
    imageUrl: 'https://example.com/lait.jpg',
  );

  setUp(() {
    mockRepository = MockProductRepository();
    bloc = EditProductBloc(
      updateProductUseCase: UpdateProductUseCase(mockRepository),
      deleteProductUseCase: DeleteProductUseCase(mockRepository),
      getUploadUrlUseCase: GetUploadUrlUseCase(mockRepository),
      uploadFileUseCase: UploadFileUseCase(mockRepository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('InitEditProductEvent populates initial values with hasChanges = false', () async {
    bloc.add(const InitEditProductEvent(initialProduct));

    await expectLater(
      bloc.stream,
      emits(
        predicate<EditProductState>((s) =>
            s.product == initialProduct &&
            s.title == 'Lait Frais 1L' &&
            s.price == '1.35' &&
            s.description == 'Bouteille 1L' &&
            s.hasChanges == false &&
            s.newImageFile == null),
      ),
    );
  });

  test('EditTitleChangedEvent sets hasChanges to true when modified', () async {
    bloc.add(const InitEditProductEvent(initialProduct));
    await bloc.stream.first;

    bloc.add(const EditTitleChangedEvent('Lait Demi-Écrémé'));

    await expectLater(
      bloc.stream,
      emits(
        predicate<EditProductState>((s) =>
            s.title == 'Lait Demi-Écrémé' && s.hasChanges == true),
      ),
    );
  });

  test('EditPriceChangedEvent sets hasChanges to true when price changes', () async {
    bloc.add(const InitEditProductEvent(initialProduct));
    await bloc.stream.first;

    bloc.add(const EditPriceChangedEvent('2.0'));

    await expectLater(
      bloc.stream,
      emits(
        predicate<EditProductState>((s) =>
            s.price == '2.0' && s.hasChanges == true),
      ),
    );
  });

  test('SubmitProductUpdateEvent calls updateProduct and emits saveSuccess without new image', () async {
    bloc.add(const InitEditProductEvent(initialProduct));
    await bloc.stream.first;

    bloc.add(const EditTitleChangedEvent('Lait Frais Bio 1L'));
    await bloc.stream.first;

    bloc.add(const SubmitProductUpdateEvent());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<EditProductState>((s) => s.isSaving == true),
        predicate<EditProductState>((s) => s.statusMessage == 'Enregistrement des modifications...'),
        predicate<EditProductState>((s) => s.isSaving == false && s.saveSuccess == true),
      ]),
    );

    expect(mockRepository.capturedUpdateParams?.productId, equals('prod-123'));
    expect(mockRepository.capturedUpdateParams?.title, equals('Lait Frais Bio 1L'));
    expect(mockRepository.capturedUpdateParams?.price, equals(1.35));
    expect(mockRepository.capturedUpdateParams?.imageUrl, equals('https://example.com/lait.jpg'));
  });

  test('SubmitProductUpdateEvent uploads image when newImageFile is present', () async {
    bloc.add(const InitEditProductEvent(initialProduct));
    await bloc.stream.first;

    final newImage = File('test_edit.jpg');
    bloc.add(EditImagePickedEvent(newImage));
    await bloc.stream.first;

    bloc.add(const SubmitProductUpdateEvent());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<EditProductState>((s) => s.isSaving == true),
        predicate<EditProductState>((s) => s.statusMessage == 'Génération du lien de téléversement...'),
        predicate<EditProductState>((s) => s.statusMessage == 'Téléversement de la photo...'),
        predicate<EditProductState>((s) => s.statusMessage == 'Enregistrement des modifications...'),
        predicate<EditProductState>((s) => s.isSaving == false && s.saveSuccess == true),
      ]),
    );

    expect(mockRepository.capturedUpdateParams?.imageUrl,
        equals('https://storage.supabase.co/public/products/updated.jpg'));
  });

  test('SubmitProductDeleteEvent calls deleteProduct and emits deleteSuccess', () async {
    bloc.add(const InitEditProductEvent(initialProduct));
    await bloc.stream.first;

    bloc.add(const SubmitProductDeleteEvent());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<EditProductState>((s) => s.isDeleting == true),
        predicate<EditProductState>((s) => s.isDeleting == false && s.deleteSuccess == true),
      ]),
    );

    expect(mockRepository.capturedDeleteId, equals('prod-123'));
  });
}
