import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

/// Warna maroon (sama dengan halaman login)
const Color _maroon = Color(0xFF800020);
const Color _maroonDark = Color(0xFF4A0012);
const Color _maroonLight = Color(0xFFA8284A);
const Color _fieldBg = Color(0xFFFBF3F5);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _Bubble {
  const _Bubble(this.fx, this.fy, this.size, this.phase, this.opacity);
  final double fx;
  final double fy;
  final double size;
  final double phase;
  final double opacity;
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  late final AnimationController _entrance;
  late final AnimationController _float;

  static const _bubbles = <_Bubble>[
    _Bubble(0.80, 0.03, 120, 0.5, 0.09),
    _Bubble(0.05, 0.08, 80, 2.0, 0.10),
    _Bubble(0.62, 0.17, 34, 3.5, 0.14),
    _Bubble(-0.06, 0.22, 100, 5.0, 0.07),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final error = await _authService.register(
        UserModel(
          nama: _namaController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil, silakan login')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Pendaftaran gagal: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _stagger({
    required double begin,
    required double end,
    required Widget child,
  }) {
    final anim = CurveTween(
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    ).animate(_entrance);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(
        color: _maroon,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: _maroon),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: border(Colors.transparent, 1),
      enabledBorder: border(Colors.transparent, 1),
      focusedBorder: border(_maroon, 1.8),
      errorBorder: border(Colors.red.shade300, 1.2),
      focusedErrorBorder: border(Colors.red.shade400, 1.8),
    );
  }

  Widget _eyeButton(bool obscure, VoidCallback onTap) => IconButton(
    onPressed: onTap,
    icon: Icon(
      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      color: Colors.black45,
    ),
  );

  Widget _buildBubbles(Size size) {
    return Stack(
      children: _bubbles.map((b) {
        return Positioned(
          left: size.width * b.fx,
          top: size.height * b.fy,
          child: AnimatedBuilder(
            animation: _float,
            builder: (context, child) {
              final t = _float.value * 2 * math.pi + b.phase;
              return Transform.translate(
                offset: Offset(math.cos(t) * 14, math.sin(t) * 18),
                child: child,
              );
            },
            child: Container(
              width: b.size,
              height: b.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: b.opacity),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader() {
    final logoScale = CurveTween(
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    ).animate(_entrance);
    final logoFade = CurveTween(
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    ).animate(_entrance);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 24, 20),
      child: Column(
        children: [
          // Tombol kembali
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          FadeTransition(
            opacity: logoFade,
            child: ScaleTransition(
              scale: logoScale,
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, math.sin(_float.value * 2 * math.pi) * 5),
                  child: child,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/logo_nutribells.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _stagger(
            begin: 0.2,
            end: 0.6,
            child: const Text(
              'NutriBells',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurveTween(
            curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
          ).animate(_entrance),
        );
    final cardFade = CurveTween(
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    ).animate(_entrance);

    return SlideTransition(
      position: cardSlide,
      child: FadeTransition(
        opacity: cardFade,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stagger(
                  begin: 0.35,
                  end: 0.7,
                  child: const Text(
                    'Buat Akun Baru',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _maroon,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _stagger(
                  begin: 0.4,
                  end: 0.75,
                  child: const Text(
                    'Isi data berikut untuk mendaftar',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 22),
                _stagger(
                  begin: 0.45,
                  end: 0.8,
                  child: TextFormField(
                    controller: _namaController,
                    cursorColor: _maroon,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                        Validators.validateNotEmpty(value, 'Nama'),
                    decoration: _decoration(
                      'Nama Lengkap',
                      Icons.person_outline,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _stagger(
                  begin: 0.52,
                  end: 0.86,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: _maroon,
                    validator: Validators.validateEmail,
                    decoration: _decoration('Email', Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                _stagger(
                  begin: 0.58,
                  end: 0.92,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    cursorColor: _maroon,
                    validator: Validators.validatePassword,
                    decoration: _decoration(
                      'Kata Sandi',
                      Icons.lock_outline,
                      suffix: _eyeButton(
                        _obscure,
                        () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _stagger(
                  begin: 0.64,
                  end: 0.96,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    cursorColor: _maroon,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    decoration: _decoration(
                      'Konfirmasi Kata Sandi',
                      Icons.lock_outline,
                      suffix: _eyeButton(
                        _obscureConfirm,
                        () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                _stagger(begin: 0.7, end: 1.0, child: _buildRegisterButton()),
                const SizedBox(height: 12),
                _stagger(
                  begin: 0.76,
                  end: 1.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun?',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: _maroon,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: const Text(
                          'Masuk di sini',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_maroonLight, _maroon]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: _isLoading ? 0.15 : 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : _handleRegister,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Daftar',
                      key: ValueKey('text'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _maroonDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_maroonLight, _maroon, _maroonDark],
                ),
              ),
            ),
          ),
          _buildBubbles(size),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _buildHeader(),
                        Expanded(child: _buildFormCard()),
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
