import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Tentang Aplikasi'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    body: const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Health App membantu pengguna membangun kebiasaan hidup sehat.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
    ),
  );
}