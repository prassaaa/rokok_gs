import 'package:equatable/equatable.dart';

import 'product.dart';
import 'user.dart';

/// Transaction status enum
enum TransactionStatus {
  pending,
  completed,
  cancelled,
}

/// Payment method enum
enum PaymentMethod {
  cash,
  transfer,
  credit,
}

/// Transaction item entity
class TransactionItem extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final Product? product;

  const TransactionItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.product,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        price,
        quantity,
        subtotal,
        product,
      ];
}

/// Transaction entity - domain layer
class Transaction extends Equatable {
  final int id;
  final String? invoiceNumber;
  final int salesId;
  final String? salesName;
  final int? areaId;
  final String? areaName;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final double? latitude;
  final double? longitude;
  final PaymentMethod? paymentMethod;
  final DateTime transactionDate;
  final List<TransactionItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final TransactionStatus status;
  final String? notes;
  final User? sales;
  final Area? area;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Transaction({
    required this.id,
    this.invoiceNumber,
    required this.salesId,
    this.salesName,
    this.areaId,
    this.areaName,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.latitude,
    this.longitude,
    this.paymentMethod,
    required this.transactionDate,
    this.items = const [],
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.status = TransactionStatus.completed,
    this.notes,
    this.sales,
    this.area,
    this.createdAt,
    this.updatedAt,
  });

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if has discount
  bool get hasDiscount => discount > 0;

  /// Get formatted total
  String get formattedTotal => 'Rp ${total.toStringAsFixed(0)}';

  /// Get formatted subtotal
  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';

  /// Get formatted discount
  String get formattedDiscount => 'Rp ${discount.toStringAsFixed(0)}';

  /// Get status text
  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        salesId,
        salesName,
        areaId,
        areaName,
        customerId,
        customerName,
        customerPhone,
        customerAddress,
        latitude,
        longitude,
        paymentMethod,
        transactionDate,
        items,
        subtotal,
        discount,
        tax,
        total,
        status,
        notes,
        sales,
        area,
        createdAt,
        updatedAt,
      ];
}

/// Create transaction item params
class CreateTransactionItemParams extends Equatable {
  final int productId;
  final int quantity;
  final double price;

  const CreateTransactionItemParams({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      };

  @override
  List<Object?> get props => [productId, quantity, price];
}

/// Create transaction params
class CreateTransactionParams extends Equatable {
  final int? areaId;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final double? latitude;
  final double? longitude;
  final PaymentMethod paymentMethod;
  final DateTime? transactionDate;
  final List<CreateTransactionItemParams> items;
  final double discount;
  final String? notes;

  const CreateTransactionParams({
    this.areaId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.latitude,
    this.longitude,
    required this.paymentMethod,
    this.transactionDate,
    required this.items,
    this.discount = 0,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        if (areaId != null) 'area_id': areaId,
        if (customerId != null) 'customer_id': customerId,
        if (customerName != null) 'customer_name': customerName,
        if (customerPhone != null) 'customer_phone': customerPhone,
        if (customerAddress != null) 'customer_address': customerAddress,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'payment_method': paymentMethod.name,
        if (transactionDate != null)
          'transaction_date': transactionDate!.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'discount': discount,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [
        areaId,
        customerId,
        customerName,
        customerPhone,
        customerAddress,
        latitude,
        longitude,
        paymentMethod,
        transactionDate,
        items,
        discount,
        notes,
      ];
}
