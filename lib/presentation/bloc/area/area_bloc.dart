import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/usecase.dart';
import '../../../domain/usecases/area/get_area_by_id.dart';
import '../../../domain/usecases/area/get_areas.dart';
import 'area_event.dart';
import 'area_state.dart';

/// BLoC for managing area state
class AreaBloc extends Bloc<AreaEvent, AreaState> {
  final GetAreas getAreas;
  final GetAreaById getAreaById;

  AreaBloc({
    required this.getAreas,
    required this.getAreaById,
  }) : super(const AreaInitial()) {
    on<LoadAreas>(_onLoadAreas);
    on<LoadAreaById>(_onLoadAreaById);
    on<RefreshAreas>(_onRefreshAreas);
    on<SearchAreas>(_onSearchAreas);
  }

  Future<void> _onLoadAreas(
    LoadAreas event,
    Emitter<AreaState> emit,
  ) async {
    emit(const AreaLoading());

    final result = await getAreas(NoParams());

    result.fold(
      (failure) => emit(AreaError(failure.message)),
      (areas) => emit(AreasLoaded(areas: areas)),
    );
  }

  Future<void> _onLoadAreaById(
    LoadAreaById event,
    Emitter<AreaState> emit,
  ) async {
    emit(const AreaLoading());

    final result = await getAreaById(GetAreaByIdParams(id: event.id));

    result.fold(
      (failure) => emit(AreaError(failure.message)),
      (area) => emit(AreaDetailLoaded(area)),
    );
  }

  Future<void> _onRefreshAreas(
    RefreshAreas event,
    Emitter<AreaState> emit,
  ) async {
    final result = await getAreas(NoParams());

    result.fold(
      (failure) => emit(AreaError(failure.message)),
      (areas) => emit(AreasLoaded(areas: areas)),
    );
  }

  void _onSearchAreas(
    SearchAreas event,
    Emitter<AreaState> emit,
  ) {
    final currentState = state;
    if (currentState is AreasLoaded) {
      final query = event.query.toLowerCase();
      
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredAreas: currentState.areas,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.areas.where((area) {
          return area.name.toLowerCase().contains(query) ||
              area.code.toLowerCase().contains(query) ||
              (area.description?.toLowerCase().contains(query) ?? false);
        }).toList();

        emit(currentState.copyWith(
          filteredAreas: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}
