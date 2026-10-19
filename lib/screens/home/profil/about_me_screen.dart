import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/maroon_form.dart';
import '../../../widgets/maroon_info.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaroonFormPage(
      title: 'Tentang Saya',
      subtitle: 'Pengembang aplikasi',
      icon: Icons.badge_outlined,
      children: [
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44800020),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage('assets/images/foto_profil.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Salsabilla Oktavia Ramadhani',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 22),
        const MaroonInfoRow(
          icon: Icons.person_outline,
          label: 'Nama',
          value: 'Salsabilla Oktavia Ramadhani',
        ),
        const MaroonInfoRow(
          icon: Icons.numbers,
          label: 'NIM',
          value: '25051204393',
        ),
        const MaroonInfoRow(
          icon: Icons.school_outlined,
          label: 'Kelas',
          value: '2025TIH',
        ),
        const MaroonInfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: 'sasoy@gmail.com',
        ),
      ],
    );
  }
}
