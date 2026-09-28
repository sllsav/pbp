import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/makanan_model.dart';
import '../utils/constants.dart';

class MakananGridCard extends StatelessWidget {
  const MakananGridCard({
    super.key,
    required this.makanan,
    required this.onTap,
  });
  final MakananModel makanan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF4F8F2),
                  child: makanan.gambar.toLowerCase().endsWith('.svg')
                      ? SvgPicture.asset(
                          makanan.gambar,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) => const Icon(
                            Icons.image_outlined,
                            size: 58,
                            color: Color(0xFF55A85A),
                          ),
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.eco_outlined,
                            size: 58,
                            color: Color(0xFF55A85A),
                          ),
                        )
                      : Image.asset(
                          makanan.gambar,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.eco_outlined,
                            size: 58,
                            color: Color(0xFF55A85A),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              makanan.nama,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              makanan.deskripsi,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Informasi', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
