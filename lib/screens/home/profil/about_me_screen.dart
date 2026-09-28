import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Tentang Saya'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    body: const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Nama:Salsabilla Oktavia Ramadhani\n'
        'NIM: 25051204393\n'
        'Kelas: 2025TIH\n'
        'Email: sasoy@example.com\n',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
    ),
  );
}
