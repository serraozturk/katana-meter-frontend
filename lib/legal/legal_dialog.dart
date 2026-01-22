// lib/legal/legal_dialog.dart
import 'package:flutter/material.dart';
import 'legal_texts.dart';

enum LegalType { terms, privacy }

class LegalDialog {
  static void open(BuildContext context, LegalType type) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _LegalPopup(type: type),
    );
  }
}

class _LegalPopup extends StatelessWidget {
  final LegalType type;

  const _LegalPopup({required this.type});

  @override
  Widget build(BuildContext context) {
    final isTerms = type == LegalType.terms;

    return Dialog(
      backgroundColor: const Color(0xFF0E121B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTerms ? 'Terms & Conditions' : 'Privacy Policy',
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7CC4FF),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    isTerms ? kAppTermsText : kAppPrivacyText,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: Color(0xFFD0DBEA),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Color(0xFF4FAAF7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
