import '../../domain/entities/stock.dart';
import '../../domain/entities/product.dart';
import 'product_model.dart';

/// Stock model with JSON serialization
class StockModel extends Stock {
  const StockModel({
    required super.id,
    required super.productId,
    required super.branchId,
    required super.quantity,
    super.minStock,
    super.lastUpdated,
    super.product,
    super.branchName,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: _parseInt(json['id']) ?? 0,
      productId: _parseInt(json['product_id']) ?? 0,
      branchId: _parseInt(json['branch_id']) ?? 0,
      quantity: _parseInt(json['quantity']) ?? 0,
      minStock: _parseInt(json['min_stock'] ?? json['minimum_stock']) ?? 10,
      lastUpdated: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      branchName: json['branch']?['name']?.toString() ?? json['branch_name']?.toString(),
    );
  }

  /// Safely parse int from dynamic value
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'branch_id': branchId,
        'quantity': quantity,
        'min_stock': minStock,
        if (lastUpdated != null) 'updated_at': lastUpdated!.toIso8601String(),
        if (branchName != null) 'branch_name': branchName,
      };

  factory StockModel.fromEntity(Stock stock) {
    return StockModel(
      id: stock.id,
      productId: stock.productId,
      branchId: stock.branchId,
      quantity: stock.quantity,
      minStock: stock.minStock,
      lastUpdated: stock.lastUpdated,
      product: stock.product,
      branchName: stock.branchName,
    );
  }

  StockModel copyWith({
    int? id,
    int? productId,
    int? branchId,
    int? quantity,
    int? minStock,
    DateTime? lastUpdated,
    Product? product,
    String? branchName,
  }) {
    return StockModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      branchId: branchId ?? this.branchId,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      product: product ?? this.product,
      branchName: branchName ?? this.branchName,
    );
  }
}

/// Stock history model with JSON serialization
class StockHistoryModel extends StockHistory {
  const StockHistoryModel({
    required super.id,
    required super.stockId,
    required super.quantityBefore,
    required super.quantityAfter,
    required super.quantityChange,
    required super.changeType,
    super.referenceType,
    super.referenceId,
    super.notes,
    required super.createdAt,
    super.createdBy,
  });

  factory StockHistoryModel.fromJson(Map<String, dynamic> json) {
    return StockHistoryModel(
      id: _parseIntRequired(json['id']),
      stockId: _parseIntRequired(json['stock_id']),
      quantityBefore: _parseIntRequired(json['quantity_before']),
      quantityAfter: _parseIntRequired(json['quantity_after']),
      quantityChange: _parseIntRequired(json['quantity_change']),
      changeType: StockChangeTypeX.fromString(
        json['change_type']?.toString() ?? 'adjustment',
      ),
      referenceType: json['reference_type']?.toString(),
      referenceId: _parseIntNullable(json['reference_id']),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdBy: json['created_by']?['name']?.toString() ?? json['created_by_name']?.toString(),
    );
  }

  static int _parseIntRequired(dynamic value) {
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'stock_id': stockId,
        'quantity_before': quantityBefore,
        'quantity_after': quantityAfter,
        'quantity_change': quantityChange,
        'change_type': changeType.value,
        if (referenceType != null) 'reference_type': referenceType,
        if (referenceId != null) 'reference_id': referenceId,
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toIso8601String(),
        if (createdBy != null) 'created_by_name': createdBy,
      };

  factory StockHistoryModel.fromEntity(StockHistory history) {
    return StockHistoryModel(
      id: history.id,
      stockId: history.stockId,
      quantityBefore: history.quantityBefore,
      quantityAfter: history.quantityAfter,
      quantityChange: history.quantityChange,
      changeType: history.changeType,
      referenceType: history.referenceType,
      referenceId: history.referenceId,
      notes: history.notes,
      createdAt: history.createdAt,
      createdBy: history.createdBy,
    );
  }
}
