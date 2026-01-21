import 'package:flutter/material.dart';

class LoudenceHeader extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;

  const LoudenceHeader({super.key, this.showBack = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          )
        else
          const SizedBox(width: 6),

        // Logo mark + word
        Image.asset('assets/images/loudence_mark.png', height: 22),
        const SizedBox(width: 10),
        Image.asset('assets/images/loudence_word.png', height: 18),

        const Spacer(),

        // ✅ Hamburger kaldırıldı -> hiçbir şey koymuyoruz
        const SizedBox(width: 10),
      ],
    );
  }
}
