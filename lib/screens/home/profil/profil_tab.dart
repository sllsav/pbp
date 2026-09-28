import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/profil_menu_item.dart';
import '../../auth/login_screen.dart';
import 'about_me_screen.dart';
import 'about_us_screen.dart';
import 'edit_profil_screen.dart';
import 'ganti_sandi_screen.dart';
import 'kebijakan_privasi_screen.dart';

class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          const Center(
            child: Text(
              'Profil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: user?.fotoProfil != null
                    ? DecorationImage(
                        image: NetworkImage(user!.fotoProfil!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user?.fotoProfil == null
                  ? const Center(
                      child: Text(
                        'No Image\navailable',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              user?.nama ?? '-',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '-',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilScreen()),
              ),
              icon: const Text(
                'Sunting Profile',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              label: const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          ProfilMenuItem(
            title: 'Ganti Sandi',
            icon: Icons.vpn_key_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GantiSandiScreen()),
            ),
          ),
          ProfilMenuItem(
            title: 'Kebijakan Privasi',
            icon: Icons.lock_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KebijakanPrivasiScreen()),
            ),
          ),
          ProfilMenuItem(
            title: 'Tentang Aplikasi',
            icon: Icons.info_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),
          ProfilMenuItem(
            title: 'Tentang Saya',
            icon: Icons.badge_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutMeScreen()),
            ),
          ),
          const SizedBox(height: 16),
          ProfilMenuItem(
            title: 'Keluar',
            icon: Icons.logout,
            onTap: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}