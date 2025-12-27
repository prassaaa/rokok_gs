import 'package:equatable/equatable.dart';

/// Category entity
class Category extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, description, image, isActive];
}

/// Product entity - domain layer
class Product extends Equatable {
  final int id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? description;
  final double price;
  final double? costPrice;
  final String? image;
  final Category? category;
  final int stock;
  final int? minStock;
  final String? unit;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.description,
    required this.price,
    this.costPrice,
    this.image,
    this.category,
    this.stock = 0,
    this.minStock,
    this.unit,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if stock is low
  bool get isLowStock => minStock != null && stock <= minStock!;

  /// Check if out of stock
  bool get isOutOfStock => stock <= 0;

  /// Get profit margin
  double get profitMargin {
    if (costPrice == null || costPrice! <= 0) return 0;
    return ((price - costPrice!) / costPrice!) * 100;
  }

  /// Get formatted price
  String get formattedPrice => 'Rp ${price.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        barcode,
        description,
        price,
        costPrice,
        image,
        category,
        stock,
        minStock,
        unit,
        isActive,
        createdAt,
        updatedAt,
      ];
}
