import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_service_categories_usecase.dart';
import '../../domain/usecases/submit_onboarding_usecase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// BLoC handling business logic and state transitions for the Onboarding screen.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetServiceCategoriesUseCase getServiceCategoriesUseCase;
  final SubmitOnboardingUseCase submitOnboardingUseCase;

  OnboardingBloc({
    required this.getServiceCategoriesUseCase,
    required this.submitOnboardingUseCase,
  }) : super(const OnboardingState()) {
    on<FetchServiceCategoriesEvent>(_onFetchServiceCategories);
    on<SelectServiceCategoryEvent>(_onSelectServiceCategory);
    on<SubmitOnboardingEvent>(_onSubmitOnboarding);
  }

  Future<void> _onFetchServiceCategories(
    FetchServiceCategoriesEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(
      status: OnboardingStatus.categoriesLoading,
      errorMessage: null,
    ));

    final result = await getServiceCategoriesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: failure.message,
      )),
      (categories) => emit(state.copyWith(
        status: OnboardingStatus.categoriesLoaded,
        categories: categories,
        errorMessage: null,
      )),
    );
  }

  void _onSelectServiceCategory(
    SelectServiceCategoryEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      selectedCategory: event.category,
    ));
  }

  Future<void> _onSubmitOnboarding(
    SubmitOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(
      status: OnboardingStatus.submitting,
      errorMessage: null,
    ));

    final result = await submitOnboardingUseCase(event.params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: OnboardingStatus.success,
        errorMessage: null,
      )),
    );
  }
}
