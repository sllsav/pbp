import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/makanan_model.dart';
import '../../../utils/constants.dart';

class DetailMakananScreen extends StatelessWidget {
  const DetailMakananScreen({super.key, required this.makanan});

  final MakananModel makanan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),
      appBar: AppBar(
        title: Text(makanan.nama),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 270,
              color: const Color(0xFFEFF4EF),
              child: makanan.gambar.toLowerCase().endsWith('.svg')
                  ? SvgPicture.asset(
                      makanan.gambar,
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) => const Icon(
                        Icons.image_outlined,
                        size: 100,
                        color: Color(0xFF56A65A),
                      ),
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.eco_outlined,
                        size: 100,
                        color: Color(0xFF56A65A),
                      ),
                    )
                  : Image.asset(
                      makanan.gambar,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.eco_outlined,
                        size: 100,
                        color: Color(0xFF56A65A),
                      ),
                    ),
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      makanan.nama,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      makanan.deskripsi,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Nutrisi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _NutritionRow(
                      value: '${makanan.kalori.toStringAsFixed(0)}k',
                      label: 'Kalori',
                    ),
                    _NutritionRow(
                      value: '${makanan.protein.toStringAsFixed(2)}g',
                      label: 'Protein',
                    ),
                    _NutritionRow(
                      value: '${makanan.karbo.toStringAsFixed(1)}g',
                      label: 'Karbo',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
