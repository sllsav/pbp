import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

/// Warna maroon khusus halaman login (tidak mengubah AppColors di aplikasi lain)
const Color _maroon = Color(0xFF800020);
const Color _maroonDark = Color(0xFF4A0012);
const Color _maroonLight = Color(0xFFA8284A);
const Color _fieldBg = Color(0xFFFBF3F5);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _Bubble {
  const _Bubble(this.fx, this.fy, this.size, this.phase, this.opacity);
  final double fx; // posisi horizontal (0-1 dari lebar layar)
  final double fy; // posisi vertikal (0-1 dari tinggi layar)
  final double size;
  final double phase;
  final double opacity;
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscure = true;

  // Animasi masuk (sekali jalan) dan animasi melayang (berulang)
  late final AnimationController _entrance;
  late final AnimationController _float;

  static const _bubbles = <_Bubble>[
    _Bubble(0.08, 0.06, 90, 0.0, 0.10),
    _Bubble(0.78, 0.04, 140, 1.5, 0.08),
    _Bubble(0.88, 0.26, 60, 3.0, 0.12),
    _Bubble(-0.05, 0.30, 110, 4.5, 0.07),
    _Bubble(0.55, 0.20, 36, 2.2, 0.14),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final error = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login gagal: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Membungkus widget dengan animasi fade + geser naik, berurutan (staggered)
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
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
      child: Column(
        children: [
          FadeTransition(
            opacity: logoFade,
            child: ScaleTransition(
              scale: logoScale,
              // Logo melayang naik-turun pelan
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, math.sin(_float.value * 2 * math.pi) * 6),
                  child: child,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/logo_nutribells.png',
                      width: 104,
                      height: 104,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _stagger(
            begin: 0.2,
            end: 0.6,
            child: const Text(
              'NutriBells',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _stagger(
            begin: 0.3,
            end: 0.7,
            child: Text(
              'Sehat dimulai dari kebiasaan kecil',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
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
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                  begin: 0.4,
                  end: 0.75,
                  child: const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _maroon,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _stagger(
                  begin: 0.45,
                  end: 0.8,
                  child: const Text(
                    'Masuk untuk melanjutkan',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 24),
                _stagger(
                  begin: 0.5,
                  end: 0.85,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: _maroon,
                    validator: Validators.validateEmail,
                    decoration: _decoration('Email', Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
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
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _stagger(begin: 0.66, end: 1.0, child: _buildLoginButton()),
                const SizedBox(height: 16),
                _stagger(
                  begin: 0.72,
                  end: 1.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun?',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                        style: TextButton.styleFrom(
                          foregroundColor: _maroon,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: const Text(
                          'Daftar di sini',
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

  Widget _buildLoginButton() {
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
          onTap: _isLoading ? null : _handleLogin,
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
                      'Masuk',
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
          // Latar gradasi maroon
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
          // Lingkaran-lingkaran melayang
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
