/// Parameters and domain entity representing vendor onboarding details.
class OnboardingParams {
  final String categoryId;
  final String categoryTitle;
  final String description;

  const OnboardingParams({
    required this.categoryId,
    required this.categoryTitle,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingParams &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryTitle == other.categoryTitle &&
          description == other.description;

  @override
  int get hashCode =>
      categoryId.hashCode ^ categoryTitle.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'OnboardingParams(categoryId: $categoryId, categoryTitle: $categoryTitle, description: $description)';
  }
}
