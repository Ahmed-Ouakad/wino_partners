import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sub_category.dart';

class AddProductState extends Equatable {
  final String? categoryId;
  final List<SubCategory> allSubCategories;
  final List<SubCategory> filteredSuggestions;
  final SubCategory? selectedSubCategory;
  final File? pickedImage;
  final bool isLoadingCategories;
  final bool isSubmitting;
  final String? submissionStatus; // e.g. "Téléversement de l'image...", etc.
  final bool isSuccess;
  final String? errorMessage;

  const AddProductState({
    this.categoryId,
    this.allSubCategories = const [],
    this.filteredSuggestions = const [],
    this.selectedSubCategory,
    this.pickedImage,
    this.isLoadingCategories = false,
    this.isSubmitting = false,
    this.submissionStatus,
    this.isSuccess = false,
    this.errorMessage,
  });

  AddProductState copyWith({
    String? categoryId,
    List<SubCategory>? allSubCategories,
    List<SubCategory>? filteredSuggestions,
    SubCategory? selectedSubCategory,
    bool clearSelectedSubCategory = false,
    File? pickedImage,
    bool clearPickedImage = false,
    bool? isLoadingCategories,
    bool? isSubmitting,
    String? submissionStatus,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddProductState(
      categoryId: categoryId ?? this.categoryId,
      allSubCategories: allSubCategories ?? this.allSubCategories,
      filteredSuggestions: filteredSuggestions ?? this.filteredSuggestions,
      selectedSubCategory: clearSelectedSubCategory
          ? null
          : (selectedSubCategory ?? this.selectedSubCategory),
      pickedImage: clearPickedImage ? null : (pickedImage ?? this.pickedImage),
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        allSubCategories,
        filteredSuggestions,
        selectedSubCategory,
        pickedImage,
        isLoadingCategories,
        isSubmitting,
        submissionStatus,
        isSuccess,
        errorMessage,
      ];
}
