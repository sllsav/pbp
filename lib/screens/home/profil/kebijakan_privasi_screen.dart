import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Kebijakan Privasi'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    body: const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Data pengguna dikelola secara bertanggung jawab untuk mendukung fitur aplikasi.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
    ),
  );
}