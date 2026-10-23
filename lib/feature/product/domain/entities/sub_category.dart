import 'package:equatable/equatable.dart';

/// Entity representing a sub-category under a vendor service category.
class SubCategory extends Equatable {
  final String id;
  final String title;

  const SubCategory({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
