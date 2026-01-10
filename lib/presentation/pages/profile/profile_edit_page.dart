import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/custom_text_field.dart';

/// Profile edit page for updating user information
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated && state.errorMessage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil berhasil diperbarui'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Masukkan email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Nomor Telepon',
                    hint: 'Masukkan nomor telepon',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // Change password toggle
                  SwitchListTile(
                    title: const Text('Ubah Password'),
                    subtitle: const Text('Aktifkan untuk mengubah password'),
                    value: _changePassword,
                    onChanged: (value) {
                      setState(() {
                        _changePassword = value;
                        if (!value) {
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_changePassword) ...[
                    const SizedBox(height: 16),
                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password Baru',
                      hint: 'Masukkan password baru',
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (_changePassword && (value == null || value.isEmpty)) {
                          return 'Password tidak boleh kosong';
                        }
                        if (_changePassword && value != null && value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm password field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Masukkan ulang password baru',
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (_changePassword && value != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.status == AuthStatus.loading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.status == AuthStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthUpdateProfile(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
              password: _changePassword && _passwordController.text.isNotEmpty
                  ? _passwordController.text
                  : null,
            ),
          );
    }
  }
}
