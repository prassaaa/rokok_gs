import '../../domain/entities/product.dart';

/// Category model - data layer
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.image,
    super.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'is_active': isActive,
    };
  }

  Category toEntity() => Category(
        id: id,
        name: name,
        description: description,
        image: image,
        isActive: isActive,
      );
}

/// Product model - data layer
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.sku,
    super.barcode,
    super.description,
    required super.price,
    super.costPrice,
    super.image,
    super.category,
    super.stock,
    super.minStock,
    super.unit,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? json['code'],
      barcode: json['barcode'],
      description: json['description'],
      price: _parseDouble(json['price']),
      costPrice: json['cost_price'] != null 
          ? _parseDouble(json['cost_price']) 
          : (json['cost'] != null ? _parseDouble(json['cost']) : null),
      image: _parseImage(json['image']),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category']).toEntity()
          : null,
      stock: _parseStock(json['stock']),
      minStock: _parseMinStock(json['stock'], json['min_stock']),
      unit: json['unit'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Parse image - handles both String and Map (image object from API)
  static String? _parseImage(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    // Handle image as object: { "url": "/storage/...", "path": "..." }
    if (value is Map<String, dynamic>) {
      return value['url'] as String?;
    }
    return null;
  }

  /// Parse stock - handles both int and Maps (stock object from API)
  static int _parseStock(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is Map<String, dynamic>) {
      return _parseStock(value['quantity']);
    }
    return 0;
  }

  /// Parse min_stock - can come from stock object or separate field
  static int? _parseMinStock(dynamic stockValue, dynamic minStockValue) {
    // First check if min_stock is provided directly
    if (minStockValue != null) {
      if (minStockValue is int) return minStockValue;
      if (minStockValue is num) return minStockValue.toInt();
      if (minStockValue is String) return int.tryParse(minStockValue);
    }
    // Otherwise check if stock is an object with minimum_stock
    if (stockValue is Map<String, dynamic>) {
      final minStock = stockValue['minimum_stock'] ?? stockValue['min_stock'];
      if (minStock != null) {
        if (minStock is int) return minStock;
        if (minStock is num) return minStock.toInt();
        if (minStock is String) return int.tryParse(minStock);
      }
    }
    return null;
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
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'description': description,
      'price': price,
      'cost_price': costPrice,
      'image': image,
      'stock': stock,
      'min_stock': minStock,
      'unit': unit,
      'is_active': isActive,
    };
  }

  Product toEntity() => Product(
        id: id,
        name: name,
        sku: sku,
        barcode: barcode,
        description: description,
        price: price,
        costPrice: costPrice,
        image: image,
        category: category,
        stock: stock,
        minStock: minStock,
        unit: unit,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      sku: product.sku,
      barcode: product.barcode,
      description: product.description,
      price: product.price,
      costPrice: product.costPrice,
      image: product.image,
      category: product.category,
      stock: product.stock,
      minStock: product.minStock,
      unit: product.unit,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
