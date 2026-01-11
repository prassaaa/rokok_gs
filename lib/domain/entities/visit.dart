import 'package:equatable/equatable.dart';

import 'area.dart' as area_entity;
import 'user.dart';

/// Visit status enum
enum VisitStatus { pending, approved, rejected }

/// Visit type enum
enum VisitType { routine, prospecting, followUp, complaint, other }

/// Visit entity - domain layer
class Visit extends Equatable {
  final int id;
  final String visitNumber;
  final int branchId;
  final String? branchName;
  final int salesId;
  final String? salesName;
  final int? areaId;
  final String? areaName;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final VisitType visitType;
  final String? purpose;
  final String? result;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final String? photo;
  final VisitStatus status;
  final int? approverId;
  final String? approverName;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime visitDate;
  final User? sales;
  final area_entity.Area? area;
  final User? approver;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Visit({
    required this.id,
    required this.visitNumber,
    required this.branchId,
    this.branchName,
    required this.salesId,
    this.salesName,
    this.areaId,
    this.areaName,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.visitType = VisitType.routine,
    this.purpose,
    this.result,
    this.notes,
    this.latitude,
    this.longitude,
    this.photo,
    this.status = VisitStatus.pending,
    this.approverId,
    this.approverName,
    this.approvedAt,
    this.rejectionReason,
    required this.visitDate,
    this.sales,
    this.area,
    this.approver,
    this.createdAt,
    this.updatedAt,
  });

  /// Get status text
  String get statusText {
    switch (status) {
      case VisitStatus.pending:
        return 'Menunggu';
      case VisitStatus.approved:
        return 'Disetujui';
      case VisitStatus.rejected:
        return 'Ditolak';
    }
  }

  /// Get visit type text
  String get visitTypeText {
    switch (visitType) {
      case VisitType.routine:
        return 'Rutin';
      case VisitType.prospecting:
        return 'Prospek';
      case VisitType.followUp:
        return 'Follow Up';
      case VisitType.complaint:
        return 'Komplain';
      case VisitType.other:
        return 'Lainnya';
    }
  }

  /// Check if has location
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if has photo
  bool get hasPhoto => photo != null && photo!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    visitNumber,
    branchId,
    branchName,
    salesId,
    salesName,
    areaId,
    areaName,
    customerName,
    customerPhone,
    customerAddress,
    visitType,
    purpose,
    result,
    notes,
    latitude,
    longitude,
    photo,
    status,
    approverId,
    approverName,
    approvedAt,
    rejectionReason,
    visitDate,
    sales,
    area,
    approver,
    createdAt,
    updatedAt,
  ];
}

/// Create visit params
class CreateVisitParams extends Equatable {
  final int? areaId;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final VisitType visitType;
  final String? purpose;
  final String? result;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final String? photoPath; // Path to photo file

  const CreateVisitParams({
    this.areaId,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.visitType = VisitType.routine,
    this.purpose,
    this.result,
    this.notes,
    this.latitude,
    this.longitude,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
    if (areaId != null) 'area_id': areaId,
    'customer_name': customerName,
    if (customerPhone != null) 'customer_phone': customerPhone,
    if (customerAddress != null) 'customer_address': customerAddress,
    'visit_type': _visitTypeToString(visitType),
    if (purpose != null) 'purpose': purpose,
    if (result != null) 'result': result,
    if (notes != null) 'notes': notes,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  String _visitTypeToString(VisitType type) {
    switch (type) {
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

  @override
  List<Object?> get props => [
    areaId,
    customerName,
    customerPhone,
    customerAddress,
    visitType,
    purpose,
    result,
    notes,
    latitude,
    longitude,
    photoPath,
  ];
}

/// Visit statistics
class VisitStatistics extends Equatable {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int today;
  final int thisWeek;
  final int thisMonth;

  const VisitStatistics({
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.today = 0,
    this.thisWeek = 0,
    this.thisMonth = 0,
  });

  @override
  List<Object?> get props => [
    total,
    pending,
    approved,
    rejected,
    today,
    thisWeek,
    thisMonth,
  ];
}
