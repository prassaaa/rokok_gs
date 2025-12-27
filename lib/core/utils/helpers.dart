import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../theme/app_colors.dart';

/// Helper utility functions
class Helpers {
  Helpers._();

  /// Show toast message
  static void showToast(
    String message, {
    ToastType type = ToastType.info,
    Toast length = Toast.LENGTH_SHORT,
  }) {
    Color backgroundColor;
    switch (type) {
      case ToastType.success:
        backgroundColor = AppColors.success;
        break;
      case ToastType.error:
        backgroundColor = AppColors.error;
        break;
      case ToastType.warning:
        backgroundColor = AppColors.warning;
        break;
      case ToastType.info:
        backgroundColor = AppColors.textPrimary;
        break;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: AppColors.white,
      fontSize: 14,
    );
  }

  /// Debounce function
  static Timer? _debounceTimer;
  static void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  /// Cancel debounce
  static void cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'approved':
        return AppColors.approved;
      case 'paid':
      case 'completed':
        return AppColors.paid;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get status text in Indonesian
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'paid':
        return 'Dibayar';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  /// Get payment method text
  static String getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'transfer':
        return 'Transfer';
      case 'credit':
        return 'Kredit';
      default:
        return method;
    }
  }

  /// Generate invoice number
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5);
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$timestamp';
  }

  /// Calculate percentage
  static double calculatePercentage(num value, num total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  /// Mask phone number
  static String maskPhone(String phone) {
    if (phone.length < 6) return phone;
    return '${phone.substring(0, 4)}****${phone.substring(phone.length - 4)}';
  }

  /// Format phone number
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length <= 4) return cleaned;
    if (cleaned.length <= 8) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4)}';
    }
    return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
  }
}

/// Toast type enum
enum ToastType {
  success,
  error,
  warning,
  info,
}
