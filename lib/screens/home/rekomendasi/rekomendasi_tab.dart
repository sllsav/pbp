import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/makanan_data.dart';
import '../../../models/makanan_model.dart';
import '../../../utils/constants.dart';
import '../../../widgets/makanan_grid_card.dart';
import '../../../widgets/minuman_list_item.dart';
import 'detail_makanan_screen.dart';

class RekomendasiTab extends StatefulWidget {
  const RekomendasiTab({super.key});

  @override
  State<RekomendasiTab> createState() => _RekomendasiTabState();
}

class _RekomendasiTabState extends State<RekomendasiTab>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _foodPageController = PageController(viewportFraction: 0.78);
  String _selectedFilter = 'Semua';
  int _foodPage = 0;

  // Animasi masuk (sekali) dan animasi berulang (hati berdetak, ikon melayang)
  late final AnimationController _entrance;
  late final AnimationController _loop;

  // Tips yang berganti otomatis
  static const _tips = [
    'Makan porsi kecil tapi sering lebih nyaman untuk lambung.',
    'Kunyah makanan perlahan agar lebih mudah dicerna.',
    'Beri jeda 2-3 jam setelah makan sebelum berbaring.',
    'Kurangi pedas, asam, gorengan, dan minuman berkafein.',
    'Minum air putih secukupnya sepanjang hari.',
  ];
  int _tipIndex = 0;
  late final Timer _tipTimer;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });
  }

  @override
  void dispose() {
    _tipTimer.cancel();
    _entrance.dispose();
    _loop.dispose();
    _searchController.dispose();
    _foodPageController.dispose();
    super.dispose();
  }

  List<MakananModel> _filterItems(List<MakananModel> items) {
    final query = _searchController.text.trim().toLowerCase();
    return items.where((item) {
      final matchesSearch =
          query.isEmpty ||
          item.nama.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query);
      final matchesFilter =
          _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Makanan' && item.jenis == 'makanan') ||
          (_selectedFilter == 'Minuman' && item.jenis == 'minuman');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  /// Fade + geser naik, muncul berurutan saat halaman dibuka
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

  void _openDetail(MakananModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailMakananScreen(makanan: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semua = MakananData.getMakanan();
    final hasil = _filterItems(semua);
    final makanan = hasil.where((item) => item.jenis == 'makanan').toList();
    final minuman = hasil.where((item) => item.jenis == 'minuman').toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          _stagger(
            0.0,
            0.5,
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Makanan dan Minuman',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Untuk penderita sakit maag',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _stagger(0.1, 0.6, _buildTipBanner()),
          const SizedBox(height: 14),
          _stagger(0.2, 0.7, _buildSearch()),
          const SizedBox(height: 10),
          _stagger(0.3, 0.8, _buildFilters()),
          const SizedBox(height: 10),
          if (hasil.isEmpty) _buildEmpty(),
          if (makanan.isNotEmpty) ...[
            _stagger(
              0.4,
              0.9,
              _SectionHeader(
                title: 'Makanan',
                icon: Icons.restaurant,
                count: makanan.length,
              ),
            ),
            const SizedBox(height: 8),
            _stagger(0.45, 1.0, _buildFoodCarousel(makanan)),
            const SizedBox(height: 10),
            _buildDots(makanan.length),
            const SizedBox(height: 14),
          ],
          if (minuman.isNotEmpty) ...[
            _stagger(
              0.5,
              1.0,
              _SectionHeader(
                title: 'Minuman',
                icon: Icons.local_drink,
                count: minuman.length,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < minuman.length; i++)
              _FadeIn(
                key: ValueKey('minuman-${minuman[i].id}'),
                delay: i,
                child: MinumanListItem(
                  minuman: minuman[i],
                  onTap: () => _openDetail(minuman[i]),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Kartu tips dengan ikon berdetak dan teks yang berganti otomatis
  Widget _buildTipBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _loop,
            builder: (context, child) {
              final beat = math.max(
                0.0,
                math.sin(_loop.value * 2 * math.pi * 2),
              );
              return Transform.scale(scale: 1 + 0.2 * beat, child: child);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips untuk lambungmu',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Align(
                    key: ValueKey(_tipIndex),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _tips[_tipIndex],
                      style: const TextStyle(fontSize: 12.5, height: 1.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: 'Cari makanan atau minuman',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              ),
        filled: true,
        fillColor: const Color(0xFFFBF3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['Semua', 'Makanan', 'Minuman'].map((filter) {
          final selected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => setState(() {
                _selectedFilter = filter;
                _foodPage = 0;
                if (_foodPageController.hasClients) {
                  _foodPageController.jumpToPage(0);
                }
              }),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : const Color(0xFFEBD9DE),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Carousel makanan: kartu di tengah sedikit lebih besar dari yang di samping
  Widget _buildFoodCarousel(List<MakananModel> makanan) {
    return SizedBox(
      height: 306,
      child: PageView.builder(
        controller: _foodPageController,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        itemCount: makanan.length,
        onPageChanged: (i) => setState(() => _foodPage = i),
        itemBuilder: (_, index) => AnimatedBuilder(
          animation: _foodPageController,
          builder: (context, child) {
            var page = 0.0;
            if (_foodPageController.hasClients &&
                _foodPageController.position.haveDimensions) {
              page = _foodPageController.page ?? 0.0;
            }
            final scale = (1 - (page - index).abs() * 0.1).clamp(0.88, 1.0);
            return Transform.scale(scale: scale.toDouble(), child: child);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MakananGridCard(
              makanan: makanan[index],
              onTap: () => _openDetail(makanan[index]),
            ),
          ),
        ),
      ),
    );
  }

  /// Penanda halaman carousel
  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == _foodPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : const Color(0xFFEBD9DE),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _loop,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, math.sin(_loop.value * 2 * math.pi) * 6),
              child: child,
            ),
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF6E7EB),
              ),
              child: const Icon(
                Icons.search_off,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada rekomendasi yang cocok',
            style: TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
  });

  final String title;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF6E7EB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count pilihan',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Item daftar yang muncul dengan fade + geser naik, berurutan sesuai posisi.
class _FadeIn extends StatelessWidget {
  const _FadeIn({super.key, required this.delay, required this.child});

  final int delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + math.min(delay, 6) * 90),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 18),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
