import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/area.dart';
import '../../bloc/area/area_bloc.dart';
import '../../bloc/area/area_event.dart';
import '../../bloc/area/area_state.dart';
import '../../widgets/area_card.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';

/// Page for displaying list of areas
class AreaListPage extends StatefulWidget {
  const AreaListPage({super.key});

  @override
  State<AreaListPage> createState() => _AreaListPageState();
}

class _AreaListPageState extends State<AreaListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AreaBloc>().add(const LoadAreas());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Area/Wilayah'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari area...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<AreaBloc>().add(const SearchAreas(''));
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                context.read<AreaBloc>().add(SearchAreas(query));
                setState(() {});
              },
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<AreaBloc, AreaState>(
              builder: (context, state) {
                if (state is AreaLoading) {
                  return const Center(child: LoadingIndicator());
                }

                if (state is AreaError) {
                  return ErrorDisplay(
                    message: state.message,
                    onRetry: () {
                      context.read<AreaBloc>().add(const LoadAreas());
                    },
                  );
                }

                if (state is AreasLoaded) {
                  if (state.filteredAreas.isEmpty) {
                    if (state.searchQuery.isNotEmpty) {
                      return EmptyStateDisplay(
                        icon: Icons.search_off,
                        title: 'Area tidak ditemukan',
                        message:
                            'Tidak ada area yang cocok dengan pencarian "${state.searchQuery}"',
                      );
                    }
                    return const EmptyStateDisplay(
                      icon: Icons.location_off_outlined,
                      title: 'Belum ada area',
                      message: 'Belum ada area yang tersedia',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AreaBloc>().add(const RefreshAreas());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: state.filteredAreas.length,
                      itemBuilder: (context, index) {
                        final area = state.filteredAreas[index];
                        return AreaCard(
                          area: area,
                          onTap: () => _showAreaDetail(context, area),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAreaDetail(BuildContext context, Area area) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AreaDetailSheet(area: area),
    );
  }
}

/// Bottom sheet for area detail
class _AreaDetailSheet extends StatelessWidget {
  final Area area;

  const _AreaDetailSheet({required this.area});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: area.isActive
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          color: area.isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.name,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  area.code,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: area.isActive
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  area.isActive ? 'Aktif' : 'Nonaktif',
                                  style: AppTextStyles.caption.copyWith(
                                    color: area.isActive
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                if (area.description != null &&
                    area.description!.isNotEmpty) ...[
                  Text(
                    'Deskripsi',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    area.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Info section
                _buildInfoSection(),
              ],
            ),
          ),
        );
      },
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
          _buildInfoRow('ID', area.id.toString()),
          const Divider(height: 16),
          _buildInfoRow('Kode', area.code),
          const Divider(height: 16),
          _buildInfoRow('Status', area.isActive ? 'Aktif' : 'Nonaktif'),
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
