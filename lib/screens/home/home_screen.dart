import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../widgets/health_bottom_nav_bar.dart';
import '../chat_screen.dart';
import 'alarm/alarm_tab.dart';
import 'scan/scan_tab.dart';
import 'profil/profil_tab.dart';
import 'rekomendasi/rekomendasi_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final tabs = const [AlarmTab(), RekomendasiTab(), ScanTab(), ProfilTab()];

  // Posisi tombol AI (null = belum diatur, pakai posisi default di build pertama)
  Offset? _buttonPosition;
  static const double _buttonSize = 56;
  static const double _margin = 16;

  // Batasi posisi supaya tombol selalu berada di dalam area yang terlihat
  Offset _clampToArea(Offset position, Size area) {
    final maxX = (area.width - _buttonSize).clamp(0.0, double.infinity);
    final maxY = (area.height - _buttonSize).clamp(0.0, double.infinity);
    return Offset(
      position.dx.clamp(0.0, maxX).toDouble(),
      position.dy.clamp(0.0, maxY).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final area = Size(constraints.maxWidth, constraints.maxHeight);

          // Posisi default: kanan tengah area body
          _buttonPosition ??= Offset(
            area.width - _buttonSize - _margin,
            area.height / 2 - _buttonSize,
          );

          // Dicek ulang setiap build, jadi ikut menyesuaikan saat ukuran jendela berubah
          final position = _clampToArea(_buttonPosition!, area);

          return Stack(
            children: [
              tabs[index],
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _buttonPosition = _clampToArea(
                        position + details.delta,
                        area,
                      );
                    });
                  },
                  child: _AiAssistantButton(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: HealthBottomNavBar(
        currentIndex: index,
        onTap: (value) => setState(() => index = value),
        items: const [
          HealthNavItem(icon: Icons.alarm, label: 'Alarm'),
          HealthNavItem(icon: Icons.restaurant_menu, label: 'Rekomendasi'),
          HealthNavItem(icon: Icons.photo_camera, label: 'Scan'),
          HealthNavItem(icon: Icons.person, label: 'Profil'),
        ],
      ),
    );
  }
}

class _AiAssistantButton extends StatelessWidget {
  const _AiAssistantButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
