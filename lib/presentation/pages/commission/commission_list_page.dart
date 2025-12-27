import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/commission.dart';
import '../../bloc/commission/commission_bloc.dart';
import '../../bloc/commission/commission_event.dart';
import '../../bloc/commission/commission_state.dart';
import '../../widgets/commission_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

/// Page for displaying commission list
class CommissionListPage extends StatefulWidget {
  const CommissionListPage({super.key});

  @override
  State<CommissionListPage> createState() => _CommissionListPageState();
}

class _CommissionListPageState extends State<CommissionListPage> {
  final _scrollController = ScrollController();
  CommissionStatus? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    context.read<CommissionBloc>()
      ..add(const CommissionsLoadRequested())
      ..add(const CommissionSummaryLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CommissionBloc>().add(const CommissionsLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: BlocBuilder<CommissionBloc, CommissionState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CommissionBloc>()
                ..add(CommissionsLoadRequested(
                  startDate: _selectedDateRange?.start,
                  endDate: _selectedDateRange?.end,
                  status: _selectedStatus,
                  refresh: true,
                ))
                ..add(CommissionSummaryLoadRequested(
                  startDate: _selectedDateRange?.start,
                  endDate: _selectedDateRange?.end,
                ));
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Summary card
                if (state.summary != null)
                  SliverToBoxAdapter(
                    child: CommissionSummaryCard(summary: state.summary!),
                  ),
                
                // Filter chips
                SliverToBoxAdapter(
                  child: _buildFilterChips(),
                ),
                
                // Content
                if (state.isLoading && state.commissions.isEmpty)
                  const SliverFillRemaining(
                    child: LoadingPage(message: 'Memuat komisi...'),
                  )
                else if (state.hasError && state.commissions.isEmpty)
                  SliverFillRemaining(
                    child: ErrorDisplay(
                      message: state.errorMessage ?? 'Terjadi kesalahan',
                      onRetry: () {
                        context.read<CommissionBloc>().add(const CommissionsLoadRequested());
                      },
                    ),
                  )
                else if (state.commissions.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyStateDisplay(
                      icon: Icons.payments_outlined,
                      title: 'Tidak Ada Komisi',
                      message: 'Belum ada data komisi tersedia',
                    ),
                  )
                else ...[
                  // Commission list
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.commissions.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final commission = state.commissions[index];
                          return CommissionCard(
                            commission: commission,
                            onTap: () => _showCommissionDetail(commission),
                          );
                        },
                        childCount: state.commissions.length +
                            (state.isLoadingMore ? 1 : 0),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Date range chip
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _selectedDateRange = null);
                  _applyFilters();
                },
              ),
            ),
          
          // Status filter chips
          ...CommissionStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? status : null;
                  });
                  _applyFilters();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _applyFilters() {
    context.read<CommissionBloc>().add(CommissionsFilterChanged(
      status: _selectedStatus,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
    ));
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              
              Text(
                'Filter Komisi',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Date range selector
              Text('Periode', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _selectedDateRange,
                  );
                  if (dateRange != null) {
                    setModalState(() {
                      _selectedDateRange = dateRange;
                    });
                  }
                },
                icon: const Icon(Icons.date_range),
                label: Text(
                  _selectedDateRange != null
                      ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
                      : 'Pilih periode',
                ),
              ),
              const SizedBox(height: 24),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Terapkan Filter'),
                ),
              ),
              const SizedBox(height: 8),
              
              // Clear button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                      _selectedDateRange = null;
                    });
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset Filter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommissionDetail(Commission commission) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            
            Text(
              'Detail Komisi',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildDetailRow('Kode Transaksi', commission.transactionCode ?? 'TRX-${commission.transactionId}'),
            _buildDetailRow('Sales', commission.salesName ?? '-'),
            _buildDetailRow('Jumlah Komisi', 'Rp ${_formatNumber(commission.amount.toInt())}'),
            _buildDetailRow('Persentase', '${commission.percentage.toStringAsFixed(1)}%'),
            _buildDetailRow('Status', commission.status.displayName),
            _buildDetailRow('Periode', '${commission.periodStart.day}/${commission.periodStart.month}/${commission.periodStart.year} - ${commission.periodEnd.day}/${commission.periodEnd.month}/${commission.periodEnd.year}'),
            if (commission.paidAt != null)
              _buildDetailRow('Tanggal Bayar', '${commission.paidAt!.day}/${commission.paidAt!.month}/${commission.paidAt!.year}'),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
