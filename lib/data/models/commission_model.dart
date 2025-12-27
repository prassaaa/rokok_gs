import '../../domain/entities/commission.dart';

/// Commission model with JSON serialization
class CommissionModel extends Commission {
  const CommissionModel({
    required super.id,
    required super.salesId,
    required super.transactionId,
    required super.amount,
    required super.percentage,
    required super.status,
    required super.periodStart,
    required super.periodEnd,
    super.paidAt,
    super.salesName,
    super.transactionCode,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      id: json['id'] as int,
      salesId: json['sales_id'] as int,
      transactionId: json['transaction_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      status: CommissionStatusX.fromString(json['status'] as String? ?? 'pending'),
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'] as String)
          : DateTime.now(),
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'] as String)
          : DateTime.now(),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      salesName: json['sales']?['name'] as String? ?? json['sales_name'] as String?,
      transactionCode: json['transaction']?['code'] as String? ?? json['transaction_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sales_id': salesId,
        'transaction_id': transactionId,
        'amount': amount,
        'percentage': percentage,
        'status': status.value,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
        if (salesName != null) 'sales_name': salesName,
        if (transactionCode != null) 'transaction_code': transactionCode,
      };

  factory CommissionModel.fromEntity(Commission commission) {
    return CommissionModel(
      id: commission.id,
      salesId: commission.salesId,
      transactionId: commission.transactionId,
      amount: commission.amount,
      percentage: commission.percentage,
      status: commission.status,
      periodStart: commission.periodStart,
      periodEnd: commission.periodEnd,
      paidAt: commission.paidAt,
      salesName: commission.salesName,
      transactionCode: commission.transactionCode,
    );
  }
}

/// Commission summary model with JSON serialization
class CommissionSummaryModel extends CommissionSummary {
  const CommissionSummaryModel({
    required super.totalEarnings,
    required super.pendingAmount,
    required super.paidAmount,
    required super.totalTransactions,
    required super.periodStart,
    required super.periodEnd,
  });

  factory CommissionSummaryModel.fromJson(Map<String, dynamic> json) {
    return CommissionSummaryModel(
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: json['total_transactions'] as int? ?? 0,
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'] as String)
          : DateTime.now(),
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_earnings': totalEarnings,
        'pending_amount': pendingAmount,
        'paid_amount': paidAmount,
        'total_transactions': totalTransactions,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
      };
}
