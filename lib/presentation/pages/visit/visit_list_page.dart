import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/visit.dart';
import '../../bloc/visit/visit_bloc.dart';
import '../../bloc/visit/visit_event.dart';
import '../../bloc/visit/visit_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';

/// Visit list page
class VisitListPage extends StatefulWidget {
  const VisitListPage({super.key});

  @override
  State<VisitListPage> createState() => _VisitListPageState();
}

class _VisitListPageState extends State<VisitListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<VisitBloc>().add(const LoadVisits());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<VisitBloc>().add(const LoadMoreVisits());
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
        title: const Text('Kunjungan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<VisitBloc>().add(const RefreshVisits());
        },
        child: BlocBuilder<VisitBloc, VisitState>(
          builder: (context, state) {
            if (state is VisitLoading) {
              return const LoadingPage(message: 'Memuat kunjungan...');
            }

            if (state is VisitError) {
              return ErrorDisplay(
                message: state.message,
                isNetworkError: state.isNetworkError,
                onRetry: () =>
                    context.read<VisitBloc>().add(const LoadVisits()),
              );
            }

            if (state is VisitLoaded) {
              if (state.visits.isEmpty) {
                return _buildEmptyState(state.hasFilters);
              }

              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.visits.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= state.visits.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return _VisitCard(visit: state.visits[index]);
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/visits/new'),
        icon: const Icon(Icons.add),
        label: const Text('Kunjungan Baru'),
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilters) {
    return EmptyStateDisplay(
      icon: Icons.fact_check_outlined,
      title: hasFilters ? 'Tidak ada hasil' : 'Belum ada kunjungan',
      message: hasFilters
          ? 'Tidak ada kunjungan dengan filter yang dipilih'
          : 'Kunjungan akan muncul di sini',
      actionLabel: hasFilters ? 'Hapus Filter' : null,
      onAction: hasFilters
          ? () => context.read<VisitBloc>().add(const ClearFilters())
          : null,
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        onApply: (status, visitType, startDate, endDate) {
          Navigator.pop(context);
          this.context.read<VisitBloc>().add(
            FilterVisits(
              status: status,
              visitType: visitType,
              startDate: startDate,
              endDate: endDate,
            ),
          );
        },
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final Visit visit;

  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/visits/${visit.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          visit.visitNumber,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(visit.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    visit.visitTypeText,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy').format(visit.visitDate),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (visit.purpose != null) ...[
                const SizedBox(height: 12),
                Text(
                  visit.purpose!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(VisitStatus status) {
    Color color;
    switch (status) {
      case VisitStatus.approved:
        color = AppColors.success;
        break;
      case VisitStatus.rejected:
        color = AppColors.error;
        break;
      case VisitStatus.pending:
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        visit.statusText,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final Function(VisitStatus?, VisitType?, DateTime?, DateTime?) onApply;

  const _FilterBottomSheet({required this.onApply});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  VisitStatus? _selectedStatus;
  VisitType? _selectedVisitType;
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Kunjungan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Menunggu'),
                  selected: _selectedStatus == VisitStatus.pending,
                  onSelected: (selected) => setState(() {
                    _selectedStatus = selected ? VisitStatus.pending : null;
                  }),
                ),
                FilterChip(
                  label: const Text('Disetujui'),
                  selected: _selectedStatus == VisitStatus.approved,
                  onSelected: (selected) => setState(() {
                    _selectedStatus = selected ? VisitStatus.approved : null;
                  }),
                ),
                FilterChip(
                  label: const Text('Ditolak'),
                  selected: _selectedStatus == VisitStatus.rejected,
                  onSelected: (selected) => setState(() {
                    _selectedStatus = selected ? VisitStatus.rejected : null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tipe Kunjungan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Rutin'),
                  selected: _selectedVisitType == VisitType.routine,
                  onSelected: (selected) => setState(() {
                    _selectedVisitType = selected ? VisitType.routine : null;
                  }),
                ),
                FilterChip(
                  label: const Text('Prospek'),
                  selected: _selectedVisitType == VisitType.prospecting,
                  onSelected: (selected) => setState(() {
                    _selectedVisitType = selected
                        ? VisitType.prospecting
                        : null;
                  }),
                ),
                FilterChip(
                  label: const Text('Follow Up'),
                  selected: _selectedVisitType == VisitType.followUp,
                  onSelected: (selected) => setState(() {
                    _selectedVisitType = selected ? VisitType.followUp : null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _selectedStatus,
                    _selectedVisitType,
                    _selectedDateRange?.start,
                    _selectedDateRange?.end,
                  );
                },
                child: const Text('Terapkan Filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
