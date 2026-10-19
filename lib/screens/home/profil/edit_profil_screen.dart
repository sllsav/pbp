import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../utils/validators.dart';
import '../../../widgets/maroon_form.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _namaController = TextEditingController(text: user?.nama ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    user.nama = _namaController.text.trim();
    user.email = _emailController.text.trim();
    await _authService.updateProfile(user);

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaroonFormPage(
      title: 'Sunting Profil',
      subtitle: 'Perbarui nama dan email akunmu',
      icon: Icons.manage_accounts,
      formKey: _formKey,
      children: [
        MaroonField(
          controller: _namaController,
          label: 'Nama',
          icon: Icons.person_outline,
          validator: (v) => Validators.validateNotEmpty(v, 'Nama'),
        ),
        const SizedBox(height: 16),
        MaroonField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 28),
        MaroonButton(label: 'Simpan', loading: _isLoading, onPressed: _simpan),
      ],
    );
  }
}
