import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/maroon_form.dart';
import '../../../widgets/maroon_info.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaroonFormPage(
      title: 'Tentang Aplikasi',
      subtitle: 'Mengenal NutriBells',
      icon: Icons.info_outline,
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44800020),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/logo_nutribells.png',
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 88,
                  height: 88,
                  color: AppColors.primary,
                  child: const Icon(Icons.alarm, color: Colors.white, size: 44),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'NutriBells',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF6E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'NutriBells membantu pengguna membangun kebiasaan hidup sehat, terutama bagi penderita asam lambung.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Fitur Utama',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const MaroonInfoCard(
          icon: Icons.alarm,
          title: 'Alarm Makan',
          body: 'Pengingat jadwal makan agar lambung tidak kosong terlalu lama.',
        ),
        const MaroonInfoCard(
          icon: Icons.restaurant_menu,
          title: 'Rekomendasi Makanan & Minuman',
          body: 'Pilihan menu yang lebih ramah untuk lambung beserta informasi gizinya.',
        ),
        const MaroonInfoCard(
          icon: Icons.photo_camera,
          title: 'Scan Makanan',
          body: 'Foto makanan atau minuman untuk mengetahui perkiraan kalori dan apakah cocok untuk asam lambung.',
        ),
        const MaroonInfoCard(
          icon: Icons.smart_toy_outlined,
          title: 'Asisten Herbal',
          body: 'Tanya seputar herbal, makanan sehat, dan nutrisi umum.',
        ),
      ],
    );
  }
}
