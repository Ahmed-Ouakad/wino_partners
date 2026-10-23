import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/sub_category.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object?> get props => [];
}

/// Loads available sub-categories for the current vendor service.
class LoadSubCategoriesEvent extends AddProductEvent {
  const LoadSubCategoriesEvent();
}

/// Fired as user types into the sub-category text field.
class SubCategoryInputChangedEvent extends AddProductEvent {
  final String query;

  const SubCategoryInputChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Fired when user selects an existing sub-category suggestion.
class SelectSubCategoryEvent extends AddProductEvent {
  final SubCategory subCategory;

  const SelectSubCategoryEvent(this.subCategory);

  @override
  List<Object?> get props => [subCategory];
}

/// Fired to pick an image from gallery or camera.
class PickImageEvent extends AddProductEvent {
  final ImageSource source;

  const PickImageEvent(this.source);

  @override
  List<Object?> get props => [source];
}

/// Fired to clear the selected image.
class RemoveImageEvent extends AddProductEvent {
  const RemoveImageEvent();
}

/// Submits the product creation flow.
class SubmitProductEvent extends AddProductEvent {
  final String title;
  final String price;
  final String subCategoryInput;
  final String description;

  const SubmitProductEvent({
    required this.title,
    required this.price,
    required this.subCategoryInput,
    required this.description,
  });

  @override
  List<Object?> get props => [title, price, subCategoryInput, description];
}
