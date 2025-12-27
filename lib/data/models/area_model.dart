import '../../domain/entities/area.dart';

/// Area model for API mapping
class AreaModel extends Area {
  const AreaModel({
    required super.id,
    required super.name,
    required super.code,
    super.description,
    required super.isActive,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'is_active': isActive,
    };
  }

  /// Convert entity to model
  factory AreaModel.fromEntity(Area area) {
    return AreaModel(
      id: area.id,
      name: area.name,
      code: area.code,
      description: area.description,
      isActive: area.isActive,
    );
  }
}
