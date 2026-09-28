import 'package:flutter/material.dart';

import '../../../models/alarm_model.dart';
import '../../../services/alarm_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_textfield.dart';

class TambahAlarmScreen extends StatefulWidget {
  const TambahAlarmScreen({super.key});

  @override
  State<TambahAlarmScreen> createState() => _TambahAlarmScreenState();
}

class _TambahAlarmScreenState extends State<TambahAlarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController(text: 'Waktu makan');
  final _deskripsiController = TextEditingController(
    text: 'Waktunya makan sesuai jadwal',
  );
  final _alarmService = AlarmService();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Pilih waktu makan',
    );
    if (picked != null && mounted) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final time =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    try {
      await _alarmService.tambahAlarm(
        AlarmModel(
          userId: userId,
          jam: time,
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarm makan berhasil disimpan')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan alarm: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Alarm Makan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.access_time,
                    color: AppColors.primary,
                  ),
                  title: const Text('Waktu makan'),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: const Icon(Icons.edit),
                  onTap: _pickTime,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _judulController,
                  label: 'Judul',
                  icon: Icons.restaurant,
                  validator: (value) =>
                      Validators.validateNotEmpty(value, 'Judul'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _deskripsiController,
                  label: 'Deskripsi',
                  icon: Icons.description_outlined,
                  validator: (value) =>
                      Validators.validateNotEmpty(value, 'Deskripsi'),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.notifications_active),
                  label: Text(
                    _isSaving
                        ? 'Menyimpan...'
                        : 'Simpan dan Aktifkan Notifikasi',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Notifikasi akan muncul setiap hari pada waktu yang dipilih di perangkat Android/iOS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
