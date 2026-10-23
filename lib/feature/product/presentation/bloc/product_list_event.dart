import 'package:equatable/equatable.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on initial screen mount or manual retry.
class LoadVendorProductsEvent extends ProductListEvent {
  const LoadVendorProductsEvent();
}

/// Fired during pull-to-refresh or after returning from AddProductScreen.
class RefreshVendorProductsEvent extends ProductListEvent {
  const RefreshVendorProductsEvent();
}
