import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isWide;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isWide = true,
  });

  // ===== Brand Tokens =====
  static const _bgEnabled = Color(0xFF4FAAF7); // 🔵 primary blue
  static const _bgHover = Color(0xFF6BB9FF);
  static const _bgPressed = Color(0xFF3C93DB);

  static const _textEnabled = Color(0xFF08141F); // koyu text
  static const _textActive = Color(0xFF08141F);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: isWide ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),

          // ===== Background =====
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled) return _bgEnabled.withOpacity(0.45);
            if (states.contains(WidgetState.pressed)) return _bgPressed;
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return _bgHover;
            }
            return _bgEnabled;
          }),

          // ===== Foreground =====
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled) return _textEnabled.withOpacity(0.55);
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed)) {
              return _textActive;
            }
            return _textEnabled;
          }),

          // ===== Border =====
          side: const WidgetStatePropertyAll(BorderSide.none),

          // ===== Shape =====
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // ⬅️ 10 → 12
            ),
          ),

          // ===== Overlay =====
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled) return Colors.transparent;
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withOpacity(0.10);
            }
            return Colors.transparent;
          }),

          // ===== Cursor =====
          mouseCursor: WidgetStatePropertyAll(
            enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          ),

          // ===== Subtle depth =====
          shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.35)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w700, // ⬅️ güçlendi
            letterSpacing: -0.1, // ⬅️ daha modern
          ),
        ),
      ),
    );
  }
}
