import 'package:flutter/material.dart';

import '../../../models/informasi_model.dart';

class DetailInformasiScreen extends StatelessWidget {
  const DetailInformasiScreen({super.key, required this.informasi});
  final InformasiModel informasi;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(informasi.judul)),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(informasi.isi),
    ),
  );
}
