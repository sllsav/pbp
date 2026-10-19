import 'package:flutter/material.dart';

import '../../../models/alarm_model.dart';
import '../../../services/alarm_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../widgets/maroon_form.dart';

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

  static const _judulCepat = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Camilan',
    'Minum Obat',
  ];

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

  /// Kartu waktu besar yang bisa diketuk untuk mengubah jam
  Widget _buildTimeCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55800020),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _pickTime,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu makan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Ubah',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaroonFormPage(
      title: 'Tambah Alarm Makan',
      subtitle: 'Atur pengingat agar lambungmu tetap terjaga',
      icon: Icons.alarm_add,
      formKey: _formKey,
      children: [
        _buildTimeCard(),
        const SizedBox(height: 16),
        MaroonField(
          controller: _judulController,
          label: 'Judul',
          icon: Icons.restaurant,
          validator: (value) => Validators.validateNotEmpty(value, 'Judul'),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final judul in _judulCepat)
              ActionChip(
                label: Text(judul),
                backgroundColor: const Color(0xFFF6E7EB),
                side: const BorderSide(color: AppColors.softBorder),
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                onPressed: () => setState(() => _judulController.text = judul),
              ),
          ],
        ),
        const SizedBox(height: 16),
        MaroonField(
          controller: _deskripsiController,
          label: 'Deskripsi',
          icon: Icons.description_outlined,
          validator: (value) => Validators.validateNotEmpty(value, 'Deskripsi'),
        ),
        const SizedBox(height: 28),
        MaroonButton(
          label: 'Simpan dan Aktifkan Notifikasi',
          icon: Icons.notifications_active,
          loading: _isSaving,
          onPressed: _save,
        ),
        const SizedBox(height: 14),
        const Text(
          'Notifikasi akan muncul setiap hari pada waktu yang dipilih di perangkat Android/iOS.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
      ],
    );
  }
}
