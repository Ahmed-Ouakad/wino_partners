import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/caching_service.dart';
import '../../domain/entities/create_product_params.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/create_sub_category_usecase.dart';
import '../../domain/usecases/get_sub_categories_usecase.dart';
import '../../domain/usecases/get_upload_url_usecase.dart';
import '../../domain/usecases/upload_file_usecase.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final GetSubCategoriesUseCase getSubCategoriesUseCase;
  final CreateSubCategoryUseCase createSubCategoryUseCase;
  final GetUploadUrlUseCase getUploadUrlUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final CreateProductUseCase createProductUseCase;
  final CachingService cachingService;
  final ImagePicker imagePicker;

  AddProductBloc({
    required this.getSubCategoriesUseCase,
    required this.createSubCategoryUseCase,
    required this.getUploadUrlUseCase,
    required this.uploadFileUseCase,
    required this.createProductUseCase,
    required this.cachingService,
    ImagePicker? imagePicker,
  })  : imagePicker = imagePicker ?? ImagePicker(),
        super(const AddProductState()) {
    on<LoadSubCategoriesEvent>(_onLoadSubCategories);
    on<SubCategoryInputChangedEvent>(_onSubCategoryInputChanged);
    on<SelectSubCategoryEvent>(_onSelectSubCategory);
    on<PickImageEvent>(_onPickImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<SubmitProductEvent>(_onSubmitProduct);
  }

  Future<void> _onLoadSubCategories(
    LoadSubCategoriesEvent event,
    Emitter<AddProductState> emit,
  ) async {
    final serviceId = cachingService.getString(serviceIdKey);
    if (serviceId == null || serviceId.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingCategories: true));

    final result = await getSubCategoriesUseCase(serviceId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingCategories: false,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        isLoadingCategories: false,
        categoryId: data.categoryId,
        allSubCategories: data.subCategories,
        clearError: true,
      )),
    );
  }

  void _onSubCategoryInputChanged(
    SubCategoryInputChangedEvent event,
    Emitter<AddProductState> emit,
  ) {
    final query = event.query.trim().toLowerCase();
    if (query.isEmpty) {
      emit(state.copyWith(
        filteredSuggestions: [],
        clearSelectedSubCategory: true,
      ));
      return;
    }

    final filtered = state.allSubCategories.where((sub) {
      return sub.title.toLowerCase().contains(query);
    }).toList();

    final isExactMatch = state.selectedSubCategory != null &&
        state.selectedSubCategory!.title.toLowerCase() == query;

    emit(state.copyWith(
      filteredSuggestions: filtered,
      clearSelectedSubCategory: !isExactMatch,
    ));
  }

  void _onSelectSubCategory(
    SelectSubCategoryEvent event,
    Emitter<AddProductState> emit,
  ) {
    emit(state.copyWith(
      selectedSubCategory: event.subCategory,
      filteredSuggestions: [],
    ));
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<AddProductState> emit,
  ) async {
    try {
      final picked = await imagePicker.pickImage(
        source: event.source,
        imageQuality: 85,
      );

      if (picked != null) {
        emit(state.copyWith(
          pickedImage: File(picked.path),
          clearError: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Impossible de sélectionner l\'image: ${e.toString()}',
      ));
    }
  }

  void _onRemoveImage(
    RemoveImageEvent event,
    Emitter<AddProductState> emit,
  ) {
    emit(state.copyWith(clearPickedImage: true));
  }

  Future<void> _onSubmitProduct(
    SubmitProductEvent event,
    Emitter<AddProductState> emit,
  ) async {
    // 1. Validations
    final title = event.title.trim();
    if (title.isEmpty) {
      emit(state.copyWith(errorMessage: 'Veuillez saisir le titre du produit.'));
      return;
    }

    final priceCleaned = event.price.replaceAll(',', '.').trim();
    final price = double.tryParse(priceCleaned);
    if (price == null || price <= 0) {
      emit(state.copyWith(errorMessage: 'Veuillez saisir un prix valide supérieur à 0.'));
      return;
    }

    final subCategoryTitle = event.subCategoryInput.trim();
    if (subCategoryTitle.isEmpty) {
      emit(state.copyWith(errorMessage: 'Veuillez préciser la sous-catégorie du produit.'));
      return;
    }

    if (state.pickedImage == null) {
      emit(state.copyWith(errorMessage: 'Veuillez ajouter une photo pour le produit.'));
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      submissionStatus: 'Préparation du produit...',
      clearError: true,
    ));

    // 2. Resolve Sub-Category ID
    String subCategoryId = '';
    if (state.selectedSubCategory != null &&
        state.selectedSubCategory!.title.toLowerCase() == subCategoryTitle.toLowerCase()) {
      subCategoryId = state.selectedSubCategory!.id;
    } else {
      // Check if it matches an existing one in allSubCategories
      final existingIndex = state.allSubCategories.indexWhere(
        (s) => s.title.toLowerCase() == subCategoryTitle.toLowerCase(),
      );

      if (existingIndex != -1) {
        subCategoryId = state.allSubCategories[existingIndex].id;
      } else {
        // Create new sub-category
        if (state.categoryId == null || state.categoryId!.isEmpty) {
          emit(state.copyWith(
            isSubmitting: false,
            errorMessage: 'Identifiant de catégorie introuvable pour créer la sous-catégorie.',
          ));
          return;
        }

        emit(state.copyWith(submissionStatus: 'Création de la sous-catégorie...'));

        final createSubResult = await createSubCategoryUseCase(
          CreateSubCategoryParams(
            categoryId: state.categoryId!,
            title: subCategoryTitle,
          ),
        );

        final failureOrSub = createSubResult.fold((f) => f, (s) => s);
        if (createSubResult.isLeft()) {
          emit(state.copyWith(
            isSubmitting: false,
            errorMessage: failureOrSub.toString(),
          ));
          return;
        }

        subCategoryId = (failureOrSub as dynamic).id;
      }
    }

    // 3. Request Storage Upload URL
    emit(state.copyWith(submissionStatus: 'Génération du lien de téléversement...'));
    final file = state.pickedImage!;
    final filename = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'product_cover.jpg';

    final uploadUrlResult = await getUploadUrlUseCase(
      GetUploadUrlParams(filename: filename, folder: 'products'),
    );

    if (uploadUrlResult.isLeft()) {
      final failure = uploadUrlResult.swap().toOption().toNullable()!;
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ));
      return;
    }

    final uploadUrlData = uploadUrlResult.toOption().toNullable()!;

    // 4. Upload File to Storage
    emit(state.copyWith(submissionStatus: 'Téléversement de l\'image...'));
    final uploadResult = await uploadFileUseCase(
      UploadFileParams(
        uploadUrl: uploadUrlData.uploadUrl,
        token: uploadUrlData.token,
        file: file,
      ),
    );

    if (uploadResult.isLeft()) {
      final failure = uploadResult.swap().toOption().toNullable()!;
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ));
      return;
    }

    // 5. Create Product on Backend
    emit(state.copyWith(submissionStatus: 'Enregistrement du produit...'));
    final createProductResult = await createProductUseCase(
      CreateProductParams(
        title: title,
        price: price,
        subCategoryId: subCategoryId,
        description: event.description.trim(),
        imageUrl: uploadUrlData.publicUrl,
      ),
    );

    createProductResult.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      )),
    );
  }
}
