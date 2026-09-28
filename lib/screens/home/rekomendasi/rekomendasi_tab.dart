import 'package:flutter/material.dart';

import '../../../data/makanan_data.dart';
import '../../../utils/constants.dart';
import '../../../widgets/makanan_grid_card.dart';
import '../../../widgets/minuman_list_item.dart';
import 'detail_makanan_screen.dart';

class RekomendasiTab extends StatefulWidget {
  const RekomendasiTab({super.key});

  @override
  State<RekomendasiTab> createState() => _RekomendasiTabState();
}

class _RekomendasiTabState extends State<RekomendasiTab> {
  final _searchController = TextEditingController();
  final _foodPageController = PageController(viewportFraction: 0.78);
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    _foodPageController.dispose();
    super.dispose();
  }

  List<dynamic> _filterItems(List<dynamic> items) {
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
        const Text(
          'Makanan dan Minuman',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const Text(
          'Untuk penderita sakit maag',
          style: TextStyle(color: AppColors.textGrey, fontSize: 15),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
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
            fillColor: const Color(0xFFF7F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
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
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        if (hasil.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                'Tidak ada rekomendasi yang cocok',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          ),
        const Row(
          children: [
            Text(
              'Makanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 6),
            Icon(Icons.restaurant, size: 16, color: AppColors.textGrey),
          ],
        ),
        const SizedBox(height: 8),
        if (makanan.isNotEmpty)
          SizedBox(
            height: 306,
            child: PageView.builder(
              controller: _foodPageController,
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(),
              itemCount: makanan.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: MakananGridCard(
                  makanan: makanan[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailMakananScreen(makanan: makanan[index]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (makanan.isNotEmpty) const SizedBox(height: 20),
        const Row(
          children: [
            Text(
              'Minuman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 6),
            Icon(Icons.local_drink, size: 16, color: AppColors.textGrey),
          ],
        ),
        const SizedBox(height: 8),
        if (minuman.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: minuman.length,
            itemBuilder: (context, index) {
              final item = minuman[index];
              return MinumanListItem(
                minuman: item,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailMakananScreen(makanan: item),
                  ),
                ),
              );
            },
          ),
      ],
    ),
    );
  }
}