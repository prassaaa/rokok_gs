import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

import '../../domain/entities/transaction.dart';
import '../constants/asset_constants.dart';

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

  /// Load and process logo image for thermal printing
  Future<Uint8List?> _loadLogoImage() async {
    try {
      final ByteData data = await rootBundle.load(AssetConstants.logo);
      final Uint8List bytes = data.buffer.asUint8List();
      return bytes;
    } catch (e) {
      debugPrint('Error loading logo: $e');
      return null;
    }
  }

  /// Convert image to ESC/POS bitmap format for thermal printer
  /// Thermal printers typically support 58mm (384 dots) or 80mm (576 dots) width
  List<int> _imageToEscPosBitmap(img.Image image, {int printerWidth = 384}) {
    // Resize image to fit printer width while maintaining aspect ratio
    final int targetWidth = printerWidth;
    final double aspectRatio = image.height / image.width;
    final int targetHeight = (targetWidth * aspectRatio).round();

    // Resize and convert to grayscale
    img.Image resized = img.copyResize(image, width: targetWidth, height: targetHeight);
    img.Image grayscale = img.grayscale(resized);

    // Ensure height is multiple of 8 for printing
    final int printHeight = ((grayscale.height + 7) ~/ 8) * 8;

    List<int> bytes = [];

    // ESC/POS command for bitmap mode
    // GS v 0 - Print raster bit image
    final int widthBytes = (targetWidth + 7) ~/ 8;

    bytes.add(0x1D); // GS
    bytes.add(0x76); // v
    bytes.add(0x30); // 0
    bytes.add(0x00); // Normal mode (1:1)
    bytes.add(widthBytes & 0xFF); // xL
    bytes.add((widthBytes >> 8) & 0xFF); // xH
    bytes.add(printHeight & 0xFF); // yL
    bytes.add((printHeight >> 8) & 0xFF); // yH

    // Convert image to bitmap data
    for (int y = 0; y < printHeight; y++) {
      for (int xByte = 0; xByte < widthBytes; xByte++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final int x = xByte * 8 + bit;
          if (x < targetWidth && y < grayscale.height) {
            final pixel = grayscale.getPixel(x, y);
            // Get luminance (grayscale value)
            final int luminance = img.getLuminance(pixel).toInt();
            // Threshold: if dark enough, set bit (print dot)
            if (luminance < 128) {
              byte |= (0x80 >> bit);
            }
          }
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }

  /// Print logo image
  Future<bool> _printLogo() async {
    try {
      final logoBytes = await _loadLogoImage();
      if (logoBytes == null) return false;

      // Decode image
      final img.Image? image = img.decodeImage(logoBytes);
      if (image == null) {
        debugPrint('Failed to decode logo image');
        return false;
      }

      // Convert to ESC/POS bitmap (use 200 width for a reasonable logo size)
      final bitmapBytes = _imageToEscPosBitmap(image, printerWidth: 200);

      // Center the logo
      List<int> centerCommand = [0x1B, 0x61, 0x01]; // ESC a 1 (center)
      await _printBytes(centerCommand);

      // Print the bitmap
      await _printBytes(bitmapBytes);

      // Add line feed after logo
      await _printBytes([0x0A]);

      return true;
    } catch (e) {
      debugPrint('Error printing logo: $e');
      return false;
    }
  }
  
  /// Print transaction receipt
  Future<bool> printReceipt(Transaction transaction, {String? storeName}) async {
    if (!isConnected) return false;

    try {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');

      // ESC/POS commands
      const esc = '\x1B';
      const gs = '\x1D';

      // Initialize printer
      await _printBytes(utf8.encode('$esc@'));

      // Print logo at the top
      await _printLogo();

      final receipt = StringBuffer();

      // Center align
      receipt.write('${esc}a\x01');

      // Bold on, double height
      receipt.write('${esc}E\x01');
      receipt.write('$gs!\x10');
      receipt.writeln(storeName ?? 'ROKOK GS');

      // Normal size
      receipt.write('$gs!\x00');
      receipt.write('${esc}E\x00');

      receipt.writeln('Gunung Sari Sigaret Kretek');
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
      receipt.writeln('Terima Kasih Atas Kerjasamanya');
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
