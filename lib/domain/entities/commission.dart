import 'package:equatable/equatable.dart';

/// Commission entity representing sales commission
class Commission extends Equatable {
  final int id;
  final int salesId;
  final int transactionId;
  final double amount;
  final double percentage;
  final CommissionStatus status;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime? paidAt;
  final String? salesName;
  final String? transactionCode;

  const Commission({
    required this.id,
    required this.salesId,
    required this.transactionId,
    required this.amount,
    required this.percentage,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    this.paidAt,
    this.salesName,
    this.transactionCode,
  });

  /// Check if commission is paid
  bool get isPaid => status == CommissionStatus.paid;

  /// Check if commission is pending
  bool get isPending => status == CommissionStatus.pending;

  @override
  List<Object?> get props => [
        id,
        salesId,
        transactionId,
        amount,
        percentage,
        status,
        periodStart,
        periodEnd,
        paidAt,
        salesName,
        transactionCode,
      ];
}

/// Commission status enum
enum CommissionStatus {
  pending,
  approved,
  paid,
  cancelled,
}

/// Extension for CommissionStatus
extension CommissionStatusX on CommissionStatus {
  String get displayName {
    switch (this) {
      case CommissionStatus.pending:
        return 'Menunggu';
      case CommissionStatus.approved:
        return 'Disetujui';
      case CommissionStatus.paid:
        return 'Dibayar';
      case CommissionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String get value {
    switch (this) {
      case CommissionStatus.pending:
        return 'pending';
      case CommissionStatus.approved:
        return 'approved';
      case CommissionStatus.paid:
        return 'paid';
      case CommissionStatus.cancelled:
        return 'cancelled';
    }
  }

  static CommissionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return CommissionStatus.pending;
      case 'approved':
        return CommissionStatus.approved;
      case 'paid':
        return CommissionStatus.paid;
      case 'cancelled':
        return CommissionStatus.cancelled;
      default:
        return CommissionStatus.pending;
    }
  }
}

/// Commission summary for dashboard
class CommissionSummary extends Equatable {
  final double totalEarnings;
  final double pendingAmount;
  final double paidAmount;
  final int totalTransactions;
  final DateTime periodStart;
  final DateTime periodEnd;

  const CommissionSummary({
    required this.totalEarnings,
    required this.pendingAmount,
    required this.paidAmount,
    required this.totalTransactions,
    required this.periodStart,
    required this.periodEnd,
  });

  factory CommissionSummary.empty() => CommissionSummary(
        totalEarnings: 0,
        pendingAmount: 0,
        paidAmount: 0,
        totalTransactions: 0,
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
      );

  @override
  List<Object?> get props => [
        totalEarnings,
        pendingAmount,
        paidAmount,
        totalTransactions,
        periodStart,
        periodEnd,
      ];
}
