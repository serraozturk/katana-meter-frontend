// lib/legal/legal_footer.dart
import 'package:flutter/material.dart';
import 'legal_dialog.dart';

class LegalFooter extends StatelessWidget {
  const LegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Center(
        child: Wrap(
          spacing: 6,
          children: [
            _LegalLink(
              text: 'Terms',
              onTap: () => LegalDialog.open(context, LegalType.terms),
            ),
            const Text('|', style: TextStyle(color: Colors.white38)),
            _LegalLink(
              text: 'Privacy',
              onTap: () => LegalDialog.open(context, LegalType.privacy),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _LegalLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF9FD8FF),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
