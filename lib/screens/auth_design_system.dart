// ═══════════════════════════════════════════════════════════════════════════
//  auth_design_system.dart
//  Shared constants + widgets used by SignupScreen & RegisterScreen
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const Color kBg       = Color(0xFFF8F9FA);
const Color kCardBg   = Color(0xFFF1F5F9);
const Color kTextMain = Color(0xFF0F172A);
const Color kTextSub  = Color(0xFF64748B);
const Color kAccent   = Color(0xFF6366F1);
const Color kDark     = Color(0xFF0F172A);

// ── Logo ────────────────────────────────────────────────────────────────────
class AuthLogo extends StatelessWidget {
  final bool onDark;
  const AuthLogo({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onDark ? Colors.white : kDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.architecture_rounded,
          size: 18,
          color: onDark ? kDark : Colors.white,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        'ArchiManager',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: onDark ? Colors.white : kTextMain,
        ),
      ),
    ],
  );
}

// ── Section label ──────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: kTextSub,
      letterSpacing: 1.2,
    ),
  );
}

// ── Auth text field ────────────────────────────────────────────────────────
class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final String? hintText;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.hintText,
  });

  OutlineInputBorder _border(Color c, {double w = 1.0}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(11),
    borderSide: BorderSide(color: c, width: w),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kTextMain,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: kTextMain),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: kTextSub, fontSize: 13),
          prefixIcon: Icon(prefixIcon, size: 16, color: kTextSub),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, size: 16, color: kTextSub),
                )
              : null,
          filled: true,
          fillColor: kCardBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: _border(const Color(0xFFE2E8F0)),
          enabledBorder: _border(const Color(0xFFE2E8F0)),
          focusedBorder: _border(kAccent, w: 1.5),
          errorBorder: _border(const Color(0xFFEF4444)),
          focusedErrorBorder: _border(const Color(0xFFEF4444), w: 1.5),
          errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
        ),
      ),
    ],
  );
}

// ── Two-column row (responsive) ────────────────────────────────────────────
class TwoColumnRow extends StatelessWidget {
  final Widget left, right;
  const TwoColumnRow({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 500;
    return narrow
        ? Column(children: [left, const SizedBox(height: 12), right])
        : Row(children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ]);
  }
}

// ── Password strength indicator ────────────────────────────────────────────
class PasswordStrength extends StatelessWidget {
  final String password;
  const PasswordStrength({super.key, required this.password});

  int get _score {
    if (password.isEmpty) return 0;
    int s = 0;
    if (password.length >= 6) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  Color _color(int s) => s <= 1
      ? const Color(0xFFEF4444)
      : s == 2
          ? const Color(0xFFF59E0B)
          : s == 3
              ? const Color(0xFF10B981)
              : kAccent;

  String _label(int s) => s <= 1
      ? 'Faible'
      : s == 2
          ? 'Moyen'
          : s == 3
              ? 'Fort'
              : 'Très fort';

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final s = _score;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < s ? _color(s) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          const SizedBox(height: 4),
          Text(
            'Force : ${_label(s)}',
            style: TextStyle(
              fontSize: 11,
              color: _color(s),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFEF4444)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
          ),
        ),
      ],
    ),
  );
}

// ── Feature item (left dark panel) ────────────────────────────────────────
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const FeatureItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1))),
    ],
  );
}

// ── Dark panel (left side) ─────────────────────────────────────────────────
class DarkPanel extends StatelessWidget {
  final String? backgroundImage;
  final String headline;
  final String subline;
  final List<Widget> features;

  const DarkPanel({
    super.key,
    this.backgroundImage,
    required this.headline,
    required this.subline,
    required this.features,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: kDark,
    child: Stack(
      children: [
        if (backgroundImage != null)
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(backgroundImage!, fit: BoxFit.cover),
            ),
          ),
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthLogo(onDark: true),
              const Spacer(),
              Text(
                headline,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                subline,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 44),
              ...features,
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Grid background painter ────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Primary button ─────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kDark.withOpacity(0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
    ),
  );
}

// ── Link row (bottom of form) ──────────────────────────────────────────────
class AuthLinkRow extends StatelessWidget {
  final String question;
  final String linkText;
  final VoidCallback onTap;

  const AuthLinkRow({
    super.key,
    required this.question,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(question, style: const TextStyle(color: kTextSub, fontSize: 14)),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: onTap,
        child: Text(
          linkText,
          style: const TextStyle(
            color: kAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: kAccent,
          ),
        ),
      ),
    ],
  );
}

// ── Slide+Fade entry animation mixin ──────────────────────────────────────
mixin AuthAnimMixin<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late AnimationController animCtrl;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  void initAuthAnim() {
    animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    fadeAnim = CurvedAnimation(parent: animCtrl, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeOut));
    animCtrl.forward();
  }

  void disposeAuthAnim() => animCtrl.dispose();

  Widget animatedForm({required Widget child}) => FadeTransition(
    opacity: fadeAnim,
    child: SlideTransition(position: slideAnim, child: child),
  );
}