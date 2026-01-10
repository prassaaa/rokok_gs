import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/product/get_product_detail_usecase.dart';
import '../../../domain/usecases/product/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

/// Product BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;
  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductDetailUseCase,
  }) : super(ProductState.initial()) {
    on<ProductsLoadRequested>(_onProductsLoadRequested);
    on<ProductsLoadMoreRequested>(_onProductsLoadMoreRequested);
    on<ProductDetailLoadRequested>(_onProductDetailLoadRequested);
    on<ProductsCategoryChanged>(_onProductsCategoryChanged);
    on<ProductsSearchChanged>(_onProductsSearchChanged);
    on<ProductsFiltersCleared>(_onProductsFiltersCleared);
  }

  /// Handle load products
  Future<void> _onProductsLoadRequested(
    ProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      searchQuery: event.search,
      selectedCategoryId: event.categoryId,
      clearCategoryId: event.categoryId == null,
    ));

    final result = await getProductsUseCase(GetProductsParams(
      page: event.page,
      search: event.search,
      categoryId: event.categoryId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: response.data,
        meta: response.meta,
        hasReachedMax: !response.meta.hasNextPage,
      )),
    );
  }

  /// Handle load more products
  Future<void> _onProductsLoadMoreRequested(
    ProductsLoadMoreRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(status: ProductStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await getProductsUseCase(GetProductsParams(
      page: nextPage,
      search: state.searchQuery,
      categoryId: state.selectedCategoryId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: [...state.products, ...response.data],
        meta: response.meta,
        hasReachedMax: !response.meta.hasNextPage,
      )),
    );
  }

  /// Handle load product detail
  Future<void> _onProductDetailLoadRequested(
    ProductDetailLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      clearSelectedProduct: true,
    ));

    final result = await getProductDetailUseCase(event.productId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      )),
      (product) => emit(state.copyWith(
        status: ProductStatus.loaded,
        selectedProduct: product,
      )),
    );
  }

  /// Handle category change
  Future<void> _onProductsCategoryChanged(
    ProductsCategoryChanged event,
    Emitter<ProductState> emit,
  ) async {
    add(ProductsLoadRequested(
      categoryId: event.categoryId,
      search: state.searchQuery,
    ));
  }

  /// Handle search change
  Future<void> _onProductsSearchChanged(
    ProductsSearchChanged event,
    Emitter<ProductState> emit,
  ) async {
    add(ProductsLoadRequested(
      search: event.query.isEmpty ? null : event.query,
      categoryId: state.selectedCategoryId,
    ));
  }

  /// Handle clear filters
  void _onProductsFiltersCleared(
    ProductsFiltersCleared event,
    Emitter<ProductState> emit,
  ) {
    add(const ProductsLoadRequested(refresh: true));
  }
}
