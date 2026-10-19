import 'dart:async';
import 'dart:math' as math;

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

class _Preset {
  const _Preset(this.judul, this.jam, this.deskripsi, this.icon);
  final String judul;
  final String jam;
  final String deskripsi;
  final IconData icon;
}

class _AlarmTabState extends State<AlarmTab> with TickerProviderStateMixin {
  final _alarmService = AlarmService();
  List<AlarmModel> _alarms = [];
  late Timer _timer;
  DateTime _now = DateTime.now();

  // Animasi masuk (sekali) dan animasi berulang (jam berdering, bulatan melayang)
  late final AnimationController _entrance;
  late final AnimationController _loop;

  // Jadwal cepat yang bisa ditambahkan dengan satu ketukan
  static const _presets = <_Preset>[
    _Preset(
      'Sarapan',
      '07:00',
      'Waktunya sarapan, pilih menu yang lembut',
      Icons.free_breakfast,
    ),
    _Preset(
      'Minum Air',
      '10:00',
      'Jangan lupa minum air putih',
      Icons.water_drop_outlined,
    ),
    _Preset(
      'Makan Siang',
      '12:00',
      'Waktunya makan siang tepat waktu',
      Icons.lunch_dining,
    ),
    _Preset(
      'Camilan Sehat',
      '15:30',
      'Camilan ringan agar lambung tidak kosong',
      Icons.local_cafe_outlined,
    ),
    _Preset(
      'Makan Malam',
      '18:30',
      'Makan malam, hindari yang pedas dan asam',
      Icons.dinner_dining,
    ),
    _Preset(
      'Sebelum Tidur',
      '21:00',
      'Minum hangat dan jangan langsung berbaring',
      Icons.bedtime_outlined,
    ),
  ];
  final Set<String> _busy = {};

  // Tips yang berganti otomatis
  static const _tips = [
    'Makan porsi kecil tapi sering lebih nyaman untuk lambung.',
    'Kunyah makanan perlahan agar lebih mudah dicerna.',
    'Beri jeda 2-3 jam setelah makan sebelum berbaring.',
    'Kurangi pedas, asam, gorengan, dan minuman berkafein.',
    'Jangan menunda makan, lambung kosong memicu perih.',
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadAlarm();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _entrance.dispose();
    _loop.dispose();
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

  bool _hasPreset(_Preset p) =>
      _alarms.any((a) => a.jam == p.jam && a.judul == p.judul);

  Future<void> _addPreset(_Preset p) async {
    final userId = AuthService.currentUser?.id;
    if (userId == null || _busy.contains(p.judul) || _hasPreset(p)) return;
    setState(() => _busy.add(p.judul));
    try {
      await _alarmService.tambahAlarm(
        AlarmModel(
          userId: userId,
          jam: p.jam,
          judul: p.judul,
          deskripsi: p.deskripsi,
        ),
      );
      await _loadAlarm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarm ${p.judul} (${p.jam}) ditambahkan')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambah alarm: $error')));
    } finally {
      if (mounted) setState(() => _busy.remove(p.judul));
    }
  }

  String get _greeting {
    final h = _now.hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  /// Alarm aktif yang paling dekat dengan waktu sekarang
  ({AlarmModel alarm, Duration diff})? _nextAlarm() {
    AlarmModel? best;
    Duration? bestDiff;
    for (final a in _alarms.where((a) => a.aktif)) {
      final parts = a.jam.split(':');
      if (parts.length < 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) continue;
      var t = DateTime(_now.year, _now.month, _now.day, h, m);
      if (!t.isAfter(_now)) t = t.add(const Duration(days: 1));
      final d = t.difference(_now);
      if (bestDiff == null || d < bestDiff) {
        best = a;
        bestDiff = d;
      }
    }
    if (best == null || bestDiff == null) return null;
    return (alarm: best, diff: bestDiff);
  }

  String _formatDiff(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '$h jam $m menit lagi';
    if (m > 0) return '$m menit lagi';
    return 'kurang dari 1 menit lagi';
  }

  /// Fade + geser naik, muncul berurutan saat halaman dibuka
  Widget _stagger(double begin, double end, Widget child) {
    final anim = CurveTween(
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    ).animate(_entrance);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 96),
        children: [
          _stagger(0.0, 0.55, _buildHero()),
          const SizedBox(height: 18),
          _stagger(
            0.2,
            0.7,
            const _SectionTitle(
              title: 'Jadwal Cepat',
              subtitle: 'Ketuk untuk menambah alarm makan',
            ),
          ),
          const SizedBox(height: 10),
          _stagger(0.25, 0.8, _buildPresets()),
          const SizedBox(height: 18),
          _stagger(0.35, 0.9, _buildAlarmHeader()),
          const SizedBox(height: 6),
          if (_alarms.isEmpty)
            _stagger(0.4, 0.95, _buildEmpty())
          else
            for (var i = 0; i < _alarms.length; i++)
              _FadeIn(
                key: ValueKey('alarm-${_alarms[i].id ?? i}'),
                delay: i,
                child: AlarmItemCard(
                  alarm: _alarms[i],
                  onToggle: (value) async {
                    await _alarmService.toggleAktif(_alarms[i].id!, value);
                    _loadAlarm();
                  },
                  onDelete: () async {
                    await _alarmService.hapusAlarm(_alarms[i].id!);
                    _loadAlarm();
                  },
                ),
              ),
          const SizedBox(height: 18),
          _stagger(0.5, 1.0, _buildTipCard()),
        ],
      ),
    );
  }

  /// Kartu utama bergradasi maroon: jam, sapaan, alarm berikutnya, jam berdering
  Widget _buildHero() {
    final next = _nextAlarm();
    final name = (AuthService.currentUser?.nama ?? '').trim().split(' ').first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55800020),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            _floatingBubble(
              right: -30,
              top: -30,
              size: 120,
              phase: 0.5,
              alpha: 0.09,
            ),
            _floatingBubble(
              left: -24,
              bottom: -34,
              size: 100,
              phase: 2.2,
              alpha: 0.08,
            ),
            _floatingBubble(
              right: 90,
              bottom: 14,
              size: 28,
              phase: 3.8,
              alpha: 0.14,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? _greeting : '$_greeting, $name',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH.mm.ss').format(_now),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              DateFormat('d MMMM yyyy').format(_now),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildRingingClock(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: next == null
                              ? const Text(
                                  'Belum ada alarm aktif. Tambahkan dari jadwal cepat di bawah.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    height: 1.3,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Berikutnya: ${next.alarm.judul} • ${next.alarm.jam}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      _formatDiff(next.diff),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _floatingBubble({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required double phase,
    required double alpha,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, child) {
          final t = _loop.value * 2 * math.pi + phase;
          return Transform.translate(
            offset: Offset(math.cos(t) * 8, math.sin(t) * 10),
            child: child,
          );
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(255, 255, 255, alpha),
          ),
        ),
      ),
    );
  }

  /// Ikon jam yang bergetar seperti berdering, dengan gelombang di sekelilingnya
  Widget _buildRingingClock() {
    return SizedBox(
      width: 84,
      height: 84,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, _) {
          final t = _loop.value;
          final shake = t < 0.4
              ? math.sin(t / 0.4 * 2 * math.pi * 4) * 0.22
              : 0.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 2; i++) _ring((t + i / 2) % 1.0),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Transform.rotate(
                  angle: shake,
                  child: const Icon(Icons.alarm, color: Colors.white, size: 30),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(double p) {
    final size = 56 + p * 28;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color.fromRGBO(255, 255, 255, (1 - p) * 0.45),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildPresets() {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final p = _presets[i];
          return _PresetCard(
            preset: p,
            added: _hasPreset(p),
            busy: _busy.contains(p.judul),
            onTap: () => _addPreset(p),
          );
        },
      ),
    );
  }

  Widget _buildAlarmHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Alarm Saya',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF6E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_alarms.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Tambah alarm',
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: _tambahAlarm,
          ),
        ],
      ),
    );
  }

  /// Tampilan ringkas saat belum ada alarm
  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.softBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _loop,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, math.sin(_loop.value * 2 * math.pi) * 5),
              child: child,
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
              ),
              child: const Icon(Icons.alarm_add, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada alarm',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  'Pilih dari jadwal cepat di atas atau ketuk tombol + untuk membuat sendiri.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu tips yang berganti sesuai menit berjalan
  Widget _buildTipCard() {
    final tip = _tips[(_now.minute ~/ 1 + _now.hour) % _tips.length];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E7EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _loop,
            builder: (context, child) {
              final beat = math.max(
                0.0,
                math.sin(_loop.value * 2 * math.pi * 2),
              );
              return Transform.scale(scale: 1 + 0.2 * beat, child: child);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Peduli terhadap lambungmu',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Align(
                    key: ValueKey(tip),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 12.5, height: 1.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.added,
    required this.busy,
    required this.onTap,
  });

  final _Preset preset;
  final bool added;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 138,
      decoration: BoxDecoration(
        gradient: added
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
        color: added ? AppColors.softBg : null,
        borderRadius: BorderRadius.circular(20),
        border: added ? Border.all(color: AppColors.softBorder) : null,
        boxShadow: added
            ? null
            : const [
                BoxShadow(
                  color: Color(0x44800020),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: added || busy ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: added
                        ? const Color(0xFFF6E7EB)
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    preset.icon,
                    size: 18,
                    color: added ? AppColors.primary : Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  preset.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: added ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      preset.jam,
                      style: TextStyle(
                        fontSize: 12,
                        color: added ? AppColors.textGrey : Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    if (busy)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Icon(
                        added ? Icons.check_circle : Icons.add_circle_outline,
                        size: 18,
                        color: added ? AppColors.primary : Colors.white,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Item daftar yang muncul dengan fade + geser naik, berurutan sesuai posisi.
class _FadeIn extends StatelessWidget {
  const _FadeIn({super.key, required this.delay, required this.child});

  final int delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + math.min(delay, 6) * 90),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 18),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
