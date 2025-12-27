import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/stock.dart';

/// Card widget for displaying stock item
class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;
  final VoidCallback? onUpdateStock;

  const StockCard({
    super.key,
    required this.stock,
    this.onTap,
    this.onUpdateStock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Stock indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.product?.name ?? 'Produk #${stock.productId}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStockBadge(),
                        const SizedBox(width: 8),
                        Text(
                          'Min: ${stock.minStock}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Quantity
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${stock.quantity}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'unit',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Update button
              if (onUpdateStock != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onUpdateStock,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        stock.statusText,
        style: AppTextStyles.caption.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w500,
        ),
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
}

/// List tile for stock item (compact version)
class StockListTile extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;

  const StockListTile({
    super.key,
    required this.stock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getStatusColor().withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${stock.quantity}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        stock.product?.name ?? 'Produk #${stock.productId}',
        style: AppTextStyles.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        stock.statusText,
        style: AppTextStyles.caption.copyWith(
          color: _getStatusColor(),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Color _getStatusColor() {
    if (stock.isEmpty) return AppColors.error;
    if (stock.isCritical) return AppColors.error;
    if (stock.isLowStock) return AppColors.warning;
    return AppColors.success;
  }
}

/// Summary card for stock statistics
class StockSummaryCard extends StatelessWidget {
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final VoidCallback? onLowStockTap;

  const StockSummaryCard({
    super.key,
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    this.onLowStockTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Stok',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Produk',
                    totalProducts.toString(),
                    Icons.inventory_2,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onLowStockTap,
                    child: _buildStatItem(
                      'Stok Rendah',
                      lowStockCount.toString(),
                      Icons.warning_amber_rounded,
                      AppColors.warning,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Habis',
                    outOfStockCount.toString(),
                    Icons.remove_shopping_cart,
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget for stock history item
class StockHistoryItem extends StatelessWidget {
  final StockHistory history;

  const StockHistoryItem({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (history.isIncrease ? AppColors.success : AppColors.error)
              .withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          history.isIncrease ? Icons.add : Icons.remove,
          color: history.isIncrease ? AppColors.success : AppColors.error,
        ),
      ),
      title: Row(
        children: [
          Text(
            history.changeType.displayName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (history.isIncrease ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${history.isIncrease ? '+' : ''}${history.quantityChange}',
              style: AppTextStyles.caption.copyWith(
                color: history.isIncrease ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${history.quantityBefore} → ${history.quantityAfter}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (history.notes != null && history.notes!.isNotEmpty)
            Text(
              history.notes!,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Text(
        _formatDate(history.createdAt),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
