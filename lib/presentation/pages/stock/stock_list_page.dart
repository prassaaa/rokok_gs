import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/stock.dart';
import '../../bloc/stock/stock_bloc.dart';
import '../../bloc/stock/stock_event.dart';
import '../../bloc/stock/stock_state.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/stock_card.dart';

/// Page for displaying stock list
class StockListPage extends StatefulWidget {
  const StockListPage({super.key});

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    context.read<StockBloc>().add(const StocksLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StockBloc>().add(const StocksLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semua Stok'),
            Tab(text: 'Stok Rendah'),
          ],
          onTap: (index) {
            if (index == 0) {
              context.read<StockBloc>().add(const StocksLoadRequested());
            } else {
              context.read<StockBloc>().add(const LowStocksLoadRequested());
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              controller: _searchController,
              hint: 'Cari produk...',
              onChanged: (value) {
                context.read<StockBloc>().add(StocksSearchChanged(value));
              },
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllStocksTab(),
                _buildLowStocksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllStocksTab() {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state.isLoading && state.stocks.isEmpty) {
          return const LoadingPage(message: 'Memuat stok...');
        }

        if (state.hasError && state.stocks.isEmpty) {
          return ErrorDisplay(
            message: state.errorMessage ?? 'Terjadi kesalahan',
            onRetry: () {
              context.read<StockBloc>().add(const StocksLoadRequested());
            },
          );
        }

        if (state.stocks.isEmpty) {
          return const EmptyStateDisplay(
            icon: Icons.inventory_2_outlined,
            title: 'Tidak Ada Stok',
            message: 'Belum ada data stok tersedia',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<StockBloc>().add(const StocksLoadRequested(refresh: true));
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: state.stocks.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.stocks.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final stock = state.stocks[index];
              return StockCard(
                stock: stock,
                onTap: () => _showStockDetail(stock),
                onUpdateStock: () => _showUpdateStockDialog(stock),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLowStocksTab() {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state.isLoading && state.lowStocks.isEmpty) {
          return const LoadingPage(message: 'Memuat stok rendah...');
        }

        if (state.hasError && state.lowStocks.isEmpty) {
          return ErrorDisplay(
            message: state.errorMessage ?? 'Terjadi kesalahan',
            onRetry: () {
              context.read<StockBloc>().add(const LowStocksLoadRequested());
            },
          );
        }

        if (state.lowStocks.isEmpty) {
          return const EmptyStateDisplay(
            icon: Icons.check_circle_outline,
            title: 'Tidak Ada Stok Rendah',
            message: 'Semua produk memiliki stok yang cukup',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<StockBloc>().add(const LowStocksLoadRequested());
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: state.lowStocks.length,
            itemBuilder: (context, index) {
              final stock = state.lowStocks[index];
              return StockCard(
                stock: stock,
                onTap: () => _showStockDetail(stock),
                onUpdateStock: () => _showUpdateStockDialog(stock),
              );
            },
          ),
        );
      },
    );
  }

  void _showStockDetail(Stock stock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _StockDetailSheet(
          stock: stock,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showUpdateStockDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => _UpdateStockDialog(stock: stock),
    );
  }
}

/// Bottom sheet for stock detail
class _StockDetailSheet extends StatelessWidget {
  final Stock stock;
  final ScrollController scrollController;

  const _StockDetailSheet({
    required this.stock,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.product?.name ?? 'Produk #${stock.productId}',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stock.statusText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stock info
          _buildInfoSection(),
          
          const SizedBox(height: 24),
          
          // Product info if available
          if (stock.product != null) ...[
            Text(
              'Informasi Produk',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildProductInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow('Stok Saat Ini', '${stock.quantity} unit'),
          const Divider(height: 24),
          _buildInfoRow('Stok Minimum', '${stock.minStock} unit'),
          if (stock.branchName != null) ...[
            const Divider(height: 24),
            _buildInfoRow('Cabang', stock.branchName!),
          ],
          if (stock.lastUpdated != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              'Terakhir Update',
              _formatDateTime(stock.lastUpdated!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    final product = stock.product!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (product.sku != null) ...[
            _buildInfoRow('SKU', product.sku!),
            const Divider(height: 24),
          ],
          _buildInfoRow(
            'Harga',
            'Rp ${_formatNumber(product.price.toInt())}',
          ),
          if (product.category != null) ...[
            const Divider(height: 24),
            _buildInfoRow('Kategori', product.category!.name),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (stock.isEmpty) return AppColors.error;
    if (stock.isCritical) return AppColors.error;
    if (stock.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (stock.isEmpty) return Icons.inventory_2_outlined;
    if (stock.isCritical) return Icons.warning_amber_rounded;
    if (stock.isLowStock) return Icons.inventory_outlined;
    return Icons.check_circle_outline;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

/// Dialog for updating stock
class _UpdateStockDialog extends StatefulWidget {
  final Stock stock;

  const _UpdateStockDialog({required this.stock});

  @override
  State<_UpdateStockDialog> createState() => _UpdateStockDialogState();
}

class _UpdateStockDialogState extends State<_UpdateStockDialog> {
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  StockChangeType _changeType = StockChangeType.adjustment;
  bool _isAdding = true;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Stok'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current stock info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stok Saat Ini:',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    '${widget.stock.quantity} unit',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Add or subtract toggle
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    label: 'Tambah',
                    icon: Icons.add,
                    isSelected: _isAdding,
                    onTap: () => setState(() => _isAdding = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildToggleButton(
                    label: 'Kurangi',
                    icon: Icons.remove,
                    isSelected: !_isAdding,
                    onTap: () => setState(() => _isAdding = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Change type
            Text(
              'Jenis Perubahan',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<StockChangeType>(
              initialValue: _changeType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: StockChangeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _changeType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Quantity
            Text(
              'Jumlah',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes
            Text(
              'Catatan (opsional)',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submitUpdate,
          child: const Text('Update'),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitUpdate() {
    final quantityText = _quantityController.text.trim();
    if (quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah')),
      );
      return;
    }

    final quantity = int.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah harus lebih dari 0')),
      );
      return;
    }

    final actualQuantity = _isAdding ? quantity : -quantity;

    final params = UpdateStockParams(
      stockId: widget.stock.id,
      quantity: actualQuantity,
      changeType: _changeType,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    context.read<StockBloc>().add(StockUpdateRequested(params));
    Navigator.of(context).pop();
  }
}
