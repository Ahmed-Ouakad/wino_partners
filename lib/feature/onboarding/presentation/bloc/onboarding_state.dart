import '../../domain/entities/service_category.dart';

enum OnboardingStatus {
  initial,
  categoriesLoading,
  categoriesLoaded,
  submitting,
  success,
  failure,
}

/// State representation for the onboarding feature.
class OnboardingState {
  final OnboardingStatus status;
  final List<ServiceCategory> categories;
  final ServiceCategory? selectedCategory;
  final String? errorMessage;

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.categories = const [],
    this.selectedCategory,
    this.errorMessage,
  });

  bool get isCategoriesLoading => status == OnboardingStatus.categoriesLoading;
  bool get isSubmitting => status == OnboardingStatus.submitting;
  bool get isSuccess => status == OnboardingStatus.success;
  bool get isFailure => status == OnboardingStatus.failure;

  OnboardingState copyWith({
    OnboardingStatus? status,
    List<ServiceCategory>? categories,
    ServiceCategory? selectedCategory,
    String? errorMessage,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          categories == other.categories &&
          selectedCategory == other.selectedCategory &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^
      categories.hashCode ^
      selectedCategory.hashCode ^
      errorMessage.hashCode;
}
