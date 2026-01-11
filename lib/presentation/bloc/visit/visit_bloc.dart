import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/usecases/visit/create_visit.dart';
import '../../../domain/usecases/visit/get_sales_visits.dart';
import '../../../domain/usecases/visit/get_visit_detail.dart';
import '../../../domain/usecases/visit/get_visits.dart';
import 'visit_event.dart';
import 'visit_state.dart';

/// BLoC for managing visit list and operations
class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final GetVisits getVisits;
  final GetVisitDetail getVisitDetail;
  final GetSalesVisits getSalesVisits;
  final CreateVisit createVisit;

  VisitBloc({
    required this.getVisits,
    required this.getVisitDetail,
    required this.getSalesVisits,
    required this.createVisit,
  }) : super(const VisitInitial()) {
    on<LoadVisits>(_onLoadVisits);
    on<LoadMoreVisits>(_onLoadMoreVisits);
    on<RefreshVisits>(_onRefreshVisits);
    on<FilterVisits>(_onFilterVisits);
    on<ClearFilters>(_onClearFilters);
    on<LoadVisitDetail>(_onLoadVisitDetail);
    on<LoadSalesVisits>(_onLoadSalesVisits);
    on<LoadMoreSalesVisits>(_onLoadMoreSalesVisits);
    on<CreateVisitEvent>(_onCreateVisit);
  }

  Future<void> _onLoadVisits(
    LoadVisits event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitLoading());

    final result = await getVisits(page: 1);

    result.fold(
      (failure) => emit(VisitError(
        message: _mapFailureToMessage(failure),
        isNetworkError: failure is NetworkFailure,
      )),
      (response) => emit(VisitLoaded(
        visits: response.data,
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
      )),
    );
  }

  Future<void> _onLoadMoreVisits(
    LoadMoreVisits event,
    Emitter<VisitState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VisitLoaded || currentState.hasReachedMax) {
      return;
    }

    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await getVisits(
      page: nextPage,
      status: currentState.statusFilter,
      visitType: currentState.visitTypeFilter,
      startDate: currentState.startDate,
      endDate: currentState.endDate,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (response) => emit(currentState.copyWith(
        visits: [...currentState.visits, ...response.data],
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onRefreshVisits(
    RefreshVisits event,
    Emitter<VisitState> emit,
  ) async {
    final currentState = state;
    if (currentState is VisitLoaded) {
      final result = await getVisits(
        page: 1,
        status: currentState.statusFilter,
        visitType: currentState.visitTypeFilter,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      );

      result.fold(
        (failure) => emit(VisitError(
          message: _mapFailureToMessage(failure),
          isNetworkError: failure is NetworkFailure,
        )),
        (response) => emit(VisitLoaded(
          visits: response.data,
          currentPage: response.meta.currentPage,
          totalPages: response.meta.lastPage,
          hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
          statusFilter: currentState.statusFilter,
          visitTypeFilter: currentState.visitTypeFilter,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
        )),
      );
    } else {
      add(const LoadVisits());
    }
  }

  Future<void> _onFilterVisits(
    FilterVisits event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitLoading());

    final result = await getVisits(
      page: 1,
      status: event.status,
      visitType: event.visitType,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(VisitError(
        message: _mapFailureToMessage(failure),
        isNetworkError: failure is NetworkFailure,
      )),
      (response) => emit(VisitLoaded(
        visits: response.data,
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
        statusFilter: event.status,
        visitTypeFilter: event.visitType,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitLoading());

    final result = await getVisits(page: 1);

    result.fold(
      (failure) => emit(VisitError(
        message: _mapFailureToMessage(failure),
        isNetworkError: failure is NetworkFailure,
      )),
      (response) => emit(VisitLoaded(
        visits: response.data,
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
      )),
    );
  }

  Future<void> _onLoadVisitDetail(
    LoadVisitDetail event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitDetailLoading());

    final result = await getVisitDetail(event.visitId);

    result.fold(
      (failure) => emit(VisitError(
        message: _mapFailureToMessage(failure),
        isNetworkError: failure is NetworkFailure,
      )),
      (visit) => emit(VisitDetailLoaded(visit)),
    );
  }

  Future<void> _onLoadSalesVisits(
    LoadSalesVisits event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitLoading());

    final result = await getSalesVisits(salesId: event.salesId, page: 1);

    result.fold(
      (failure) => emit(VisitError(
        message: _mapFailureToMessage(failure),
        isNetworkError: failure is NetworkFailure,
      )),
      (response) => emit(VisitLoaded(
        visits: response.data,
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
      )),
    );
  }

  Future<void> _onLoadMoreSalesVisits(
    LoadMoreSalesVisits event,
    Emitter<VisitState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VisitLoaded || currentState.hasReachedMax) {
      return;
    }

    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await getSalesVisits(
      salesId: event.salesId,
      page: nextPage,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (response) => emit(currentState.copyWith(
        visits: [...currentState.visits, ...response.data],
        currentPage: response.meta.currentPage,
        totalPages: response.meta.lastPage,
        hasReachedMax: response.meta.currentPage >= response.meta.lastPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onCreateVisit(
    CreateVisitEvent event,
    Emitter<VisitState> emit,
  ) async {
    emit(const VisitCreating());

    final result = await createVisit(event.params);

    result.fold(
      (failure) => emit(VisitError(
        message: _mapFailureToMessage(failure),
        isNetworkError: failure is NetworkFailure,
      )),
      (visit) => emit(VisitCreated(visit)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Tidak ada koneksi internet';
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is AuthFailure) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (failure is TimeoutFailure) {
      return 'Koneksi timeout. Silakan coba lagi.';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
