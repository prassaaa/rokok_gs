import 'package:equatable/equatable.dart';

import 'product.dart';

/// Stock entity representing product stock in a branch
class Stock extends Equatable {
  final int id;
  final int productId;
  final int branchId;
  final int quantity;
  final int minStock;
  final DateTime? lastUpdated;
  final Product? product;
  final String? branchName;

  const Stock({
    required this.id,
    required this.productId,
    required this.branchId,
    required this.quantity,
    this.minStock = 10,
    this.lastUpdated,
    this.product,
    this.branchName,
  });

  /// Check if stock is low (below minimum)
  bool get isLowStock => quantity <= minStock;

  /// Check if stock is empty
  bool get isEmpty => quantity <= 0;

  /// Check if stock is critical (below half of minimum)
  bool get isCritical => quantity <= (minStock ~/ 2);

  /// Get stock status text
  String get statusText {
    if (isEmpty) return 'Habis';
    if (isCritical) return 'Kritis';
    if (isLowStock) return 'Rendah';
    return 'Normal';
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        branchId,
        quantity,
        minStock,
        lastUpdated,
        product,
        branchName,
      ];
}

/// Stock history entry for tracking stock changes
class StockHistory extends Equatable {
  final int id;
  final int stockId;
  final int quantityBefore;
  final int quantityAfter;
  final int quantityChange;
  final StockChangeType changeType;
  final String? referenceType;
  final int? referenceId;
  final String? notes;
  final DateTime createdAt;
  final String? createdBy;

  const StockHistory({
    required this.id,
    required this.stockId,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.quantityChange,
    required this.changeType,
    this.referenceType,
    this.referenceId,
    this.notes,
    required this.createdAt,
    this.createdBy,
  });

  /// Check if stock increased
  bool get isIncrease => quantityChange > 0;

  /// Check if stock decreased
  bool get isDecrease => quantityChange < 0;

  @override
  List<Object?> get props => [
        id,
        stockId,
        quantityBefore,
        quantityAfter,
        quantityChange,
        changeType,
        referenceType,
        referenceId,
        notes,
        createdAt,
        createdBy,
      ];
}

/// Enum for stock change types
enum StockChangeType {
  purchase,     // Pembelian/restock
  sale,         // Penjualan
  adjustment,   // Penyesuaian manual
  transfer,     // Transfer antar cabang
  returned,     // Pengembalian
  damaged,      // Rusak/cacat
  expired,      // Kadaluarsa
}

/// Extension for StockChangeType
extension StockChangeTypeX on StockChangeType {
  String get displayName {
    switch (this) {
      case StockChangeType.purchase:
        return 'Pembelian';
      case StockChangeType.sale:
        return 'Penjualan';
      case StockChangeType.adjustment:
        return 'Penyesuaian';
      case StockChangeType.transfer:
        return 'Transfer';
      case StockChangeType.returned:
        return 'Pengembalian';
      case StockChangeType.damaged:
        return 'Rusak';
      case StockChangeType.expired:
        return 'Kadaluarsa';
    }
  }

  String get value {
    switch (this) {
      case StockChangeType.purchase:
        return 'purchase';
      case StockChangeType.sale:
        return 'sale';
      case StockChangeType.adjustment:
        return 'adjustment';
      case StockChangeType.transfer:
        return 'transfer';
      case StockChangeType.returned:
        return 'returned';
      case StockChangeType.damaged:
        return 'damaged';
      case StockChangeType.expired:
        return 'expired';
    }
  }

  static StockChangeType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'purchase':
        return StockChangeType.purchase;
      case 'sale':
        return StockChangeType.sale;
      case 'adjustment':
        return StockChangeType.adjustment;
      case 'transfer':
        return StockChangeType.transfer;
      case 'returned':
        return StockChangeType.returned;
      case 'damaged':
        return StockChangeType.damaged;
      case 'expired':
        return StockChangeType.expired;
      default:
        return StockChangeType.adjustment;
    }
  }
}

/// Parameters for updating stock
class UpdateStockParams extends Equatable {
  final int stockId;
  final int quantity;
  final StockChangeType changeType;
  final String? notes;

  const UpdateStockParams({
    required this.stockId,
    required this.quantity,
    required this.changeType,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'stock_id': stockId,
        'quantity': quantity,
        'change_type': changeType.value,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [stockId, quantity, changeType, notes];
}

/// Parameters for stock adjustment
class StockAdjustmentParams extends Equatable {
  final int productId;
  final int branchId;
  final int newQuantity;
  final String reason;

  const StockAdjustmentParams({
    required this.productId,
    required this.branchId,
    required this.newQuantity,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'branch_id': branchId,
        'new_quantity': newQuantity,
        'reason': reason,
      };

  @override
  List<Object?> get props => [productId, branchId, newQuantity, reason];
}
