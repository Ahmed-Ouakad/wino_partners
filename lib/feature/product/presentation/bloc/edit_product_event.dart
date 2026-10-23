import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class EditProductEvent extends Equatable {
  const EditProductEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes the edit screen with an existing product.
class InitEditProductEvent extends EditProductEvent {
  final Product product;

  const InitEditProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class EditTitleChangedEvent extends EditProductEvent {
  final String title;

  const EditTitleChangedEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class EditPriceChangedEvent extends EditProductEvent {
  final String price;

  const EditPriceChangedEvent(this.price);

  @override
  List<Object?> get props => [price];
}

class EditDescriptionChangedEvent extends EditProductEvent {
  final String description;

  const EditDescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class EditImagePickedEvent extends EditProductEvent {
  final File imageFile;

  const EditImagePickedEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class SubmitProductUpdateEvent extends EditProductEvent {
  const SubmitProductUpdateEvent();
}

class SubmitProductDeleteEvent extends EditProductEvent {
  const SubmitProductDeleteEvent();
}
