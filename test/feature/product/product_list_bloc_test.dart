import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/feature/product/data/models/sub_category_products_model.dart';
import 'package:wino_partners/feature/product/domain/entities/create_product_params.dart';
import 'package:wino_partners/feature/product/domain/entities/product.dart';
import 'package:wino_partners/feature/product/domain/entities/service_sub_categories.dart';
import 'package:wino_partners/feature/product/domain/entities/sub_category.dart';
import 'package:wino_partners/feature/product/domain/entities/sub_category_products.dart';
import 'package:wino_partners/feature/product/domain/entities/update_product_params.dart';
import 'package:wino_partners/feature/product/domain/entities/upload_url_response.dart';
import 'package:wino_partners/feature/product/domain/repositories/product_repository.dart';
import 'package:wino_partners/feature/product/domain/usecases/get_vendor_products_usecase.dart';
import 'package:wino_partners/feature/product/presentation/bloc/product_list_bloc.dart';
import 'package:wino_partners/feature/product/presentation/bloc/product_list_event.dart';
import 'package:wino_partners/feature/product/presentation/bloc/product_list_state.dart';

class MockProductRepository implements ProductRepository {
  Either<Failure, List<SubCategoryProducts>> getVendorProductsResult = const Right([
    SubCategoryProducts(
      subCategoryId: 'sub-1',
      subCategoryTitle: 'Boissons & Épicerie',
      products: [
        Product(
          id: 'prod-1',
          title: 'lait frais 1L',
          description: 'lait frais 1L ViataLait',
          price: 1.35,
          imageUrl: 'https://example.com/lait.png',
          isAvailable: true,
        ),
      ],
    ),
    SubCategoryProducts(
      subCategoryId: 'sub-2',
      subCategoryTitle: 'loisirs',
      products: [
        Product(
          id: 'prod-2',
          title: 'ballon Kipsta',
          description: 'Ballon peau bleu kipsta',
          price: 15.0,
          imageUrl: 'https://example.com/ballon.png',
          isAvailable: true,
        ),
      ],
    ),
  ]);

  @override
  Future<Either<Failure, List<SubCategoryProducts>>> getVendorProducts() async {
    return getVendorProductsResult;
  }

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
  Future<Either<Failure, UploadUrlResponse>> getUploadUrl({
    required String filename,
    required String folder,
  }) async =>
      const Left(ServerFailure('unimplemented'));

  @override
  Future<Either<Failure, void>> uploadFile({
    required String uploadUrl,
    required String? token,
    required File file,
  }) async =>
      const Left(ServerFailure('unimplemented'));

  @override
  Future<Either<Failure, void>> createProduct(CreateProductParams params) async =>
      const Left(ServerFailure('unimplemented'));

  @override
  Future<Either<Failure, void>> updateProduct(UpdateProductParams params) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async =>
      const Right(null);
}

void main() {
  late MockProductRepository mockRepository;
  late GetVendorProductsUseCase useCase;
  late ProductListBloc bloc;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetVendorProductsUseCase(mockRepository);
    bloc = ProductListBloc(getVendorProductsUseCase: useCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('SubCategoryProductsModel', () {
    test('fromJson properly decodes json object and products', () {
      final json = {
        'sub_category_id': '9c7f41a9-7437-4fb9-bcd2-e8745614261d',
        'sub_category_title': 'Boissons & Épicerie',
        'products': [
          {
            'id': '4acff383-e55e-47dc-b6ed-db39a90fe9ed',
            'title': 'lait frais 1L',
            'description': 'lait frais 1L ViataLait',
            'price': 1.35,
            'image_url': 'https://example.com/img.jpg',
            'is_available': true,
            'service_id': '47a48316-9b42-4be8-938e-c300c55875ae',
            'sub_category_id': '9c7f41a9-7437-4fb9-bcd2-e8745614261d',
            'createdAt': '2026-10-22T08:55:07.662Z',
            'updatedAt': '2026-10-22T08:55:07.662Z',
          }
        ]
      };

      final model = SubCategoryProductsModel.fromJson(json);

      expect(model.subCategoryId, equals('9c7f41a9-7437-4fb9-bcd2-e8745614261d'));
      expect(model.subCategoryTitle, equals('Boissons & Épicerie'));
      expect(model.products.length, equals(1));
      expect(model.products.first.title, equals('lait frais 1L'));
      expect(model.products.first.price, equals(1.35));
    });

    test('toJson produces matching map', () {
      final model = SubCategoryProductsModel.fromJson({
        'sub_category_id': 'cat-1',
        'sub_category_title': 'Boissons',
        'products': [
          {
            'id': 'p1',
            'title': 'Jus',
            'price': 2.5,
          }
        ]
      });

      final json = model.toJson();
      expect(json['sub_category_id'], equals('cat-1'));
      expect((json['products'] as List).length, equals(1));
    });
  });

  group('ProductListBloc', () {
    test('initial state has empty groups and initial status', () {
      expect(bloc.state.status, equals(ProductListStatus.initial));
      expect(bloc.state.groups, isEmpty);
      expect(bloc.state.isRefreshing, isFalse);
    });

    test('LoadVendorProductsEvent emits loading then success with groups', () async {
      bloc.add(const LoadVendorProductsEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductListState>((s) => s.status == ProductListStatus.loading),
          predicate<ProductListState>((s) =>
              s.status == ProductListStatus.success &&
              s.groups.length == 2 &&
              s.groups.first.subCategoryTitle == 'Boissons & Épicerie'),
        ]),
      );
    });

    test('LoadVendorProductsEvent emits failure when repository returns error', () async {
      mockRepository.getVendorProductsResult =
          const Left(ServerFailure('Impossible de charger les produits'));

      bloc.add(const LoadVendorProductsEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductListState>((s) => s.status == ProductListStatus.loading),
          predicate<ProductListState>((s) =>
              s.status == ProductListStatus.failure &&
              s.errorMessage == 'Impossible de charger les produits'),
        ]),
      );
    });

    test('RefreshVendorProductsEvent emits isRefreshing then updates groups', () async {
      bloc.add(const RefreshVendorProductsEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProductListState>((s) => s.isRefreshing == true),
          predicate<ProductListState>((s) =>
              s.isRefreshing == false &&
              s.status == ProductListStatus.success &&
              s.groups.length == 2),
        ]),
      );
    });
  });
}
