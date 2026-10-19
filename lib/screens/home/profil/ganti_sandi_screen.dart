import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../utils/validators.dart';
import '../../../widgets/maroon_form.dart';

class GantiSandiScreen extends StatefulWidget {
  const GantiSandiScreen({super.key});

  @override
  State<GantiSandiScreen> createState() => _GantiSandiScreenState();
}

class _GantiSandiScreenState extends State<GantiSandiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sandiBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _sandiBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final error = await _authService.changePassword(_sandiBaruController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sandi berhasil diubah')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaroonFormPage(
      title: 'Ganti Sandi',
      subtitle: 'Gunakan sandi baru yang kuat dan mudah kamu ingat',
      icon: Icons.lock_reset,
      formKey: _formKey,
      children: [
        MaroonField(
          controller: _sandiBaruController,
          label: 'Sandi Baru',
          icon: Icons.lock_outline,
          obscureText: true,
          validator: Validators.validatePassword,
        ),
        const SizedBox(height: 16),
        MaroonField(
          controller: _konfirmasiController,
          label: 'Konfirmasi Sandi Baru',
          icon: Icons.lock_outline,
          obscureText: true,
          validator: (v) => Validators.validateConfirmPassword(
            v,
            _sandiBaruController.text,
          ),
        ),
        const SizedBox(height: 28),
        MaroonButton(label: 'Simpan', loading: _isLoading, onPressed: _simpan),
      ],
    );
  }
}
