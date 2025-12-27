import 'package:equatable/equatable.dart';

import '../../../domain/entities/commission.dart';

/// Base class for commission events
abstract class CommissionEvent extends Equatable {
  const CommissionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load commissions
class CommissionsLoadRequested extends CommissionEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final CommissionStatus? status;
  final bool refresh;

  const CommissionsLoadRequested({
    this.startDate,
    this.endDate,
    this.status,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [startDate, endDate, status, refresh];
}

/// Event to load commission summary
class CommissionSummaryLoadRequested extends CommissionEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const CommissionSummaryLoadRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load more commissions (pagination)
class CommissionsLoadMoreRequested extends CommissionEvent {
  const CommissionsLoadMoreRequested();
}

/// Event to filter commissions
class CommissionsFilterChanged extends CommissionEvent {
  final CommissionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const CommissionsFilterChanged({
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}

/// Event to clear commission error
class CommissionErrorCleared extends CommissionEvent {
  const CommissionErrorCleared();
}
