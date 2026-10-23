import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/core/services/caching_service.dart';
import 'package:wino_partners/feature/product/domain/entities/create_product_params.dart';
import 'package:wino_partners/feature/product/domain/entities/service_sub_categories.dart';
import 'package:wino_partners/feature/product/domain/entities/sub_category.dart';
import 'package:wino_partners/feature/product/domain/entities/sub_category_products.dart';
import 'package:wino_partners/feature/product/domain/entities/update_product_params.dart';
import 'package:wino_partners/feature/product/domain/entities/upload_url_response.dart';
import 'package:wino_partners/feature/product/domain/repositories/product_repository.dart';
import 'package:wino_partners/feature/product/domain/usecases/create_product_usecase.dart';
import 'package:wino_partners/feature/product/domain/usecases/create_sub_category_usecase.dart';
import 'package:wino_partners/feature/product/domain/usecases/get_sub_categories_usecase.dart';
import 'package:wino_partners/feature/product/domain/usecases/get_upload_url_usecase.dart';
import 'package:wino_partners/feature/product/domain/usecases/upload_file_usecase.dart';
import 'package:wino_partners/feature/product/presentation/bloc/add_product_bloc.dart';
import 'package:wino_partners/feature/product/presentation/bloc/add_product_event.dart';
import 'package:wino_partners/feature/product/presentation/bloc/add_product_state.dart';

class MockCachingService implements CachingService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> clear() async => _storage.clear();

  @override
  double? getDouble(String key) => _storage[key] as double?;

  @override
  String? getString(String key) => _storage[key] as String?;

  @override
  Future<void> remove(String key) async => _storage.remove(key);

  @override
  Future<void> saveDouble(String key, double value) async => _storage[key] = value;

  @override
  Future<void> saveString(String key, String value) async => _storage[key] = value;
}

class MockProductRepository implements ProductRepository {
  Either<Failure, ServiceSubCategories> getSubCategoriesResult = const Right(
    ServiceSubCategories(
      categoryId: 'cat-123',
      subCategories: [
        SubCategory(id: 'sub-1', title: 'Boissons & Épicerie'),
        SubCategory(id: 'sub-2', title: 'Fruits & Légumes'),
      ],
    ),
  );

  Either<Failure, SubCategory> createSubCategoryResult = const Right(
    SubCategory(id: 'sub-new', title: 'Nouveau Produit'),
  );

  Either<Failure, UploadUrlResponse> getUploadUrlResult = const Right(
    UploadUrlResponse(
      uploadUrl: 'https://storage.supabase.co/upload/sign',
      token: 'jwt-token',
      path: 'products/img.jpg',
      publicUrl: 'https://storage.supabase.co/public/products/img.jpg',
    ),
  );

  Either<Failure, void> uploadFileResult = const Right(null);
  Either<Failure, void> createProductResult = const Right(null);

  String? capturedCategoryId;
  String? capturedNewSubCategoryTitle;
  CreateProductParams? capturedProductParams;

  @override
  Future<Either<Failure, ServiceSubCategories>> getSubCategories(String serviceId) async {
    return getSubCategoriesResult;
  }

  @override
  Future<Either<Failure, SubCategory>> createSubCategory({
    required String categoryId,
    required String title,
  }) async {
    capturedCategoryId = categoryId;
    capturedNewSubCategoryTitle = title;
    return createSubCategoryResult;
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
  Future<Either<Failure, void>> createProduct(CreateProductParams params) async {
    capturedProductParams = params;
    return createProductResult;
  }

  @override
  Future<Either<Failure, List<SubCategoryProducts>>> getVendorProducts() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> updateProduct(UpdateProductParams params) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    return const Right(null);
  }
}

void main() {
  late MockCachingService mockCachingService;
  late MockProductRepository mockRepository;
  late AddProductBloc bloc;

  setUp(() {
    mockCachingService = MockCachingService();
    mockRepository = MockProductRepository();

    mockCachingService.saveString(serviceIdKey, 'service-uuid-456');

    bloc = AddProductBloc(
      getSubCategoriesUseCase: GetSubCategoriesUseCase(mockRepository),
      createSubCategoryUseCase: CreateSubCategoryUseCase(mockRepository),
      getUploadUrlUseCase: GetUploadUrlUseCase(mockRepository),
      uploadFileUseCase: UploadFileUseCase(mockRepository),
      createProductUseCase: CreateProductUseCase(mockRepository),
      cachingService: mockCachingService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state has default values', () {
    expect(bloc.state.isSubmitting, isFalse);
    expect(bloc.state.isSuccess, isFalse);
    expect(bloc.state.pickedImage, isNull);
    expect(bloc.state.categoryId, isNull);
    expect(bloc.state.allSubCategories, isEmpty);
  });

  test('LoadSubCategoriesEvent loads and populates subcategories', () async {
    bloc.add(const LoadSubCategoriesEvent());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<AddProductState>((s) => s.isLoadingCategories == true),
        predicate<AddProductState>((s) =>
            s.isLoadingCategories == false &&
            s.categoryId == 'cat-123' &&
            s.allSubCategories.length == 2 &&
            s.filteredSuggestions.isEmpty),
      ]),
    );
  });

  test('SubCategoryInputChangedEvent filters suggestions based on query', () async {
    bloc.add(const LoadSubCategoriesEvent());
    await bloc.stream.firstWhere((s) => !s.isLoadingCategories);

    bloc.add(const SubCategoryInputChangedEvent('Fruits'));

    await expectLater(
      bloc.stream,
      emits(
        predicate<AddProductState>((s) =>
            s.filteredSuggestions.length == 1 &&
            s.filteredSuggestions.first.title == 'Fruits & Légumes'),
      ),
    );
  });

  test('SelectSubCategoryEvent selects a category and matches existing one', () async {
    const selected = SubCategory(id: 'sub-1', title: 'Boissons & Épicerie');
    bloc.add(const SelectSubCategoryEvent(selected));

    await expectLater(
      bloc.stream,
      emits(
        predicate<AddProductState>((s) =>
            s.selectedSubCategory == selected &&
            s.filteredSuggestions.isEmpty),
      ),
    );
  });

  test('SubmitProductEvent with new subcategory creates subcategory first, uploads image, then creates product', () async {
    // 1. First load sub-categories so categoryId is known
    bloc.add(const LoadSubCategoriesEvent());
    await bloc.stream.firstWhere((s) => s.categoryId != null);

    // 2. Set an image
    final tempFile = File('test_product.jpg');
    bloc.emit(bloc.state.copyWith(pickedImage: tempFile));

    // 3. Submit with brand new sub-category title
    bloc.add(const SubmitProductEvent(
      title: 'Eau Minérale',
      price: '1.5',
      subCategoryInput: 'Nouvelle Catégorie Inconnue',
      description: 'Bouteille 1.5L',
    ));

    // Wait for completion (isSuccess == true)
    await bloc.stream.firstWhere((s) => s.isSuccess);

    expect(mockRepository.capturedCategoryId, equals('cat-123'));
    expect(mockRepository.capturedNewSubCategoryTitle, equals('Nouvelle Catégorie Inconnue'));
    expect(mockRepository.capturedProductParams?.title, equals('Eau Minérale'));
    expect(mockRepository.capturedProductParams?.price, equals(1.5));
    expect(mockRepository.capturedProductParams?.subCategoryId, equals('sub-new'));
    expect(mockRepository.capturedProductParams?.imageUrl, equals('https://storage.supabase.co/public/products/img.jpg'));
  });

  test('SubmitProductEvent validates missing image and emits failure', () async {
    bloc.add(const SubmitProductEvent(
      title: 'Eau Minérale',
      price: '1.5',
      subCategoryInput: 'Fruits & Légumes',
      description: 'Fraises',
    ));

    await expectLater(
      bloc.stream,
      emits(
        predicate<AddProductState>((s) =>
            s.isSubmitting == false &&
            s.errorMessage == 'Veuillez ajouter une photo pour le produit.'),
      ),
    );
  });

  test('SubmitProductEvent validates invalid price format', () async {
    final tempFile = File('test_product.jpg');
    bloc.emit(bloc.state.copyWith(pickedImage: tempFile));

    bloc.add(const SubmitProductEvent(
      title: 'Eau Minérale',
      price: 'abc',
      subCategoryInput: 'Fruits & Légumes',
      description: 'Fraises',
    ));

    await expectLater(
      bloc.stream,
      emits(
        predicate<AddProductState>((s) =>
            s.isSubmitting == false &&
            s.errorMessage == 'Veuillez saisir un prix valide supérieur à 0.'),
      ),
    );
  });
}
