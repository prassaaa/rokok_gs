import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/visit.dart';
import '../../bloc/visit/visit_bloc.dart';
import '../../bloc/visit/visit_event.dart';
import '../../bloc/visit/visit_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Visit form page
class VisitFormPage extends StatefulWidget {
  const VisitFormPage({super.key});

  @override
  State<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends State<VisitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _purposeController = TextEditingController();
  final _resultController = TextEditingController();
  final _notesController = TextEditingController();

  VisitType _selectedVisitType = VisitType.routine;
  File? _selectedPhoto;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _purposeController.dispose();
    _resultController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final pickedFile = await picker.pickImage(source: result);
      if (pickedFile != null) {
        setState(() {
          _selectedPhoto = File(pickedFile.path);
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final params = CreateVisitParams(
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text.isEmpty
            ? null
            : _customerPhoneController.text,
        customerAddress: _customerAddressController.text.isEmpty
            ? null
            : _customerAddressController.text,
        visitType: _selectedVisitType,
        purpose: _purposeController.text.isEmpty
            ? null
            : _purposeController.text,
        result: _resultController.text.isEmpty ? null : _resultController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        photoPath: _selectedPhoto?.path,
      );

      context.read<VisitBloc>().add(CreateVisitEvent(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kunjungan Baru')),
      body: BlocConsumer<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kunjungan berhasil dibuat')),
            );
            context.pop();
          } else if (state is VisitError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is VisitCreating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _customerNameController,
                    label: 'Nama Pelanggan',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama pelanggan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _customerPhoneController,
                    label: 'No. Telepon',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _customerAddressController,
                    label: 'Alamat',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tipe Kunjungan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: VisitType.values.map((type) {
                      return ChoiceChip(
                        label: Text(_getVisitTypeText(type)),
                        selected: _selectedVisitType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedVisitType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _purposeController,
                    label: 'Tujuan Kunjungan',
                    prefixIcon: const Icon(Icons.assignment_outlined),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _resultController,
                    label: 'Hasil Kunjungan',
                    prefixIcon: const Icon(Icons.description_outlined),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _notesController,
                    label: 'Catatan',
                    prefixIcon: const Icon(Icons.notes),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildPhotoSection(),
                  const SizedBox(height: 16),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Simpan Kunjungan',
                    onPressed: isLoading ? null : _submitForm,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Kunjungan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (_selectedPhoto != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedPhoto!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => _selectedPhoto = null),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Ambil Foto'),
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: _currentPosition != null
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentPosition != null
                        ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                              'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}'
                        : 'Lokasi tidak tersedia',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoadingLocation)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _getCurrentLocation,
              ),
          ],
        ),
      ),
    );
  }

  String _getVisitTypeText(VisitType type) {
    switch (type) {
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
}
