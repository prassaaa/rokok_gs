import 'package:equatable/equatable.dart';

import '../../../domain/entities/commission.dart';

/// Enum for commission status
enum CommissionBlocStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

/// State class for commission
class CommissionState extends Equatable {
  final CommissionBlocStatus status;
  final List<Commission> commissions;
  final CommissionSummary? summary;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final CommissionStatus? statusFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const CommissionState({
    this.status = CommissionBlocStatus.initial,
    this.commissions = const [],
    this.summary,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.statusFilter,
    this.startDate,
    this.endDate,
  });

  /// Initial state
  factory CommissionState.initial() => const CommissionState();

  /// Check if loading
  bool get isLoading => status == CommissionBlocStatus.loading;

  /// Check if loading more
  bool get isLoadingMore => status == CommissionBlocStatus.loadingMore;

  /// Check if error
  bool get hasError => status == CommissionBlocStatus.error;

  /// Check if loaded
  bool get isLoaded => status == CommissionBlocStatus.loaded;

  /// Get pending commissions
  List<Commission> get pendingCommissions =>
      commissions.where((c) => c.isPending).toList();

  /// Get paid commissions
  List<Commission> get paidCommissions =>
      commissions.where((c) => c.isPaid).toList();

  CommissionState copyWith({
    CommissionBlocStatus? status,
    List<Commission>? commissions,
    CommissionSummary? summary,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    CommissionStatus? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return CommissionState(
      status: status ?? this.status,
      commissions: commissions ?? this.commissions,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        commissions,
        summary,
        errorMessage,
        hasReachedMax,
        currentPage,
        statusFilter,
        startDate,
        endDate,
      ];
}
