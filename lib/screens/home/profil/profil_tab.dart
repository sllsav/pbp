import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/makanan_data.dart';
import '../../../services/alarm_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../auth/login_screen.dart';
import 'about_me_screen.dart';
import 'about_us_screen.dart';
import 'edit_profil_screen.dart';
import 'ganti_sandi_screen.dart';
import 'kebijakan_privasi_screen.dart';

class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _Bubble {
  const _Bubble(this.fx, this.fy, this.size, this.phase, this.opacity);
  final double fx;
  final double fy;
  final double size;
  final double phase;
  final double opacity;
}

class _ProfilTabState extends State<ProfilTab> with TickerProviderStateMixin {
  // Animasi masuk (sekali) dan animasi berulang (gelombang, bulatan, foto melayang)
  late final AnimationController _entrance;
  late final AnimationController _loop;

  int _alarmTotal = 0;
  int _alarmAktif = 0;

  static const _bubbles = <_Bubble>[
    _Bubble(0.80, 0.04, 120, 0.5, 0.09),
    _Bubble(0.04, 0.10, 80, 2.0, 0.10),
    _Bubble(0.66, 0.46, 34, 3.5, 0.14),
    _Bubble(-0.06, 0.55, 100, 5.0, 0.07),
    _Bubble(0.90, 0.68, 56, 1.2, 0.10),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _loadStats();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loop.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) return;
      final alarms = await AlarmService().getAlarmByUser(userId);
      if (!mounted) return;
      setState(() {
        _alarmTotal = alarms.length;
        _alarmAktif = alarms.where((a) => a.aktif).length;
      });
    } catch (_) {
      // Statistik hanya pelengkap, abaikan jika gagal dimuat
    }
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

  Future<void> _editProfil() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilScreen()),
    );
    if (mounted) setState(() {});
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header gradasi + kartu statistik yang menempel di tepi bawahnya
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildHeader(context),
            Positioned(
              left: 16,
              right: 16,
              bottom: -44,
              child: _stagger(0.45, 0.95, _buildStats()),
            ),
          ],
        ),
        const SizedBox(height: 44 + 20),
        _stagger(0.5, 1.0, _buildMenuCard()),
        const SizedBox(height: 14),
        _stagger(0.6, 1.0, _buildLogoutCard()),
        const SizedBox(height: 22),
        _stagger(
          0.7,
          1.0,
          const Center(
            child: Text(
              'NutriBells • Sehat dimulai dari kebiasaan kecil',
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = AuthService.currentUser;
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        child: Stack(
          children: [
            // Bulatan transparan yang melayang
            for (final b in _bubbles)
              Positioned(
                left: size.width * b.fx,
                top: 330 * b.fy,
                child: AnimatedBuilder(
                  animation: _loop,
                  builder: (context, child) {
                    final t = _loop.value * 2 * math.pi + b.phase;
                    return Transform.translate(
                      offset: Offset(math.cos(t) * 14, math.sin(t) * 18),
                      child: child,
                    );
                  },
                  child: Container(
                    width: b.size,
                    height: b.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(255, 255, 255, b.opacity),
                    ),
                  ),
                ),
              ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 60),
                child: Column(
                  children: [
                    const Text(
                      'Profil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _stagger(0.0, 0.5, _buildAvatar(user?.fotoProfil)),
                    const SizedBox(height: 6),
                    _stagger(
                      0.15,
                      0.6,
                      Text(
                        user?.nama ?? '-',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    _stagger(
                      0.2,
                      0.65,
                      Text(
                        user?.email ?? '-',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _stagger(
                      0.3,
                      0.75,
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        onPressed: _editProfil,
                        icon: const Text(
                          'Sunting Profile',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        label: const Icon(Icons.arrow_forward_ios, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Foto profil dengan gelombang yang melebar dan foto yang melayang pelan
  Widget _buildAvatar(String? fotoUrl) {
    return SizedBox(
      width: 160,
      height: 160,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, child) {
          final t = _loop.value;
          final float = math.sin(t * 2 * math.pi) * 4;
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 2; i++) _ring((t * 2 + i / 2) % 1.0),
              Transform.translate(offset: Offset(0, float), child: child),
            ],
          );
        },
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
            image: DecorationImage(
              image: fotoUrl != null
                  ? NetworkImage(fotoUrl) as ImageProvider
                  : const AssetImage('assets/images/foto_profil.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ring(double p) {
    final size = 104 + p * 56;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color.fromRGBO(255, 255, 255, (1 - p) * 0.4),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26800020),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(icon: Icons.alarm, value: _alarmTotal, label: 'Alarm'),
          const _StatDivider(),
          _StatItem(
            icon: Icons.notifications_active_outlined,
            value: _alarmAktif,
            label: 'Aktif',
          ),
          const _StatDivider(),
          _StatItem(
            icon: Icons.restaurant_menu,
            value: MakananData.getMakanan().length,
            label: 'Menu Sehat',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    final items = <_MenuData>[
      _MenuData(
        'Ganti Sandi',
        Icons.vpn_key_outlined,
        () => _open(const GantiSandiScreen()),
      ),
      _MenuData(
        'Kebijakan Privasi',
        Icons.lock_outline,
        () => _open(const KebijakanPrivasiScreen()),
      ),
      _MenuData(
        'Tentang Aplikasi',
        Icons.info_outline,
        () => _open(const AboutUsScreen()),
      ),
      _MenuData(
        'Tentang Saya',
        Icons.badge_outlined,
        () => _open(const AboutMeScreen()),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _MenuTile(data: items[i]),
              if (i != items.length - 1)
                const Divider(
                  height: 1,
                  indent: 70,
                  color: AppColors.softBorder,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E7EB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _MenuTile(
          data: _MenuData('Keluar', Icons.logout, _logout),
          highlight: true,
        ),
      ),
    );
  }
}

class _MenuData {
  const _MenuData(this.title, this.icon, this.onTap);
  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.data, this.highlight = false});

  final _MenuData data;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: highlight ? Colors.white : const Color(0xFFF6E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                    color: highlight ? AppColors.primary : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: highlight ? AppColors.primary : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 4),
              // Angka menghitung naik dari 0
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text(
                  v.round().toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.softBorder);
}
