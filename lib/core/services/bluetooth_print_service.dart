import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/transaction.dart';

/// Service untuk print struk via Bluetooth thermal printer
class BluetoothPrintService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  
  /// Check if Bluetooth is available and on
  Future<bool> isBluetoothAvailable() async {
    try {
      return await FlutterBluePlus.isSupported;
    } catch (e) {
      debugPrint('Error checking Bluetooth: $e');
      return false;
    }
  }
  
  /// Check if Bluetooth is on
  Future<bool> isBluetoothOn() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if connected to printer
  bool get isConnected => _connectedDevice != null && _writeCharacteristic != null;
  
  /// Get bonded/paired devices
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      // Get system devices (bonded devices) - requires service UUIDs for filtering
      final devices = await FlutterBluePlus.systemDevices([]);
      return devices;
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      return [];
    }
  }
  
  /// Scan for nearby Bluetooth devices
  Stream<List<ScanResult>> scanDevices() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }
  
  /// Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }
  
  /// Connect to a Bluetooth device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find writable characteristic (common for thermal printers)
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
            _connectedDevice = device;
            debugPrint('Connected to ${device.platformName}');
            return true;
          }
        }
      }
      
      debugPrint('No writable characteristic found');
      return false;
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      return false;
    }
  }
  
  /// Disconnect from printer
  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
      _connectedDevice = null;
      _writeCharacteristic = null;
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }
  
  /// Print raw bytes to printer
  Future<bool> _printBytes(List<int> bytes) async {
    if (_writeCharacteristic == null) return false;
    
    try {
      // Split into chunks (BLE has MTU limit)
      const chunkSize = 100;
      for (var i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        final chunk = bytes.sublist(i, end);
        await _writeCharacteristic!.write(chunk, withoutResponse: true);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return true;
    } catch (e) {
      debugPrint('Error printing: $e');
      return false;
    }
  }
  
  /// Print transaction receipt
  Future<bool> printReceipt(Transaction transaction, {String? storeName, String? storeAddress}) async {
    if (!isConnected) return false;
    
    try {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
      final receipt = StringBuffer();
      
      // ESC/POS commands
      const esc = '\x1B';
      const gs = '\x1D';
      
      // Initialize printer
      receipt.write('$esc@'); // Initialize
      
      // Center align
      receipt.write('${esc}a\x01');
      
      // Bold on, double height
      receipt.write('${esc}E\x01');
      receipt.write('$gs!\x10');
      receipt.writeln(storeName ?? 'ROKOK GS');
      
      // Normal size
      receipt.write('$gs!\x00');
      receipt.write('${esc}E\x00');
      
      if (storeAddress != null) {
        receipt.writeln(storeAddress);
      }
      receipt.writeln('================================');
      receipt.writeln('');
      
      // Left align
      receipt.write('${esc}a\x00');
      
      // Invoice info
      receipt.writeln('No. Invoice: ${transaction.invoiceNumber ?? '#${transaction.id}'}');
      receipt.writeln('Tanggal    : ${dateFormat.format(transaction.transactionDate)}');
      receipt.writeln('Sales      : ${transaction.salesName ?? '-'}');
      receipt.writeln('Pelanggan  : ${transaction.customerName ?? 'Umum'}');
      receipt.writeln('--------------------------------');
      
      // Items
      for (final item in transaction.items) {
        receipt.writeln(item.productName);
        receipt.writeln('  ${item.quantity} x ${_formatCurrency(item.price).padLeft(10)} = ${_formatCurrency(item.subtotal).padLeft(10)}');
      }
      
      receipt.writeln('--------------------------------');
      
      // Totals
      receipt.writeln('Subtotal${_formatCurrency(transaction.subtotal).padLeft(24)}');
      
      if (transaction.hasDiscount) {
        receipt.writeln('Diskon${('- ${_formatCurrency(transaction.discount)}').padLeft(26)}');
      }
      
      receipt.writeln('================================');
      
      // Bold total
      receipt.write('${esc}E\x01');
      receipt.writeln('TOTAL${_formatCurrency(transaction.total).padLeft(27)}');
      receipt.write('${esc}E\x00');
      
      receipt.writeln('================================');
      receipt.writeln('Pembayaran : ${_getPaymentMethodText(transaction.paymentMethod)}');
      receipt.writeln('');
      
      // Center align footer
      receipt.write('${esc}a\x01');
      receipt.writeln('Terima Kasih');
      receipt.writeln('Atas Kunjungan Anda');
      receipt.writeln('');
      receipt.writeln('');
      receipt.writeln('');
      
      // Cut paper (if supported)
      receipt.write('${gs}V\x00');
      
      // Convert to bytes and print
      final bytes = utf8.encode(receipt.toString());
      return await _printBytes(bytes);
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
