import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/services/bluetooth_print_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../di/injection_container.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/printer_dialog.dart';

/// Transaction detail page
class TransactionDetailPage extends StatefulWidget {
  final int transactionId;

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final BluetoothPrintService _printService = sl<BluetoothPrintService>();
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    context
        .read<TransactionBloc>()
        .add(LoadTransactionDetail(widget.transactionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () => _showPrintDialog(context),
            tooltip: 'Print Struk',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareTransaction,
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionDetailLoading) {
            return const LoadingPage(message: 'Memuat detail...');
          }

          if (state is TransactionDetailError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () => context
                  .read<TransactionBloc>()
                  .add(LoadTransactionDetail(widget.transactionId)),
            );
          }

          if (state is TransactionDetailLoaded) {
            return _buildContent(state.transaction);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(Transaction transaction) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(transaction),
                _buildInfoSection(transaction),
                _buildItemsSection(transaction),
                _buildTotalSection(transaction),
                if (transaction.notes != null && transaction.notes!.isNotEmpty)
                  _buildNotesSection(transaction),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildPrintButton(transaction),
      ],
    );
  }

  Widget _buildHeader(Transaction transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(transaction.status),
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            transaction.invoiceNumber ?? '#${transaction.id}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(transaction.transactionDate),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusBadge(transaction.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    Color backgroundColor;
    String text;

    switch (status) {
      case TransactionStatus.completed:
        backgroundColor = AppColors.success;
        text = 'Selesai';
        break;
      case TransactionStatus.pending:
        backgroundColor = AppColors.warning;
        text = 'Pending';
        break;
      case TransactionStatus.cancelled:
        backgroundColor = AppColors.error;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoSection(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.person_outline,
                'Pelanggan',
                transaction.customerName ?? 'Pelanggan Umum',
              ),
              const Divider(),
              _buildInfoRow(
                Icons.badge_outlined,
                'Sales',
                transaction.salesName ?? '-',
              ),
              if (transaction.areaName != null) ...[
                const Divider(),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Area',
                  transaction.areaName!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Daftar Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${transaction.totalItems} item',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transaction.items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = transaction.items[index];
                  return _buildItemRow(item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(TransactionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x Rp ${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${item.subtotal.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTotalRow('Subtotal', transaction.formattedSubtotal),
              if (transaction.hasDiscount) ...[
                const SizedBox(height: 8),
                _buildTotalRow(
                  'Diskon',
                  '- ${transaction.formattedDiscount}',
                  valueColor: AppColors.error,
                ),
              ],
              if (transaction.tax > 0) ...[
                const SizedBox(height: 8),
                _buildTotalRow(
                  'Pajak',
                  'Rp ${transaction.tax.toStringAsFixed(0)}',
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              _buildTotalRow(
                'Total',
                transaction.formattedTotal,
                isTotal: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
            color: isTotal
                ? AppColors.primary
                : valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.notes_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Catatan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                transaction.notes!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Icons.check_circle_outline;
      case TransactionStatus.pending:
        return Icons.pending_outlined;
      case TransactionStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID').format(date);
  }

  void _shareTransaction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur berbagi akan segera hadir')),
    );
  }

  Widget _buildPrintButton(Transaction transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isPrinting ? null : () => _showPrintDialog(context),
            icon: _isPrinting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print),
            label: Text(_isPrinting ? 'Mencetak...' : 'Print Struk'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPrintDialog(BuildContext context) async {
    final bloc = context.read<TransactionBloc>();
    final state = bloc.state;
    if (state is! TransactionDetailLoaded) return;

    final transaction = state.transaction;
    final isConnected = await _printService.isConnected();
    
    if (!mounted) return;
    
    if (isConnected) {
      // Already connected, print directly
      _printReceipt(transaction);
    } else {
      // Show printer selection dialog
      final result = await showDialog<bool>(
        context: this.context,
        builder: (dialogContext) => PrinterDialog(
          printService: _printService,
          onConnected: () {},
        ),
      );

      if (result == true && mounted) {
        _printReceipt(transaction);
      }
    }
  }

  Future<void> _printReceipt(Transaction transaction) async {
    setState(() {
      _isPrinting = true;
    });

    try {
      final success = await _printService.printReceipt(
        transaction,
        storeName: 'ROKOK GS',
        storeAddress: 'Jl. Contoh No. 123',
      );

      if (mounted) {
        setState(() {
          _isPrinting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Struk berhasil dicetak!' : 'Gagal mencetak struk',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
