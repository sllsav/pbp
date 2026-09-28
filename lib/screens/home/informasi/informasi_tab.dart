import 'package:flutter/material.dart';
import 'package:ms_undraw/ms_undraw.dart';

import '../../../data/informasi_data.dart';
import '../../../models/informasi_model.dart';
import '../../../utils/constants.dart';

class InformasiTab extends StatelessWidget {
  const InformasiTab({super.key});

  @override
  Widget build(BuildContext context) {
    final informasi = InformasiData.getInformasi();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 36),
        children: [
          const _InformationHeader(),
          _InformationSection(
            informasi: informasi[0],
            illustration: UnDrawIllustration.ask_me_anything,
            alignment: Alignment.topRight,
          ),
          _InformationSection(
            informasi: informasi[1],
            illustration: UnDrawIllustration.contemplating,
            alignment: Alignment.centerLeft,
            reversed: true,
          ),
          _InformationSection(
            informasi: informasi[2],
            illustration: UnDrawIllustration.alert,
            alignment: Alignment.topRight,
            accentTitle: true,
          ),
          _InformationSection(
            informasi: informasi[3],
            illustration: UnDrawIllustration.checklist,
            alignment: Alignment.centerLeft,
            reversed: true,
          ),
        ],
      ),
    );
  }
}

class _InformationHeader extends StatelessWidget {
  const _InformationHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          Positioned(
            left: -58,
            top: -72,
            child: Container(
              width: 188,
              height: 188,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 30, bottom: 30),
                  child: Text(
                    '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 24,
            top: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Informasi',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Tentang Penyakit Maag',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu bagian informasi: judul + isi + ilustrasi orang, tanpa tombol
/// "Baca selengkapnya" — semua konten langsung tampil dan bisa discroll.
class _InformationSection extends StatelessWidget {
  const _InformationSection({
    required this.informasi,
    required this.illustration,
    required this.alignment,
    this.reversed = false,
    this.accentTitle = false,
  });

  final InformasiModel informasi;
  final UnDrawIllustration illustration;
  final Alignment alignment;
  final bool reversed;
  final bool accentTitle;

  @override
  Widget build(BuildContext context) {
    final text = Padding(
      padding: EdgeInsets.fromLTRB(
        reversed ? 104 : 24,
        18,
        reversed ? 24 : 104,
        18,
      ),
      child: Column(
        crossAxisAlignment: reversed
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            informasi.judul,
            textAlign: reversed ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: 18,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: accentTitle ? AppColors.primaryDark : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            informasi.isi,
            textAlign: reversed ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    final illustrationWidget = Align(
      alignment: alignment,
      child: SizedBox(
        width: 150,
        height: 150,
        child: UnDraw(
          illustration: illustration,
          color: AppColors.primary,
          placeholder: const SizedBox(),
          errorWidget: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.primary,
          ),
        ),
      ),
    );

    // Tinggi menyesuaikan konten (bukan fixed 310) supaya teks panjang tidak
    // terpotong dan tetap enak discroll bersama section lain.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotPainter())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  children: [
                    if (reversed)
                      Positioned(left: 18, top: 6, child: illustrationWidget)
                    else
                      Positioned(right: 18, top: 6, child: illustrationWidget),
                  ],
                ),
              ),
              text,
            ],
          ),
        ],
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD9534F);
    canvas.drawCircle(Offset(size.width * .18, size.height * .78), 8, paint);
    canvas.drawCircle(Offset(size.width * .78, size.height * .72), 12, paint);
    canvas.drawCircle(Offset(size.width * .62, size.height * .9), 5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}