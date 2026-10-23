import 'package:equatable/equatable.dart';
import '../../domain/entities/sub_category_products.dart';

enum ProductListStatus { initial, loading, success, failure }

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<SubCategoryProducts> groups;
  final bool isRefreshing;
  final String? errorMessage;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.groups = const [],
    this.isRefreshing = false,
    this.errorMessage,
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<SubCategoryProducts>? groups,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductListState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, groups, isRefreshing, errorMessage];
}
