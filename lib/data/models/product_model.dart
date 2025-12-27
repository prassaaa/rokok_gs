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
      sku: json['sku'],
      barcode: json['barcode'],
      description: json['description'],
      price: _parseDouble(json['price']),
      costPrice: json['cost_price'] != null ? _parseDouble(json['cost_price']) : null,
      image: json['image'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category']).toEntity()
          : null,
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'],
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
