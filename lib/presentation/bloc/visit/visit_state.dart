import 'package:equatable/equatable.dart';

import '../../../domain/entities/visit.dart';

/// Visit list states
abstract class VisitState extends Equatable {
  const VisitState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VisitInitial extends VisitState {
  const VisitInitial();
}

/// Loading state
class VisitLoading extends VisitState {
  const VisitLoading();
}

/// Loaded state with visits
class VisitLoaded extends VisitState {
  final List<Visit> visits;
  final bool hasReachedMax;
  final int currentPage;
  final int totalPages;
  final VisitStatus? statusFilter;
  final VisitType? visitTypeFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoadingMore;

  const VisitLoaded({
    required this.visits,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.statusFilter,
    this.visitTypeFilter,
    this.startDate,
    this.endDate,
    this.isLoadingMore = false,
  });

  VisitLoaded copyWith({
    List<Visit>? visits,
    bool? hasReachedMax,
    int? currentPage,
    int? totalPages,
    VisitStatus? statusFilter,
    VisitType? visitTypeFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoadingMore,
    bool clearFilters = false,
  }) {
    return VisitLoaded(
      visits: visits ?? this.visits,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      statusFilter: clearFilters ? null : (statusFilter ?? this.statusFilter),
      visitTypeFilter: clearFilters ? null : (visitTypeFilter ?? this.visitTypeFilter),
      startDate: clearFilters ? null : (startDate ?? this.startDate),
      endDate: clearFilters ? null : (endDate ?? this.endDate),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  bool get hasFilters =>
      statusFilter != null ||
      visitTypeFilter != null ||
      startDate != null ||
      endDate != null;

  @override
  List<Object?> get props => [
        visits,
        hasReachedMax,
        currentPage,
        totalPages,
        statusFilter,
        visitTypeFilter,
        startDate,
        endDate,
        isLoadingMore,
      ];
}

/// Error state
class VisitError extends VisitState {
  final String message;
  final bool isNetworkError;

  const VisitError({
    required this.message,
    this.isNetworkError = false,
  });

  @override
  List<Object?> get props => [message, isNetworkError];
}

/// Visit detail loading state
class VisitDetailLoading extends VisitState {
  const VisitDetailLoading();
}

/// Visit detail loaded state
class VisitDetailLoaded extends VisitState {
  final Visit visit;

  const VisitDetailLoaded(this.visit);

  @override
  List<Object?> get props => [visit];
}

/// Visit creating state
class VisitCreating extends VisitState {
  const VisitCreating();
}

/// Visit created successfully
class VisitCreated extends VisitState {
  final Visit visit;

  const VisitCreated(this.visit);

  @override
  List<Object?> get props => [visit];
}
