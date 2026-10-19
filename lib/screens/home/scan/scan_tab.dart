import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/gemini_service.dart';
import '../../../utils/constants.dart';

/// Tab Scan: foto makanan/minuman, lalu Gemini menilai apakah
/// boleh dikonsumsi penderita asam lambung.
class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  final _gemini = GeminiService();

  Uint8List? _bytes;
  FoodAnalysis? _result;
  bool _loading = false;

  // Animasi denyut pada ikon kamera
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _mimeOf(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pick(ImageSource source) async {
    if (_loading) return;
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _result = null;
        _loading = true;
      });

      final result = await _gemini.analyzeFood(
        bytes,
        mimeType: _mimeOf(file.path),
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _buildPreview(),
              const SizedBox(height: 16),
              _buildButtons(),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _loading
                    ? const _LoadingCard(key: ValueKey('loading'))
                    : _result != null
                    ? _ResultCard(key: ValueKey(_result), result: _result!)
                    : const SizedBox(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan Makanan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Foto makanan atau minuman untuk cek apakah aman bagi penderita asam lambung',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.softBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.softBorder, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: _bytes != null
            ? Image.memory(_bytes!, fit: BoxFit.cover)
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.08).animate(
                        CurvedAnimation(
                          parent: _pulse,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x1A800020),
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Belum ada foto',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ambil foto atau pilih dari galeri',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.photo_camera,
            label: 'Ambil Foto',
            filled: true,
            onTap: _loading ? null : () => _pick(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.photo_library_outlined,
            label: 'Galeri',
            filled: false,
            onTap: _loading ? null : () => _pick(ImageSource.gallery),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                )
              : null,
          color: filled ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: filled
              ? null
              : Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: filled
              ? const [
                  BoxShadow(
                    color: Color(0x66800020),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: filled ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: filled ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.softBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Menganalisis makanan...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Mohon tunggu beberapa detik',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({super.key, required this.result});

  final FoodAnalysis result;

  ({Color color, Color bg, IconData icon, String label}) get _style {
    switch (result.status) {
      case 'aman':
        return (
          color: const Color(0xFF2E7D32),
          bg: const Color(0xFFE8F5E9),
          icon: Icons.check_circle,
          label: 'AMAN',
        );
      case 'hindari':
        return (
          color: const Color(0xFFC62828),
          bg: const Color(0xFFFDECEA),
          icon: Icons.cancel,
          label: 'HINDARI',
        );
      default:
        return (
          color: const Color(0xFFE08A00),
          bg: const Color(0xFFFFF4E0),
          icon: Icons.warning_amber_rounded,
          label: 'HATI-HATI',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!result.isFood) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.softBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.softBorder),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_off, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Makanan atau minuman tidak terdeteksi. Coba foto ulang dengan lebih jelas dan dekat.',
              ),
            ),
          ],
        ),
      );
    }

    final style = _style;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, color: style.color, size: 20),
                const SizedBox(width: 6),
                Text(
                  style.label,
                  style: TextStyle(
                    color: style.color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            result.nama,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${result.kalori} (perkiraan)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (result.kandungan.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionTitle('Kandungan'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.kandungan
                  .map(
                    (k) => _Chip(
                      text: k,
                      bg: AppColors.softBg,
                      fg: AppColors.primaryDark,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (result.bahanBerisiko.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionTitle('Bahan berisiko'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.bahanBerisiko
                  .map(
                    (b) => _Chip(
                      text: b,
                      bg: const Color(0xFFFDECEA),
                      fg: const Color(0xFFC62828),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (result.alasan.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionTitle('Alasan'),
            Text(result.alasan, style: const TextStyle(height: 1.5)),
          ],
          if (result.saran.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.saran,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Hasil berupa perkiraan dari foto dan bukan pengganti nasihat medis. Konsultasikan ke dokter untuk kondisi kesehatan spesifik.',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}
