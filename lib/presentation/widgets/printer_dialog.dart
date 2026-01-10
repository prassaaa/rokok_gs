import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';

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
  List<BluetoothDevice> _devices = [];
  bool _isLoading = true;
  bool _isConnecting = false;
  String? _error;
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isAvailable = await widget.printService.isBluetoothAvailable();
      if (!isAvailable) {
        setState(() {
          _error = 'Bluetooth tidak tersedia';
          _isLoading = false;
        });
        return;
      }

      final devices = await widget.printService.getPairedDevices();
      final isConnected = await widget.printService.isConnected();

      setState(() {
        _devices = devices;
        _isLoading = false;
        if (isConnected && devices.isNotEmpty) {
          // Try to find connected device
          _connectedDevice = devices.first;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat perangkat: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      // Disconnect first if already connected
      final isConnected = await widget.printService.isConnected();
      if (isConnected) {
        await widget.printService.disconnect();
      }

      final success = await widget.printService.connect(device);
      
      if (success) {
        setState(() {
          _connectedDevice = device;
          _isConnecting = false;
        });
        widget.onConnected();
      } else {
        setState(() {
          _error = 'Gagal terhubung ke ${device.name}';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isConnecting = false;
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
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        if (_connectedDevice != null)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Print Sekarang'),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadDevices,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      );
    }

    if (_devices.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bluetooth_disabled, color: Colors.grey[400], size: 48),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada printer yang dipasangkan.\nPasangkan printer di pengaturan Bluetooth.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadDevices,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_connectedDevice != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Terhubung: ${_connectedDevice!.name}',
                    style: const TextStyle(color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        const Text(
          'Perangkat Tersedia:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final device = _devices[index];
            final isConnected = _connectedDevice?.address == device.address;
            
            return ListTile(
              leading: Icon(
                Icons.print,
                color: isConnected ? AppColors.success : AppColors.textSecondary,
              ),
              title: Text(device.name ?? 'Unknown'),
              subtitle: Text(device.address ?? ''),
              trailing: _isConnecting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : isConnected
                      ? const Icon(Icons.check, color: AppColors.success)
                      : const Icon(Icons.bluetooth, color: AppColors.primary),
              onTap: _isConnecting ? null : () => _connectToDevice(device),
            );
          },
        ),
      ],
    );
  }
}
