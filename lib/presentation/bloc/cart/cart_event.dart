import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

/// Cart events for transaction form
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Add product to cart
class AddToCart extends CartEvent {
  final Product product;
  final int quantity;
  final double? customPrice;

  const AddToCart({
    required this.product,
    this.quantity = 1,
    this.customPrice,
  });

  @override
  List<Object?> get props => [product, quantity, customPrice];
}

/// Remove product from cart
class RemoveFromCart extends CartEvent {
  final int productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Update cart item quantity
class UpdateCartItemQuantity extends CartEvent {
  final int productId;
  final int quantity;

  const UpdateCartItemQuantity({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

/// Increment cart item
class IncrementCartItem extends CartEvent {
  final int productId;

  const IncrementCartItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Decrement cart item
class DecrementCartItem extends CartEvent {
  final int productId;

  const DecrementCartItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Update customer info
class UpdateCustomerInfo extends CartEvent {
  final int? customerId;
  final String? customerName;

  const UpdateCustomerInfo({
    this.customerId,
    this.customerName,
  });

  @override
  List<Object?> get props => [customerId, customerName];
}

/// Update area
class UpdateCartArea extends CartEvent {
  final int? areaId;

  const UpdateCartArea(this.areaId);

  @override
  List<Object?> get props => [areaId];
}

/// Update discount
class UpdateDiscount extends CartEvent {
  final double discount;

  const UpdateDiscount(this.discount);

  @override
  List<Object?> get props => [discount];
}

/// Update notes
class UpdateNotes extends CartEvent {
  final String? notes;

  const UpdateNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Clear cart
class ClearCart extends CartEvent {
  const ClearCart();
}

/// Submit transaction
class SubmitTransaction extends CartEvent {
  const SubmitTransaction();
}
