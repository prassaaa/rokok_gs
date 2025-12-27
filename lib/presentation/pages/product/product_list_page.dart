import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/product.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
    _scrollController.addListener(_onScroll);
  }

  void _loadProducts() {
    context.read<ProductBloc>().add(const ProductsLoadRequested());
  }

  void _loadCategories() {
    context.read<ProductBloc>().add(const CategoriesLoadRequested());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductBloc>().add(const ProductsLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              controller: _searchController,
              hint: 'Cari produk...',
              onChanged: (query) {
                context.read<ProductBloc>().add(ProductsSearchChanged(query));
              },
              onClear: () {
                context.read<ProductBloc>().add(const ProductsSearchChanged(''));
              },
            ),
          ),
          // Category chips
          _buildCategoryChips(),
          // Product list
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.isLoading && state.products.isEmpty) {
                  return const LoadingListPlaceholder();
                }

                if (state.hasError && state.products.isEmpty) {
                  return ErrorDisplay(
                    message: state.errorMessage ?? 'Terjadi kesalahan',
                    onRetry: _loadProducts,
                  );
                }

                if (!state.hasProducts) {
                  return const EmptyStateDisplay(
                    message: 'Tidak ada produk',
                    subtitle: 'Coba ubah filter atau kata kunci pencarian',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc>().add(const ProductsLoadRequested(
                      refresh: true,
                    ));
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.hasReachedMax
                        ? state.products.length
                        : state.products.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: LoadingIndicator(size: 32),
                          ),
                        );
                      }

                      final product = state.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _navigateToDetail(product),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.selectedCategoryId != current.selectedCategoryId,
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // All categories chip
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Semua'),
                    selected: state.selectedCategoryId == null,
                    onSelected: (_) {
                      context
                          .read<ProductBloc>()
                          .add(const ProductsCategoryChanged(null));
                    },
                  ),
                );
              }

              final category = state.categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.name),
                  selected: state.selectedCategoryId == category.id,
                  onSelected: (_) {
                    context
                        .read<ProductBloc>()
                        .add(ProductsCategoryChanged(category.id));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToDetail(Product product) {
    context.push('/products/${product.id}');
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ProductBloc>().add(const ProductsFiltersCleared());
                Navigator.pop(context);
              },
              child: const Text('Reset Filter'),
            ),
          ],
        ),
      ),
    );
  }
}
