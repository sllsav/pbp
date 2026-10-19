import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/constants.dart';

class _Bubble {
  const _Bubble(this.fx, this.fy, this.size, this.phase, this.opacity);
  final double fx;
  final double fy;
  final double size;
  final double phase;
  final double opacity;
}

/// Kerangka halaman form bertema maroon: header gradasi beranimasi,
/// kartu putih melengkung, dan isi yang muncul berurutan.
class MaroonFormPage extends StatefulWidget {
  const MaroonFormPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    this.formKey,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;

  @override
  State<MaroonFormPage> createState() => _MaroonFormPageState();
}

class _MaroonFormPageState extends State<MaroonFormPage>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _loop;

  static const _bubbles = <_Bubble>[
    _Bubble(0.80, 0.03, 120, 0.5, 0.09),
    _Bubble(0.05, 0.08, 80, 2.0, 0.10),
    _Bubble(0.62, 0.20, 34, 3.5, 0.14),
    _Bubble(-0.06, 0.24, 100, 5.0, 0.07),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
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

  Widget _bubble(_Bubble b, Size size) {
    return Positioned(
      left: size.width * b.fx,
      top: size.height * b.fy,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, child) {
          final t = _loop.value * 2 * math.pi + b.phase;
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
            color: Color.fromRGBO(255, 255, 255, b.opacity),
          ),
        ),
      ),
    );
  }

  Widget _ring(double p) {
    final size = 72 + p * 40;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color.fromRGBO(255, 255, 255, (1 - p) * 0.4),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final iconScale = CurveTween(
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ).animate(_entrance);
    final iconFade = CurveTween(
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ).animate(_entrance);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 24, 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          FadeTransition(
            opacity: iconFade,
            child: ScaleTransition(
              scale: iconScale,
              child: SizedBox(
                width: 112,
                height: 112,
                child: AnimatedBuilder(
                  animation: _loop,
                  builder: (context, child) {
                    final t = _loop.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        for (var i = 0; i < 2; i++) _ring((t * 2 + i / 2) % 1.0),
                        Transform.translate(
                          offset: Offset(0, math.sin(t * 2 * math.pi) * 4),
                          child: child,
                        ),
                      ],
                    );
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, size: 36, color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _stagger(
            0.2,
            0.6,
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _stagger(
            0.28,
            0.68,
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurveTween(
        curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
      ).animate(_entrance),
    );
    final fade = CurveTween(
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    ).animate(_entrance);

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _stagger(
            math.min(0.65, 0.3 + i * 0.07),
            math.min(1.0, math.min(0.65, 0.3 + i * 0.07) + 0.35),
            widget.children[i],
          ),
      ],
    );

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
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
          child: widget.formKey == null
              ? column
              : Form(key: widget.formKey, child: column),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
          for (final b in _bubbles) _bubble(b, size),
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
                        Expanded(child: _buildCard()),
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

/// Kolom isian bertema maroon (latar pink lembut, garis maroon saat fokus).
class MaroonField extends StatefulWidget {
  const MaroonField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  State<MaroonField> createState() => _MaroonFieldState();
}

class _MaroonFieldState extends State<MaroonField> {
  late bool _hide = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );

    return TextFormField(
      controller: widget.controller,
      obscureText: _hide,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.black54),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(widget.icon, color: AppColors.primary),
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () => setState(() => _hide = !_hide),
                icon: Icon(
                  _hide
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black45,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.softBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: border(Colors.transparent, 1),
        enabledBorder: border(Colors.transparent, 1),
        focusedBorder: border(AppColors.primary, 1.8),
        errorBorder: border(Colors.red.shade300, 1.2),
        focusedErrorBorder: border(Colors.red.shade400, 1.8),
      ),
    );
  }
}

/// Tombol gradasi maroon dengan animasi loading.
class MaroonButton extends StatelessWidget {
  const MaroonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(128, 0, 32, loading ? 0.15 : 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: loading ? null : onPressed,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
