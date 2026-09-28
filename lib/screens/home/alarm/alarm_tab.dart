import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/alarm_model.dart';
import '../../../services/alarm_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/alarm_item_card.dart';
import 'tambah_alarm_screen.dart';

class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});
  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  final _alarmService = AlarmService();
  List<AlarmModel> _alarms = [];
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAlarm();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadAlarm() async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    final alarms = await _alarmService.getAlarmByUser(userId);
    if (mounted) setState(() => _alarms = alarms);
  }

  Future<void> _tambahAlarm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahAlarmScreen()),
    );
    _loadAlarm();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          // IntrinsicHeight WAJIB ada supaya Row + CrossAxisAlignment.stretch
          // punya tinggi pasti sebelum di-layout (menghindari error blank screen).
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card "Waktu sekarang" + tombol Informasi (kiri)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBEAEA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Waktu sekarang',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('HH.mm.ss').format(_now),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          DateFormat('d MMMM yyyy').format(_now),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Informasi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Card "Peduli" (kanan)
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFE2E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Peduli',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Text(
                          'Terhadap lambungmu',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alaram',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: _tambahAlarm,
              ),
            ],
          ),
        ),
        Expanded(
          child: _alarms.isEmpty
              ? const Center(child: Text('Belum ada alarm'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _alarms.length,
                  itemBuilder: (_, index) {
                    final alarm = _alarms[index];
                    return AlarmItemCard(
                      alarm: alarm,
                      onToggle: (value) async {
                        await _alarmService.toggleAktif(alarm.id!, value);
                        _loadAlarm();
                      },
                      onDelete: () async {
                        await _alarmService.hapusAlarm(alarm.id!);
                        _loadAlarm();
                      },
                    );
                  },
                ),
        ),
      ],
    ),
  );
}