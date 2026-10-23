import '../../domain/entities/onboarding_params.dart';
import '../../domain/entities/service_category.dart';

/// Base event class for onboarding feature.
abstract class OnboardingEvent {
  const OnboardingEvent();
}

/// Event dispatched to load service categories from server.
class FetchServiceCategoriesEvent extends OnboardingEvent {
  const FetchServiceCategoriesEvent();
}

/// Event dispatched when a category is selected by the user.
class SelectServiceCategoryEvent extends OnboardingEvent {
  final ServiceCategory category;

  const SelectServiceCategoryEvent(this.category);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectServiceCategoryEvent &&
          runtimeType == other.runtimeType &&
          category == other.category;

  @override
  int get hashCode => category.hashCode;
}

/// Event dispatched when the onboarding form is submitted.
class SubmitOnboardingEvent extends OnboardingEvent {
  final OnboardingParams params;

  const SubmitOnboardingEvent(this.params);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitOnboardingEvent &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;
}
