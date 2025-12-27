import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/transaction_card.dart';

/// Transaction list page
class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final _scrollController = ScrollController();
  TransactionStatus? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    context.read<TransactionBloc>().add(const LoadTransactions());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionBloc>().add(const LoadMoreTransactions());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<TransactionBloc>().add(const RefreshTransactions());
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const LoadingPage(message: 'Memuat transaksi...');
            }

            if (state is TransactionError) {
              return ErrorDisplay(
                message: state.message,
                isNetworkError: state.isNetworkError,
                onRetry: _loadTransactions,
              );
            }

            if (state is TransactionLoaded) {
              if (state.transactions.isEmpty) {
                return EmptyStateDisplay(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada transaksi',
                  message: state.hasFilters
                      ? 'Tidak ada transaksi dengan filter yang dipilih'
                      : 'Transaksi akan muncul di sini',
                  actionLabel: state.hasFilters ? 'Hapus Filter' : null,
                  onAction: state.hasFilters
                      ? () => context
                          .read<TransactionBloc>()
                          .add(const ClearFilters())
                      : null,
                );
              }

              return _buildTransactionList(state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/new'),
        icon: const Icon(Icons.add),
        label: const Text('Transaksi Baru'),
      ),
    );
  }

  Widget _buildTransactionList(TransactionLoaded state) {
    return Column(
      children: [
        // Active filters
        if (state.hasFilters) _buildActiveFilters(state),

        // Summary cards
        if (state.summary != null) _buildSummarySection(state),

        // Transaction list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.hasReachedMax
                ? state.transactions.length
                : state.transactions.length + 1,
            itemBuilder: (context, index) {
              if (index >= state.transactions.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: LoadingIndicator(),
                  ),
                );
              }

              final transaction = state.transactions[index];
              return TransactionCard(
                transaction: transaction,
                onTap: () => context.push('/transactions/${transaction.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters(TransactionLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (state.statusFilter != null)
                  Chip(
                    label: Text(_getStatusLabel(state.statusFilter!)),
                    onDeleted: () {
                      context.read<TransactionBloc>().add(LoadTransactions(
                            startDate: state.startDate,
                            endDate: state.endDate,
                          ));
                    },
                    deleteIconColor: AppColors.textSecondary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                if (state.startDate != null && state.endDate != null)
                  Chip(
                    label: Text(
                      '${DateFormat('dd/MM').format(state.startDate!)} - ${DateFormat('dd/MM').format(state.endDate!)}',
                    ),
                    onDeleted: () {
                      context.read<TransactionBloc>().add(LoadTransactions(
                            status: state.statusFilter,
                          ));
                    },
                    deleteIconColor: AppColors.textSecondary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionBloc>().add(const ClearFilters());
              setState(() {
                _selectedStatus = null;
                _selectedDateRange = null;
              });
            },
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(TransactionLoaded state) {
    final summary = state.summary!;
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TransactionSummaryCard(
              title: 'Total Transaksi',
              value: summary.totalTransactions.toString(),
              icon: Icons.receipt,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TransactionSummaryCard(
              title: 'Total Penjualan',
              value: summary.formattedTotalSales,
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedStatus: _selectedStatus,
        selectedDateRange: _selectedDateRange,
        onApply: (status, dateRange) {
          setState(() {
            _selectedStatus = status;
            _selectedDateRange = dateRange;
          });

          context.read<TransactionBloc>().add(LoadTransactions(
                status: status,
                startDate: dateRange?.start,
                endDate: dateRange?.end,
              ));
        },
      ),
    );
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatefulWidget {
  final TransactionStatus? selectedStatus;
  final DateTimeRange? selectedDateRange;
  final Function(TransactionStatus?, DateTimeRange?) onApply;

  const _FilterBottomSheet({
    this.selectedStatus,
    this.selectedDateRange,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late TransactionStatus? _status;
  late DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _dateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status filter
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildStatusChip(null, 'Semua'),
              _buildStatusChip(TransactionStatus.completed, 'Selesai'),
              _buildStatusChip(TransactionStatus.pending, 'Pending'),
              _buildStatusChip(TransactionStatus.cancelled, 'Dibatalkan'),
            ],
          ),

          const SizedBox(height: 20),

          // Date range filter
          const Text(
            'Periode',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dateRange != null
                          ? '${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}'
                          : 'Pilih periode',
                      style: TextStyle(
                        color: _dateRange != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (_dateRange != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setState(() => _dateRange = null),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_status, _dateRange);
                Navigator.pop(context);
              },
              child: const Text('Terapkan Filter'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus? status, String label) {
    final isSelected = _status == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _status = selected ? status : null);
      },
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }
}
