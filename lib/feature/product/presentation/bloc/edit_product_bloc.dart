import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/update_product_params.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_upload_url_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/upload_file_usecase.dart';
import 'edit_product_event.dart';
import 'edit_product_state.dart';

class EditProductBloc extends Bloc<EditProductEvent, EditProductState> {
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final GetUploadUrlUseCase getUploadUrlUseCase;
  final UploadFileUseCase uploadFileUseCase;

  EditProductBloc({
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.getUploadUrlUseCase,
    required this.uploadFileUseCase,
  }) : super(const EditProductState()) {
    on<InitEditProductEvent>(_onInit);
    on<EditTitleChangedEvent>(_onTitleChanged);
    on<EditPriceChangedEvent>(_onPriceChanged);
    on<EditDescriptionChangedEvent>(_onDescriptionChanged);
    on<EditImagePickedEvent>(_onImagePicked);
    on<SubmitProductUpdateEvent>(_onSubmitUpdate);
    on<SubmitProductDeleteEvent>(_onSubmitDelete);
  }

  void _onInit(InitEditProductEvent event, Emitter<EditProductState> emit) {
    final product = event.product;
    final priceStr = product.price.truncateToDouble() == product.price
        ? product.price.toInt().toString()
        : product.price.toString();

    emit(EditProductState(
      product: product,
      title: product.title,
      price: priceStr,
      description: product.description ?? '',
      newImageFile: null,
      hasChanges: false,
      isSaving: false,
      isDeleting: false,
      saveSuccess: false,
      deleteSuccess: false,
      errorMessage: null,
    ));
  }

  bool _computeHasChanges({
    required Product original,
    required String title,
    required String price,
    required String description,
    required File? newImage,
  }) {
    if (newImage != null) return true;
    if (title.trim() != original.title.trim()) return true;

    final parsedPrice = double.tryParse(price.trim());
    if (parsedPrice != null && parsedPrice != original.price) return true;

    if (description.trim() != (original.description ?? '').trim()) return true;

    return false;
  }

  void _onTitleChanged(EditTitleChangedEvent event, Emitter<EditProductState> emit) {
    if (state.product == null) return;
    final hasChanges = _computeHasChanges(
      original: state.product!,
      title: event.title,
      price: state.price,
      description: state.description,
      newImage: state.newImageFile,
    );
    emit(state.copyWith(
      title: event.title,
      hasChanges: hasChanges,
      clearError: true,
    ));
  }

  void _onPriceChanged(EditPriceChangedEvent event, Emitter<EditProductState> emit) {
    if (state.product == null) return;
    final hasChanges = _computeHasChanges(
      original: state.product!,
      title: state.title,
      price: event.price,
      description: state.description,
      newImage: state.newImageFile,
    );
    emit(state.copyWith(
      price: event.price,
      hasChanges: hasChanges,
      clearError: true,
    ));
  }

  void _onDescriptionChanged(
      EditDescriptionChangedEvent event, Emitter<EditProductState> emit) {
    if (state.product == null) return;
    final hasChanges = _computeHasChanges(
      original: state.product!,
      title: state.title,
      price: state.price,
      description: event.description,
      newImage: state.newImageFile,
    );
    emit(state.copyWith(
      description: event.description,
      hasChanges: hasChanges,
      clearError: true,
    ));
  }

  void _onImagePicked(EditImagePickedEvent event, Emitter<EditProductState> emit) {
    if (state.product == null) return;
    emit(state.copyWith(
      newImageFile: event.imageFile,
      hasChanges: true,
      clearError: true,
    ));
  }

  Future<void> _onSubmitUpdate(
    SubmitProductUpdateEvent event,
    Emitter<EditProductState> emit,
  ) async {
    final product = state.product;
    if (product == null) return;

    final cleanTitle = state.title.trim();
    if (cleanTitle.isEmpty) {
      emit(state.copyWith(errorMessage: 'Veuillez renseigner le nom du produit.'));
      return;
    }

    final parsedPrice = double.tryParse(state.price.trim().replaceAll(',', '.'));
    if (parsedPrice == null || parsedPrice <= 0) {
      emit(state.copyWith(errorMessage: 'Veuillez saisir un prix valide supérieur à 0.'));
      return;
    }

    emit(state.copyWith(
      isSaving: true,
      statusMessage: 'Préparation de la mise à jour...',
      clearError: true,
    ));

    String finalImageUrl = product.imageUrl ?? '';

    // If the user selected a new image, upload it first to Supabase
    if (state.newImageFile != null) {
      emit(state.copyWith(statusMessage: 'Génération du lien de téléversement...'));

      final extension = state.newImageFile!.path.split('.').last.toLowerCase();
      final filename = 'product_edit_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final uploadUrlResult = await getUploadUrlUseCase(
        GetUploadUrlParams(
          filename: filename,
          folder: 'products',
        ),
      );

      final uploadUrlSuccess = uploadUrlResult.fold(
        (failure) {
          emit(state.copyWith(
            isSaving: false,
            errorMessage: 'Erreur lors de la préparation de l\'image: ${failure.message}',
          ));
          return null;
        },
        (uploadResponse) => uploadResponse,
      );

      if (uploadUrlSuccess == null) return;

      emit(state.copyWith(statusMessage: 'Téléversement de la photo...'));

      final uploadFileResult = await uploadFileUseCase(
        UploadFileParams(
          uploadUrl: uploadUrlSuccess.uploadUrl,
          file: state.newImageFile!,
          token: uploadUrlSuccess.token,
        ),
      );

      final uploadFileSuccess = uploadFileResult.fold(
        (failure) {
          emit(state.copyWith(
            isSaving: false,
            errorMessage: 'Erreur lors de l\'envoi de l\'image: ${failure.message}',
          ));
          return false;
        },
        (_) => true,
      );

      if (!uploadFileSuccess) return;

      finalImageUrl = uploadUrlSuccess.publicUrl;
    }

    emit(state.copyWith(statusMessage: 'Enregistrement des modifications...'));

    final updateResult = await updateProductUseCase(
      UpdateProductParams(
        productId: product.id,
        title: cleanTitle,
        price: parsedPrice,
        description: state.description.trim(),
        imageUrl: finalImageUrl,
      ),
    );

    updateResult.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isSaving: false,
        saveSuccess: true,
        hasChanges: false,
      )),
    );
  }

  Future<void> _onSubmitDelete(
    SubmitProductDeleteEvent event,
    Emitter<EditProductState> emit,
  ) async {
    final product = state.product;
    if (product == null) return;

    emit(state.copyWith(
      isDeleting: true,
      statusMessage: 'Suppression du produit en cours...',
      clearError: true,
    ));

    final result = await deleteProductUseCase(product.id);

    result.fold(
      (failure) => emit(state.copyWith(
        isDeleting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isDeleting: false,
        deleteSuccess: true,
      )),
    );
  }
}
