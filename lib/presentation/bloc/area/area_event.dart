import 'package:equatable/equatable.dart';

/// Events for AreaBloc
abstract class AreaEvent extends Equatable {
  const AreaEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all areas
class LoadAreas extends AreaEvent {
  const LoadAreas();
}

/// Event to load area by ID
class LoadAreaById extends AreaEvent {
  final int id;

  const LoadAreaById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to refresh areas
class RefreshAreas extends AreaEvent {
  const RefreshAreas();
}

/// Event to search areas
class SearchAreas extends AreaEvent {
  final String query;

  const SearchAreas(this.query);

  @override
  List<Object?> get props => [query];
}
