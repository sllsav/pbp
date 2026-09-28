import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/makanan_model.dart';
import '../utils/constants.dart';

class MinumanListItem extends StatelessWidget {
  const MinumanListItem({super.key, this.minuman, this.onTap, this.nama});
  final MakananModel? minuman;
  final VoidCallback? onTap;
  final String? nama;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      leading: SizedBox(
        width: 52,
        height: 52,
        child: (minuman?.gambar ?? '').toLowerCase().endsWith('.svg')
            ? SvgPicture.asset(
                minuman?.gambar ?? '',
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const Icon(
                  Icons.image_outlined,
                  size: 34,
                  color: AppColors.primary,
                ),
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_drink,
                  size: 34,
                  color: AppColors.primary,
                ),
              )
            : Image.asset(
                minuman?.gambar ?? '',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_drink,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
      ),
      title: Text(minuman?.nama ?? nama ?? ''),
      subtitle: Text(minuman?.deskripsi ?? ''),
      trailing: const Icon(Icons.arrow_forward, color: AppColors.primary),
      onTap: onTap,
    ),
  );
}
