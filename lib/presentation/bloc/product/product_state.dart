import 'package:equatable/equatable.dart';

import '../../../data/models/pagination_model.dart';
import '../../../domain/entities/product.dart';

/// Product status enum
enum ProductStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

/// Product State
class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final List<Category> categories;
  final Product? selectedProduct;
  final PaginationMeta? meta;
  final String? errorMessage;
  final String? searchQuery;
  final int? selectedCategoryId;
  final bool hasReachedMax;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedProduct,
    this.meta,
    this.errorMessage,
    this.searchQuery,
    this.selectedCategoryId,
    this.hasReachedMax = false,
  });

  /// Initial state
  factory ProductState.initial() => const ProductState();

  /// Copy with method
  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<Category>? categories,
    Product? selectedProduct,
    PaginationMeta? meta,
    String? errorMessage,
    String? searchQuery,
    int? selectedCategoryId,
    bool? hasReachedMax,
    bool clearSelectedProduct = false,
    bool clearCategoryId = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedProduct:
          clearSelectedProduct ? null : (selectedProduct ?? this.selectedProduct),
      meta: meta ?? this.meta,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId:
          clearCategoryId ? null : (selectedCategoryId ?? this.selectedCategoryId),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  /// Check if loading
  bool get isLoading => status == ProductStatus.loading;

  /// Check if loading more
  bool get isLoadingMore => status == ProductStatus.loadingMore;

  /// Check if has error
  bool get hasError => status == ProductStatus.error;

  /// Check if has products
  bool get hasProducts => products.isNotEmpty;

  /// Check if can load more
  bool get canLoadMore => !hasReachedMax && meta != null && meta!.hasNextPage;

  /// Current page
  int get currentPage => meta?.currentPage ?? 1;

  /// Get filtered products count
  int get productsCount => products.length;

  @override
  List<Object?> get props => [
        status,
        products,
        categories,
        selectedProduct,
        meta,
        errorMessage,
        searchQuery,
        selectedCategoryId,
        hasReachedMax,
      ];
}
