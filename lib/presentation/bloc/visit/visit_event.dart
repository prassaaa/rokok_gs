import 'package:equatable/equatable.dart';

import '../../../domain/entities/visit.dart';

/// Visit list events
abstract class VisitEvent extends Equatable {
  const VisitEvent();

  @override
  List<Object?> get props => [];
}

/// Load visits
class LoadVisits extends VisitEvent {
  const LoadVisits();
}

/// Load more visits (pagination)
class LoadMoreVisits extends VisitEvent {
  const LoadMoreVisits();
}

/// Refresh visits
class RefreshVisits extends VisitEvent {
  const RefreshVisits();
}

/// Filter visits
class FilterVisits extends VisitEvent {
  final VisitStatus? status;
  final VisitType? visitType;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterVisits({
    this.status,
    this.visitType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, visitType, startDate, endDate];
}

/// Clear filters
class ClearFilters extends VisitEvent {
  const ClearFilters();
}

/// Load visit detail
class LoadVisitDetail extends VisitEvent {
  final int visitId;

  const LoadVisitDetail(this.visitId);

  @override
  List<Object?> get props => [visitId];
}

/// Load sales visits
class LoadSalesVisits extends VisitEvent {
  final int salesId;

  const LoadSalesVisits(this.salesId);

  @override
  List<Object?> get props => [salesId];
}

/// Load more sales visits
class LoadMoreSalesVisits extends VisitEvent {
  final int salesId;

  const LoadMoreSalesVisits(this.salesId);

  @override
  List<Object?> get props => [salesId];
}

/// Create visit event
class CreateVisitEvent extends VisitEvent {
  final CreateVisitParams params;

  const CreateVisitEvent(this.params);

  @override
  List<Object?> get props => [params];
}
