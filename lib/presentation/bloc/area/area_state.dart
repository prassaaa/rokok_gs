import 'package:equatable/equatable.dart';

import '../../../domain/entities/area.dart';

/// States for AreaBloc
abstract class AreaState extends Equatable {
  const AreaState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AreaInitial extends AreaState {
  const AreaInitial();
}

/// Loading state
class AreaLoading extends AreaState {
  const AreaLoading();
}

/// Areas loaded successfully
class AreasLoaded extends AreaState {
  final List<Area> areas;
  final List<Area> filteredAreas;
  final String searchQuery;

  const AreasLoaded({
    required this.areas,
    List<Area>? filteredAreas,
    this.searchQuery = '',
  }) : filteredAreas = filteredAreas ?? areas;

  @override
  List<Object?> get props => [areas, filteredAreas, searchQuery];

  AreasLoaded copyWith({
    List<Area>? areas,
    List<Area>? filteredAreas,
    String? searchQuery,
  }) {
    return AreasLoaded(
      areas: areas ?? this.areas,
      filteredAreas: filteredAreas ?? this.filteredAreas,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Single area loaded
class AreaDetailLoaded extends AreaState {
  final Area area;

  const AreaDetailLoaded(this.area);

  @override
  List<Object?> get props => [area];
}

/// Error state
class AreaError extends AreaState {
  final String message;

  const AreaError(this.message);

  @override
  List<Object?> get props => [message];
}
