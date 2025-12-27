import '../../domain/entities/transaction.dart';
import 'product_model.dart';
import 'user_model.dart';

/// Transaction status extension
extension TransactionStatusX on TransactionStatus {
  String get value {
    switch (this) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.cancelled:
        return 'cancelled';
    }
  }

  static String fromStatus(TransactionStatus status) {
    return status.value;
  }

  static TransactionStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'completed':
      default:
        return TransactionStatus.completed;
    }
  }
}

/// Transaction item model
class TransactionItemModel extends TransactionItem {
  const TransactionItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.price,
    required super.quantity,
    required super.subtotal,
    super.product,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? json['product']?['name'] ?? '',
      price: _parseDouble(json['price']),
      quantity: json['quantity'] ?? 0,
      subtotal: _parseDouble(json['subtotal']),
      product: json['product'] != null
          ? ProductModel.fromJson(json['product']).toEntity()
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  TransactionItem toEntity() => TransactionItem(
        id: id,
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity,
        subtotal: subtotal,
        product: product,
      );
}

/// Transaction model - data layer
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    super.invoiceNumber,
    required super.salesId,
    super.salesName,
    super.areaId,
    super.areaName,
    super.customerId,
    super.customerName,
    required super.transactionDate,
    super.items,
    required super.subtotal,
    super.discount,
    super.tax,
    required super.total,
    super.status,
    super.notes,
    super.sales,
    super.area,
    super.createdAt,
    super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'],
      salesId: json['sales_id'] ?? 0,
      salesName: json['sales_name'] ?? json['sales']?['name'],
      areaId: json['area_id'],
      areaName: json['area_name'] ?? json['area']?['name'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : DateTime.now(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => TransactionItemModel.fromJson(e).toEntity())
              .toList()
          : const [],
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      status: TransactionStatusX.fromString(json['status']),
      notes: json['notes'],
      sales: json['sales'] != null
          ? UserModel.fromJson(json['sales']).toEntity()
          : null,
      area: json['area'] != null
          ? AreaModel.fromJson(json['area']).toEntity()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'sales_id': salesId,
      'sales_name': salesName,
      'area_id': areaId,
      'area_name': areaName,
      'customer_id': customerId,
      'customer_name': customerName,
      'transaction_date': transactionDate.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'status': status.value,
      'notes': notes,
    };
  }

  Transaction toEntity() => Transaction(
        id: id,
        invoiceNumber: invoiceNumber,
        salesId: salesId,
        salesName: salesName,
        areaId: areaId,
        areaName: areaName,
        customerId: customerId,
        customerName: customerName,
        transactionDate: transactionDate,
        items: items,
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        total: total,
        status: status,
        notes: notes,
        sales: sales,
        area: area,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
