import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/maroon_form.dart';
import '../../../widgets/maroon_info.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaroonFormPage(
      title: 'Kebijakan Privasi',
      subtitle: 'Bagaimana datamu dikelola',
      icon: Icons.privacy_tip_outlined,
      children: [
        Text(
          'Data pengguna dikelola secara bertanggung jawab untuk mendukung fitur aplikasi.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textGrey,
          ),
        ),
        SizedBox(height: 16),
        MaroonInfoCard(
          icon: Icons.storage_outlined,
          title: 'Data yang disimpan',
          body:
              'Nama, email, kata sandi akun, dan jadwal alarm disimpan di database aplikasi untuk mendukung login, profil, dan pengingat makan.',
        ),
        MaroonInfoCard(
          icon: Icons.photo_camera_outlined,
          title: 'Foto dan percakapan',
          body:
              'Foto makanan pada fitur Scan dan pesan pada Asisten Herbal dikirim ke layanan Gemini agar dapat dianalisis dan dijawab.',
        ),
        MaroonInfoCard(
          icon: Icons.notifications_active_outlined,
          title: 'Notifikasi',
          body:
              'Pengingat makan muncul sebagai notifikasi pada jam yang kamu pilih. Kamu dapat mengubah atau menghapus alarm kapan saja.',
        ),
        MaroonInfoCard(
          icon: Icons.manage_accounts_outlined,
          title: 'Kendali pengguna',
          body:
              'Kamu dapat memperbarui profil, mengganti sandi, dan menghapus alarm langsung dari aplikasi.',
        ),
        MaroonInfoCard(
          icon: Icons.health_and_safety_outlined,
          title: 'Catatan kesehatan',
          body:
              'Hasil analisis dan jawaban asisten bersifat informasi umum dan bukan pengganti nasihat medis.',
        ),
      ],
    );
  }
}
