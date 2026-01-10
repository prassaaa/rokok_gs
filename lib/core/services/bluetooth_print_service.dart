import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/transaction.dart';

/// Service untuk print struk via Bluetooth thermal printer
class BluetoothPrintService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;
  
  /// Check if Bluetooth is available
  Future<bool> isBluetoothAvailable() async {
    return await _printer.isAvailable ?? false;
  }
  
  /// Check if connected to printer
  Future<bool> isConnected() async {
    return await _printer.isConnected ?? false;
  }
  
  /// Get paired Bluetooth devices
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await _printer.getBondedDevices();
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      return [];
    }
  }
  
  /// Connect to a Bluetooth device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _printer.connect(device);
      return true;
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      return false;
    }
  }
  
  /// Disconnect from printer
  Future<void> disconnect() async {
    try {
      await _printer.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }
  
  /// Print transaction receipt
  Future<bool> printReceipt(Transaction transaction, {String? storeName, String? storeAddress}) async {
    try {
      final isConnectedNow = await isConnected();
      if (!isConnectedNow) {
        return false;
      }
      
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
      
      // Header
      _printer.printNewLine();
      _printer.printCustom(storeName ?? 'ROKOK GS', 3, 1); // Size 3, Center
      if (storeAddress != null) {
        _printer.printCustom(storeAddress, 1, 1);
      }
      _printer.printCustom('================================', 1, 1);
      _printer.printNewLine();
      
      // Invoice info
      _printer.printLeftRight('No. Invoice:', transaction.invoiceNumber ?? '#${transaction.id}', 1);
      _printer.printLeftRight('Tanggal:', dateFormat.format(transaction.transactionDate), 1);
      _printer.printLeftRight('Kasir:', transaction.salesName ?? '-', 1);
      _printer.printLeftRight('Pelanggan:', transaction.customerName ?? 'Umum', 1);
      
      _printer.printCustom('--------------------------------', 1, 1);
      
      // Items
      for (final item in transaction.items) {
        _printer.printCustom(item.productName, 1, 0); // Left align
        _printer.printLeftRight(
          '  ${item.quantity} x ${_formatCurrency(item.price)}',
          _formatCurrency(item.subtotal),
          1,
        );
      }
      
      _printer.printCustom('--------------------------------', 1, 1);
      
      // Totals
      _printer.printLeftRight('Subtotal:', _formatCurrency(transaction.subtotal), 1);
      
      if (transaction.hasDiscount) {
        _printer.printLeftRight('Diskon:', '- ${_formatCurrency(transaction.discount)}', 1);
      }
      
      if (transaction.tax > 0) {
        _printer.printLeftRight('Pajak:', _formatCurrency(transaction.tax), 1);
      }
      
      _printer.printCustom('================================', 1, 1);
      _printer.printLeftRight('TOTAL:', _formatCurrency(transaction.total), 2); // Size 2
      _printer.printCustom('================================', 1, 1);
      
      // Payment method
      _printer.printLeftRight('Pembayaran:', _getPaymentMethodText(transaction.paymentMethod), 1);
      
      _printer.printNewLine();
      
      // Footer
      _printer.printCustom('Terima Kasih', 2, 1);
      _printer.printCustom('Atas Kunjungan Anda', 1, 1);
      _printer.printNewLine();
      _printer.printNewLine();
      _printer.printNewLine();
      
      return true;
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      return false;
    }
  }
  
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
  
  String _getPaymentMethodText(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer';
      case PaymentMethod.credit:
        return 'Kredit';
      default:
        return '-';
    }
  }
}
