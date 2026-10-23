import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

class EditProductState extends Equatable {
  final Product? product;
  final String title;
  final String price;
  final String description;
  final File? newImageFile;
  final bool hasChanges;
  final bool isSaving;
  final bool isDeleting;
  final String? statusMessage;
  final bool saveSuccess;
  final bool deleteSuccess;
  final String? errorMessage;

  const EditProductState({
    this.product,
    this.title = '',
    this.price = '',
    this.description = '',
    this.newImageFile,
    this.hasChanges = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.statusMessage,
    this.saveSuccess = false,
    this.deleteSuccess = false,
    this.errorMessage,
  });

  EditProductState copyWith({
    Product? product,
    String? title,
    String? price,
    String? description,
    File? newImageFile,
    bool clearNewImage = false,
    bool? hasChanges,
    bool? isSaving,
    bool? isDeleting,
    String? statusMessage,
    bool? saveSuccess,
    bool? deleteSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EditProductState(
      product: product ?? this.product,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      newImageFile: clearNewImage ? null : (newImageFile ?? this.newImageFile),
      hasChanges: hasChanges ?? this.hasChanges,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      statusMessage: statusMessage ?? this.statusMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      deleteSuccess: deleteSuccess ?? this.deleteSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        product,
        title,
        price,
        description,
        newImageFile,
        hasChanges,
        isSaving,
        isDeleting,
        statusMessage,
        saveSuccess,
        deleteSuccess,
        errorMessage,
      ];
}
