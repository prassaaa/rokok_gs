import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../core/services/bluetooth_print_service.dart';
import '../../core/theme/app_colors.dart';

/// Dialog untuk memilih dan connect ke printer Bluetooth
class PrinterDialog extends StatefulWidget {
  final BluetoothPrintService printService;
  final VoidCallback onConnected;

  const PrinterDialog({
    super.key,
    required this.printService,
    required this.onConnected,
  });

  @override
  State<PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<PrinterDialog> {
  List<BluetoothDevice> _pairedDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isLoading = true;
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _error;
  BluetoothDevice? _connectingDevice;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    widget.printService.stopScan();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isAvailable = await widget.printService.isBluetoothAvailable();
      if (!isAvailable) {
        setState(() {
          _error = 'Bluetooth tidak tersedia di perangkat ini';
          _isLoading = false;
        });
        return;
      }

      final isOn = await widget.printService.isBluetoothOn();
      if (!isOn) {
        setState(() {
          _error = 'Bluetooth tidak aktif. Silakan aktifkan Bluetooth.';
          _isLoading = false;
        });
        return;
      }

      // Get paired devices
      final paired = await widget.printService.getPairedDevices();
      
      setState(() {
        _pairedDevices = paired;
        _isLoading = false;
      });

      // Start scanning for nearby devices
      _startScan();
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat perangkat: $e';
        _isLoading = false;
      });
    }
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    _scanSubscription?.cancel();
    _scanSubscription = widget.printService.scanDevices().listen((results) {
      setState(() {
        // Filter to show only devices with names (likely printers)
        _scanResults = results.where((r) => 
          r.device.platformName.isNotEmpty
        ).toList();
      });
    });

    // Stop scan after timeout
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _connectingDevice = device;
      _error = null;
    });

    try {
      // Disconnect first if already connected
      if (widget.printService.isConnected) {
        await widget.printService.disconnect();
      }

      final success = await widget.printService.connect(device);
      
      if (success) {
        widget.onConnected();
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _error = 'Gagal terhubung ke ${device.platformName}';
          _isConnecting = false;
          _connectingDevice = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isConnecting = false;
        _connectingDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.print, color: AppColors.primary),
          SizedBox(width: 12),
          Text('Pilih Printer'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        if (!_isScanning && !_isLoading)
          TextButton.icon(
            onPressed: _startScan,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Scan Ulang'),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _initialize,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Paired devices section
          if (_pairedDevices.isNotEmpty) ...[
            const Text(
              'Perangkat Tersimpan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._pairedDevices.map((device) => _buildDeviceTile(device)),
            const Divider(height: 24),
          ],
          
          // Scanned devices section
          Row(
            children: [
              const Text(
                'Perangkat Terdekat:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_isScanning) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          
          if (_scanResults.isEmpty && !_isScanning)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tidak ada perangkat ditemukan.\nPastikan printer dalam mode pairing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ..._scanResults.map((result) => _buildDeviceTile(result.device)),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(BluetoothDevice device) {
    final isConnecting = _connectingDevice?.remoteId == device.remoteId;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.print,
        color: isConnecting ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        device.remoteId.str,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: isConnecting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.bluetooth, color: AppColors.primary, size: 20),
      onTap: _isConnecting ? null : () => _connectToDevice(device),
    );
  }
}
