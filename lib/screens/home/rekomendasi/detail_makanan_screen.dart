import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/makanan_model.dart';
import '../../../utils/constants.dart';

class DetailMakananScreen extends StatefulWidget {
  const DetailMakananScreen({super.key, required this.makanan});

  final MakananModel makanan;

  @override
  State<DetailMakananScreen> createState() => _DetailMakananScreenState();
}

class _DetailMakananScreenState extends State<DetailMakananScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loop.dispose();
    super.dispose();
  }

  Widget _stagger(double begin, double end, Widget child) {
    final anim = CurveTween(
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    ).animate(_entrance);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  Widget _bubble({
    double? left,
    double? right,
    double? top,
    required double size,
    required double phase,
    required double alpha,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, child) {
          final t = _loop.value * 2 * math.pi + phase;
          return Transform.translate(
            offset: Offset(math.cos(t) * 12, math.sin(t) * 16),
            child: child,
          );
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(255, 255, 255, alpha),
          ),
        ),
      ),
    );
  }

  Widget _ring(double p) {
    final size = 190 + p * 60;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color.fromRGBO(255, 255, 255, (1 - p) * 0.35),
          width: 2,
        ),
      ),
    );
  }

  /// Gambar makanan (emoji, SVG, atau PNG/JPG) di dalam panel putih
  Widget _buildImage(MakananModel m) {
    const fallback = Icon(Icons.eco_outlined, size: 90, color: Color(0xFF56A65A));
    if (m.emoji.isNotEmpty) {
      return Center(
        child: Text(m.emoji, style: const TextStyle(fontSize: 96)),
      );
    }
    if (m.gambar.toLowerCase().endsWith('.svg')) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: SvgPicture.asset(
          m.gambar,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => fallback,
          errorBuilder: (_, __, ___) => fallback,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Image.asset(
        m.gambar,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }

  Widget _buildHero(MakananModel m) {
    return SizedBox(
      height: 260,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, child) {
          final t = _loop.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 2; i++) _ring((t * 2 + i / 2) % 1.0),
              Transform.translate(
                offset: Offset(0, math.sin(t * 2 * math.pi) * 6),
                child: child,
              ),
            ],
          );
        },
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(44),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(44),
            child: _buildImage(m),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(MakananModel m) {
    final isMinuman = m.jenis == 'minuman';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stagger(
            0.3,
            0.65,
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.nama,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6E7EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMinuman ? Icons.local_drink : Icons.restaurant,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMinuman ? 'Minuman' : 'Makanan',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _stagger(
            0.36,
            0.7,
            Text(
              m.deskripsi,
              style: const TextStyle(color: AppColors.textGrey, height: 1.45),
            ),
          ),
          const SizedBox(height: 24),
          _stagger(
            0.42,
            0.76,
            const Text(
              'Informasi Gizi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          _stagger(
            0.5,
            1.0,
            Row(
              children: [
                Expanded(
                  child: _NutriCard(
                    icon: Icons.local_fire_department,
                    value: m.kalori,
                    decimals: 0,
                    unit: 'kkal',
                    label: 'Kalori',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NutriCard(
                    icon: Icons.fitness_center,
                    value: m.protein,
                    decimals: 1,
                    unit: 'g',
                    label: 'Protein',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NutriCard(
                    icon: Icons.grain,
                    value: m.karbo,
                    decimals: 1,
                    unit: 'g',
                    label: 'Karbo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _stagger(
            0.6,
            1.0,
            const Text(
              'Nilai gizi berupa perkiraan umum. Respons tubuh tiap orang bisa berbeda, konsultasikan ke dokter bila perlu.',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.makanan;
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
            ),
          ),
          _bubble(right: -30, top: 40, size: 130, phase: 0.5, alpha: 0.09),
          _bubble(left: 10, top: 120, size: 60, phase: 2.2, alpha: 0.10),
          _bubble(right: 70, top: 300, size: 30, phase: 3.8, alpha: 0.14),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        _buildHero(m),
                        Expanded(child: _buildCard(m)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu nutrisi dengan angka yang menghitung naik dari 0
class _NutriCard extends StatelessWidget {
  const _NutriCard({
    required this.icon,
    required this.value,
    required this.decimals,
    required this.unit,
    required this.label,
  });

  final IconData icon;
  final double value;
  final int decimals;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.softBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '${v.toStringAsFixed(decimals)} $unit',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
