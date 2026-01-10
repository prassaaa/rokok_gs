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

/// Payment method extension
extension PaymentMethodX on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.transfer:
        return 'transfer';
      case PaymentMethod.credit:
        return 'credit';
    }
  }

  static PaymentMethod fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'transfer':
        return PaymentMethod.transfer;
      case 'credit':
        return PaymentMethod.credit;
      case 'cash':
      default:
        return PaymentMethod.cash;
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
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      productName: json['product_name'] ?? json['product']?['name'] ?? '',
      price: _parseDouble(json['price']),
      quantity: _parseInt(json['quantity']),
      subtotal: _parseDouble(json['subtotal']),
      product: json['product'] != null
          ? ProductModel.fromJson(json['product']).toEntity()
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
    super.customerPhone,
    super.customerAddress,
    super.latitude,
    super.longitude,
    super.paymentMethod,
    required super.transactionDate,
    super.items,
    required super.subtotal,
    super.discount,
    super.tax,
    required super.total,
    super.status,
    super.notes,
    super.proofPhoto,
    super.sales,
    super.area,
    super.createdAt,
    super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: _parseInt(json['id']),
      invoiceNumber: json['invoice_number'],
      salesId: _parseInt(json['sales_id']),
      salesName: json['sales_name'] ?? json['sales']?['name'],
      areaId: _parseIntNullable(json['area_id']),
      areaName: json['area_name'] ?? json['area']?['name'],
      customerId: _parseIntNullable(json['customer_id']),
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      latitude: _parseDoubleNullable(json['latitude']),
      longitude: _parseDoubleNullable(json['longitude']),
      paymentMethod: json['payment_method'] != null
          ? PaymentMethodX.fromString(json['payment_method'])
          : null,
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
      proofPhoto: json['proof_photo'],
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

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'latitude': latitude,
      'longitude': longitude,
      'payment_method': paymentMethod?.value,
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
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        latitude: latitude,
        longitude: longitude,
        paymentMethod: paymentMethod,
        transactionDate: transactionDate,
        items: items,
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        total: total,
        status: status,
        notes: notes,
        proofPhoto: proofPhoto,
        sales: sales,
        area: area,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
