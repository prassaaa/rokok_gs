import 'package:equatable/equatable.dart';

/// Area entity representing sales area/region
class Area extends Equatable {
  final int id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;

  const Area({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, code, description, isActive];
}
