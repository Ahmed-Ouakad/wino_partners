import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_vendor_products_usecase.dart';
import 'product_list_event.dart';
import 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final GetVendorProductsUseCase getVendorProductsUseCase;

  ProductListBloc({
    required this.getVendorProductsUseCase,
  }) : super(const ProductListState()) {
    on<LoadVendorProductsEvent>(_onLoadVendorProducts);
    on<RefreshVendorProductsEvent>(_onRefreshVendorProducts);
  }

  Future<void> _onLoadVendorProducts(
    LoadVendorProductsEvent event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductListStatus.loading,
      clearError: true,
    ));

    final result = await getVendorProductsUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: failure.message,
      )),
      (groups) => emit(state.copyWith(
        status: ProductListStatus.success,
        groups: groups,
        clearError: true,
      )),
    );
  }

  Future<void> _onRefreshVendorProducts(
    RefreshVendorProductsEvent event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(
      isRefreshing: true,
      clearError: true,
    ));

    final result = await getVendorProductsUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isRefreshing: false,
        errorMessage: failure.message,
      )),
      (groups) => emit(state.copyWith(
        status: ProductListStatus.success,
        groups: groups,
        isRefreshing: false,
        clearError: true,
      )),
    );
  }
}
