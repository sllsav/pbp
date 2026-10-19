import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ms_undraw/ms_undraw.dart';

import '../../../data/informasi_data.dart';
import '../../../models/informasi_model.dart';
import '../../../utils/constants.dart';

class InformasiTab extends StatefulWidget {
  const InformasiTab({super.key});

  @override
  State<InformasiTab> createState() => _InformasiTabState();
}

class _InformasiTabState extends State<InformasiTab>
    with SingleTickerProviderStateMixin {
  // Satu controller untuk semua bulatan & header, berputar terus-menerus
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final informasi = InformasiData.getInformasi();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 36),
        children: [
          _InformationHeader(animation: _anim),
          _InformationSection(
            informasi: informasi[0],
            animation: _anim,
            phase: 0.0,
            illustration: UnDrawIllustration.ask_me_anything,
            alignment: Alignment.topRight,
          ),
          _InformationSection(
            informasi: informasi[1],
            animation: _anim,
            phase: 1.6,
            illustration: UnDrawIllustration.contemplating,
            alignment: Alignment.centerLeft,
            reversed: true,
          ),
          _InformationSection(
            informasi: informasi[2],
            animation: _anim,
            phase: 3.2,
            illustration: UnDrawIllustration.alert,
            alignment: Alignment.topRight,
            accentTitle: true,
          ),
          _InformationSection(
            informasi: informasi[3],
            animation: _anim,
            phase: 4.8,
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
  const _InformationHeader({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          Positioned(
            left: -58,
            top: -72,
            // Lingkaran besar bergerak naik-turun & membesar-mengecil pelan
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final t = animation.value * 2 * math.pi;
                return Transform.translate(
                  offset: Offset(math.cos(t) * 6, math.sin(t) * 8),
                  child: Transform.scale(
                    scale: 1 + math.sin(t) * 0.04,
                    child: child,
                  ),
                );
              },
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
    required this.animation,
    required this.phase,
    required this.illustration,
    required this.alignment,
    this.reversed = false,
    this.accentTitle = false,
  });

  final InformasiModel informasi;
  final Animation<double> animation;
  final double phase;
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
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPainter(animation: animation, phase: phase),
            ),
          ),
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

/// Bulatan maroon yang bergerak melayang pelan dan berdenyut.
/// Semua gerakan memakai kelipatan bulat dari satu putaran, jadi loop-nya mulus.
class _DotPainter extends CustomPainter {
  _DotPainter({required this.animation, required this.phase})
    : super(repaint: animation);

  final Animation<double> animation;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 2 * math.pi;

    // (posisi x, posisi y, jari-jari, kecepatan, jarak gerak, transparansi)
    final dots = <List<double>>[
      [.18, .78, 14, 1, 16, .75],
      [.78, .72, 20, 2, 12, .65],
      [.62, .90, 9, 1, 20, .80],
    ];

    for (var i = 0; i < dots.length; i++) {
      final d = dots[i];
      final angle = t * d[3] + phase + i * 2.1;
      final center = Offset(
        size.width * d[0] + math.cos(angle) * d[4],
        size.height * d[1] + math.sin(angle) * d[4],
      );
      final radius = d[2] * (1 + 0.18 * math.sin(t * 2 + phase + i));
      final paint = Paint()..color = Color.fromRGBO(128, 0, 32, d[5]);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
