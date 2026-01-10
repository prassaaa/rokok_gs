import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/transaction.dart';

/// Cart item for form
class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double price;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get subtotal => price * quantity;

  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';
  String get formattedPrice => 'Rp ${price.toStringAsFixed(0)}';

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? price,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  CreateTransactionItemParams toTransactionItemParams() {
    return CreateTransactionItemParams(
      productId: product.id,
      quantity: quantity,
      price: price,
    );
  }

  @override
  List<Object?> get props => [product, quantity, price];
}

/// Cart states
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial cart state
class CartInitial extends CartState {
  const CartInitial();
}

/// Cart with items
class CartActive extends CartState {
  final List<CartItem> items;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final double? latitude;
  final double? longitude;
  final PaymentMethod? paymentMethod;
  final int? areaId;
  final double discount;
  final String? notes;
  final bool isSubmitting;
  final String? error;

  const CartActive({
    this.items = const [],
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.latitude,
    this.longitude,
    this.paymentMethod,
    this.areaId,
    this.discount = 0,
    this.notes,
    this.isSubmitting = false,
    this.error,
  });

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal before discount
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Total after discount
  double get total => subtotal - discount;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Check if can submit (has payment method and customer name)
  bool get canSubmit => isNotEmpty && paymentMethod != null && customerName != null && customerName!.isNotEmpty;

  /// Get formatted subtotal
  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';

  /// Get formatted discount
  String get formattedDiscount => 'Rp ${discount.toStringAsFixed(0)}';

  /// Get formatted total
  String get formattedTotal => 'Rp ${total.toStringAsFixed(0)}';

  /// Check if item exists in cart
  bool containsProduct(int productId) {
    return items.any((item) => item.product.id == productId);
  }

  /// Get item by product ID
  CartItem? getItem(int productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Get quantity for product
  int getQuantity(int productId) {
    return getItem(productId)?.quantity ?? 0;
  }

  CartActive copyWith({
    List<CartItem>? items,
    int? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    double? latitude,
    double? longitude,
    PaymentMethod? paymentMethod,
    int? areaId,
    double? discount,
    String? notes,
    bool? isSubmitting,
    String? error,
    bool clearCustomerId = false,
    bool clearCustomerName = false,
    bool clearCustomerPhone = false,
    bool clearCustomerAddress = false,
    bool clearLocation = false,
    bool clearPaymentMethod = false,
    bool clearAreaId = false,
    bool clearNotes = false,
    bool clearError = false,
  }) {
    return CartActive(
      items: items ?? this.items,
      customerId: clearCustomerId ? null : customerId ?? this.customerId,
      customerName:
          clearCustomerName ? null : customerName ?? this.customerName,
      customerPhone:
          clearCustomerPhone ? null : customerPhone ?? this.customerPhone,
      customerAddress:
          clearCustomerAddress ? null : customerAddress ?? this.customerAddress,
      latitude: clearLocation ? null : latitude ?? this.latitude,
      longitude: clearLocation ? null : longitude ?? this.longitude,
      paymentMethod:
          clearPaymentMethod ? null : paymentMethod ?? this.paymentMethod,
      areaId: clearAreaId ? null : areaId ?? this.areaId,
      discount: discount ?? this.discount,
      notes: clearNotes ? null : notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
    );
  }

  /// Convert to CreateTransactionParams
  CreateTransactionParams toTransactionParams() {
    return CreateTransactionParams(
      areaId: areaId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      latitude: latitude,
      longitude: longitude,
      paymentMethod: paymentMethod ?? PaymentMethod.cash,
      items: items.map((e) => e.toTransactionItemParams()).toList(),
      subtotal: subtotal,
      discount: discount,
      total: total,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [
        items,
        customerId,
        customerName,
        customerPhone,
        customerAddress,
        latitude,
        longitude,
        paymentMethod,
        areaId,
        discount,
        notes,
        isSubmitting,
        error,
      ];
}

/// Transaction submitted successfully
class CartSubmitted extends CartState {
  final Transaction transaction;

  const CartSubmitted(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Cart submission error
class CartSubmissionError extends CartState {
  final String message;
  final CartActive previousState;

  const CartSubmissionError({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
