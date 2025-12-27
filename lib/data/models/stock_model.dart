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
      id: json['id'] as int,
      productId: json['product_id'] as int,
      branchId: json['branch_id'] as int,
      quantity: json['quantity'] as int? ?? 0,
      minStock: json['min_stock'] as int? ?? 10,
      lastUpdated: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      branchName: json['branch']?['name'] as String? ?? json['branch_name'] as String?,
    );
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
      id: json['id'] as int,
      stockId: json['stock_id'] as int,
      quantityBefore: json['quantity_before'] as int? ?? 0,
      quantityAfter: json['quantity_after'] as int? ?? 0,
      quantityChange: json['quantity_change'] as int? ?? 0,
      changeType: StockChangeTypeX.fromString(
        json['change_type'] as String? ?? 'adjustment',
      ),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as int?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      createdBy: json['created_by']?['name'] as String? ?? json['created_by_name'] as String?,
    );
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
