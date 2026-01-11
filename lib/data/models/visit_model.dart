import '../../domain/entities/area.dart' as area_entity;
import '../../domain/entities/visit.dart';
import 'area_model.dart' as area_model;
import 'user_model.dart';

/// Visit status extension
extension VisitStatusX on VisitStatus {
  String get value {
    switch (this) {
      case VisitStatus.pending:
        return 'pending';
      case VisitStatus.approved:
        return 'approved';
      case VisitStatus.rejected:
        return 'rejected';
    }
  }

  static VisitStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'approved':
        return VisitStatus.approved;
      case 'rejected':
        return VisitStatus.rejected;
      case 'pending':
      default:
        return VisitStatus.pending;
    }
  }
}

/// Visit type extension
extension VisitTypeX on VisitType {
  String get value {
    switch (this) {
      case VisitType.routine:
        return 'routine';
      case VisitType.prospecting:
        return 'prospecting';
      case VisitType.followUp:
        return 'follow_up';
      case VisitType.complaint:
        return 'complaint';
      case VisitType.other:
        return 'other';
    }
  }

  static VisitType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'prospecting':
        return VisitType.prospecting;
      case 'follow_up':
        return VisitType.followUp;
      case 'complaint':
        return VisitType.complaint;
      case 'other':
        return VisitType.other;
      case 'routine':
      default:
        return VisitType.routine;
    }
  }
}

/// Visit model - data layer
class VisitModel extends Visit {
  const VisitModel({
    required super.id,
    required super.visitNumber,
    required super.branchId,
    super.branchName,
    required super.salesId,
    super.salesName,
    super.areaId,
    super.areaName,
    required super.customerName,
    super.customerPhone,
    super.customerAddress,
    super.visitType,
    super.purpose,
    super.result,
    super.notes,
    super.latitude,
    super.longitude,
    super.photo,
    super.status,
    super.approverId,
    super.approverName,
    super.approvedAt,
    super.rejectionReason,
    required super.visitDate,
    super.sales,
    super.area,
    super.approver,
    super.createdAt,
    super.updatedAt,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: _parseInt(json['id']),
      visitNumber: json['visit_number'] ?? '',
      branchId: _parseInt(json['branch_id']),
      branchName: json['branch_name'] ?? json['branch']?['name'],
      salesId: _parseInt(json['sales_id']),
      salesName: json['sales_name'] ?? json['sales']?['name'],
      areaId: _parseIntNullable(json['area_id']),
      areaName: json['area_name'] ?? json['area']?['name'],
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      visitType: VisitTypeX.fromString(json['visit_type']),
      purpose: json['purpose'],
      result: json['result'],
      notes: json['notes'],
      latitude: _parseDoubleNullable(json['latitude']),
      longitude: _parseDoubleNullable(json['longitude']),
      photo: json['photo'],
      status: VisitStatusX.fromString(json['status']),
      approverId: _parseIntNullable(json['approver_id']),
      approverName: json['approver_name'] ?? json['approver']?['name'],
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'])
          : null,
      rejectionReason: json['rejection_reason'],
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'])
          : DateTime.now(),
      sales: json['sales'] != null
          ? UserModel.fromJson(json['sales']).toEntity()
          : null,
      area: json['area'] != null ? _parseArea(json['area']) : null,
      approver: json['approver'] != null
          ? UserModel.fromJson(json['approver']).toEntity()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static area_entity.Area? _parseArea(dynamic json) {
    if (json == null) return null;
    final model = area_model.AreaModel.fromJson(json as Map<String, dynamic>);
    return area_entity.Area(
      id: model.id,
      name: model.name,
      code: model.code,
      description: model.description,
      isActive: model.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visit_number': visitNumber,
      'branch_id': branchId,
      'sales_id': salesId,
      if (areaId != null) 'area_id': areaId,
      'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (customerAddress != null) 'customer_address': customerAddress,
      'visit_type': visitType.value,
      if (purpose != null) 'purpose': purpose,
      if (result != null) 'result': result,
      if (notes != null) 'notes': notes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (photo != null) 'photo': photo,
      'status': status.value,
      'visit_date': visitDate.toIso8601String(),
    };
  }

  Visit toEntity() => Visit(
    id: id,
    visitNumber: visitNumber,
    branchId: branchId,
    branchName: branchName,
    salesId: salesId,
    salesName: salesName,
    areaId: areaId,
    areaName: areaName,
    customerName: customerName,
    customerPhone: customerPhone,
    customerAddress: customerAddress,
    visitType: visitType,
    purpose: purpose,
    result: result,
    notes: notes,
    latitude: latitude,
    longitude: longitude,
    photo: photo,
    status: status,
    approverId: approverId,
    approverName: approverName,
    approvedAt: approvedAt,
    rejectionReason: rejectionReason,
    visitDate: visitDate,
    sales: sales,
    area: area,
    approver: approver,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

/// Visit statistics model
class VisitStatisticsModel extends VisitStatistics {
  const VisitStatisticsModel({
    super.total,
    super.pending,
    super.approved,
    super.rejected,
    super.today,
    super.thisWeek,
    super.thisMonth,
  });

  factory VisitStatisticsModel.fromJson(Map<String, dynamic> json) {
    return VisitStatisticsModel(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      today: json['today'] ?? 0,
      thisWeek: json['this_week'] ?? 0,
      thisMonth: json['this_month'] ?? 0,
    );
  }

  VisitStatistics toEntity() => VisitStatistics(
    total: total,
    pending: pending,
    approved: approved,
    rejected: rejected,
    today: today,
    thisWeek: thisWeek,
    thisMonth: thisMonth,
  );
}
