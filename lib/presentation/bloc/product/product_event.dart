import 'package:equatable/equatable.dart';

/// Base Product Event
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load products with pagination
class ProductsLoadRequested extends ProductEvent {
  final int page;
  final String? search;
  final int? categoryId;
  final bool refresh;

  const ProductsLoadRequested({
    this.page = 1,
    this.search,
    this.categoryId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, search, categoryId, refresh];
}

/// Load more products (pagination)
class ProductsLoadMoreRequested extends ProductEvent {
  const ProductsLoadMoreRequested();
}

/// Load product detail
class ProductDetailLoadRequested extends ProductEvent {
  final int productId;

  const ProductDetailLoadRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Load categories
class CategoriesLoadRequested extends ProductEvent {
  const CategoriesLoadRequested();
}

/// Filter products by category
class ProductsCategoryChanged extends ProductEvent {
  final int? categoryId;

  const ProductsCategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Search products
class ProductsSearchChanged extends ProductEvent {
  final String query;

  const ProductsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear product filters
class ProductsFiltersCleared extends ProductEvent {
  const ProductsFiltersCleared();
}
