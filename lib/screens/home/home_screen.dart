import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../widgets/health_bottom_nav_bar.dart';
import '../chat_screen.dart';
import 'alarm/alarm_tab.dart';
import 'informasi/informasi_tab.dart';
import 'profil/profil_tab.dart';
import 'rekomendasi/rekomendasi_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final tabs = const [
    AlarmTab(),
    RekomendasiTab(),
    InformasiTab(),
    ProfilTab(),
  ];

  // Posisi tombol AI (null = belum diatur, pakai posisi default di build pertama)
  Offset? _buttonPosition;
  static const double _buttonSize = 56;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Posisi default: kanan tengah layar (dihitung sekali saat pertama kali build)
    _buttonPosition ??= Offset(
      screenSize.width - _buttonSize - 16,
      screenSize.height / 2 - _buttonSize,
    );

    return Scaffold(
      body: Stack(
        children: [
          tabs[index],
          Positioned(
            left: _buttonPosition!.dx,
            top: _buttonPosition!.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final newX = _buttonPosition!.dx + details.delta.dx;
                  final newY = _buttonPosition!.dy + details.delta.dy;

                  // Batasi supaya tombol tidak keluar dari layar
                  final maxX = screenSize.width - _buttonSize;
                  final maxY = screenSize.height - _buttonSize - kToolbarHeight - kBottomNavigationBarHeight - 40;

                  _buttonPosition = Offset(
                    newX.clamp(0, maxX),
                    newY.clamp(0, maxY),
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
      ),
      bottomNavigationBar: HealthBottomNavBar(
        currentIndex: index,
        onTap: (value) => setState(() => index = value),
        items: const [
          HealthNavItem(icon: Icons.alarm, label: 'Alarm'),
          HealthNavItem(icon: Icons.restaurant_menu, label: 'Rekomendasi'),
          HealthNavItem(icon: Icons.article, label: 'Informasi'),
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