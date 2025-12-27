import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/commission/commission_usecases.dart';
import 'commission_event.dart';
import 'commission_state.dart';

/// BLoC for managing commission state
class CommissionBloc extends Bloc<CommissionEvent, CommissionState> {
  final GetCommissionsUseCase _getCommissionsUseCase;
  final GetCommissionSummaryUseCase _getCommissionSummaryUseCase;

  static const int _perPage = 20;

  CommissionBloc({
    required GetCommissionsUseCase getCommissionsUseCase,
    required GetCommissionSummaryUseCase getCommissionSummaryUseCase,
  })  : _getCommissionsUseCase = getCommissionsUseCase,
        _getCommissionSummaryUseCase = getCommissionSummaryUseCase,
        super(CommissionState.initial()) {
    on<CommissionsLoadRequested>(_onCommissionsLoadRequested);
    on<CommissionSummaryLoadRequested>(_onCommissionSummaryLoadRequested);
    on<CommissionsLoadMoreRequested>(_onCommissionsLoadMoreRequested);
    on<CommissionsFilterChanged>(_onCommissionsFilterChanged);
    on<CommissionErrorCleared>(_onCommissionErrorCleared);
  }

  Future<void> _onCommissionsLoadRequested(
    CommissionsLoadRequested event,
    Emitter<CommissionState> emit,
  ) async {
    emit(state.copyWith(
      status: CommissionBlocStatus.loading,
      clearError: true,
    ));

    final result = await _getCommissionsUseCase(
      startDate: event.startDate ?? state.startDate,
      endDate: event.endDate ?? state.endDate,
      status: event.status ?? state.statusFilter,
      page: 1,
      perPage: _perPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CommissionBlocStatus.error,
        errorMessage: failure.message,
      )),
      (commissions) => emit(state.copyWith(
        status: CommissionBlocStatus.loaded,
        commissions: commissions,
        hasReachedMax: commissions.length < _perPage,
        currentPage: 1,
      )),
    );
  }

  Future<void> _onCommissionSummaryLoadRequested(
    CommissionSummaryLoadRequested event,
    Emitter<CommissionState> emit,
  ) async {
    final result = await _getCommissionSummaryUseCase(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (summary) => emit(state.copyWith(
        summary: summary,
      )),
    );
  }

  Future<void> _onCommissionsLoadMoreRequested(
    CommissionsLoadMoreRequested event,
    Emitter<CommissionState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(status: CommissionBlocStatus.loadingMore));

    final nextPage = state.currentPage + 1;

    final result = await _getCommissionsUseCase(
      startDate: state.startDate,
      endDate: state.endDate,
      status: state.statusFilter,
      page: nextPage,
      perPage: _perPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CommissionBlocStatus.loaded,
        errorMessage: failure.message,
      )),
      (newCommissions) => emit(state.copyWith(
        status: CommissionBlocStatus.loaded,
        commissions: [...state.commissions, ...newCommissions],
        hasReachedMax: newCommissions.length < _perPage,
        currentPage: nextPage,
      )),
    );
  }

  Future<void> _onCommissionsFilterChanged(
    CommissionsFilterChanged event,
    Emitter<CommissionState> emit,
  ) async {
    emit(state.copyWith(
      status: CommissionBlocStatus.loading,
      statusFilter: event.status,
      startDate: event.startDate,
      endDate: event.endDate,
      clearError: true,
    ));

    final result = await _getCommissionsUseCase(
      startDate: event.startDate,
      endDate: event.endDate,
      status: event.status,
      page: 1,
      perPage: _perPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CommissionBlocStatus.error,
        errorMessage: failure.message,
      )),
      (commissions) => emit(state.copyWith(
        status: CommissionBlocStatus.loaded,
        commissions: commissions,
        hasReachedMax: commissions.length < _perPage,
        currentPage: 1,
      )),
    );
  }

  void _onCommissionErrorCleared(
    CommissionErrorCleared event,
    Emitter<CommissionState> emit,
  ) {
    emit(state.copyWith(clearError: true, status: CommissionBlocStatus.loaded));
  }
}
