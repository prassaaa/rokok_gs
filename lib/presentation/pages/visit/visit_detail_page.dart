import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/visit.dart';
import '../../bloc/visit/visit_bloc.dart';
import '../../bloc/visit/visit_event.dart';
import '../../bloc/visit/visit_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';

/// Visit detail page
class VisitDetailPage extends StatefulWidget {
  final int visitId;

  const VisitDetailPage({super.key, required this.visitId});

  @override
  State<VisitDetailPage> createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<VisitDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<VisitBloc>().add(LoadVisitDetail(widget.visitId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kunjungan')),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          if (state is VisitDetailLoading) {
            return const LoadingPage(message: 'Memuat detail...');
          }

          if (state is VisitError) {
            return ErrorDisplay(
              message: state.message,
              isNetworkError: state.isNetworkError,
              onRetry: () => context.read<VisitBloc>().add(
                LoadVisitDetail(widget.visitId),
              ),
            );
          }

          if (state is VisitDetailLoaded) {
            return _buildDetailContent(state.visit);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDetailContent(Visit visit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(visit),
          const SizedBox(height: 16),
          _buildInfoCard(visit),
          const SizedBox(height: 16),
          if (visit.purpose != null || visit.result != null)
            _buildPurposeResultCard(visit),
          if (visit.hasPhoto) ...[
            const SizedBox(height: 16),
            _buildPhotoCard(visit),
          ],
          if (visit.hasLocation) ...[
            const SizedBox(height: 16),
            _buildLocationCard(visit),
          ],
          if (visit.notes != null) ...[
            const SizedBox(height: 16),
            _buildNotesCard(visit),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(Visit visit) {
    Color statusColor;
    IconData statusIcon;
    switch (visit.status) {
      case VisitStatus.approved:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case VisitStatus.rejected:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      case VisitStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        break;
    }

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visit.visitNumber,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Visit visit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Kunjungan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.person, 'Pelanggan', visit.customerName),
            if (visit.customerPhone != null)
              _buildInfoRow(Icons.phone, 'Telepon', visit.customerPhone!),
            if (visit.customerAddress != null)
              _buildInfoRow(
                Icons.location_on,
                'Alamat',
                visit.customerAddress!,
              ),
            _buildInfoRow(Icons.category, 'Tipe', visit.visitTypeText),
            _buildInfoRow(
              Icons.calendar_today,
              'Tanggal',
              DateFormat('dd MMMM yyyy, HH:mm').format(visit.visitDate),
            ),
            if (visit.salesName != null)
              _buildInfoRow(Icons.person_outline, 'Sales', visit.salesName!),
            if (visit.areaName != null)
              _buildInfoRow(Icons.map, 'Area', visit.areaName!),
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeResultCard(Visit visit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visit.purpose != null) ...[
              const Text(
                'Tujuan Kunjungan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                visit.purpose!,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              if (visit.result != null) const Divider(height: 24),
            ],
            if (visit.result != null) ...[
              const Text(
                'Hasil Kunjungan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                visit.result!,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(Visit visit) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Foto Kunjungan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Image.network(
              visit.photo!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Visit visit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi Kunjungan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latitude: ${visit.latitude!.toStringAsFixed(6)}'),
                        Text(
                          'Longitude: ${visit.longitude!.toStringAsFixed(6)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Visit visit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              visit.notes!,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
