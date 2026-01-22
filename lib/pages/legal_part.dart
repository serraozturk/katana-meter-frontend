import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// LEGAL TYPE
/// ------------------------------------------------------------
enum LegalType { terms, privacy }

/// ------------------------------------------------------------
/// PUBLIC HELPER (BURADAN ÇAĞIRACAKSIN)
/// ------------------------------------------------------------
void showLegalDialog(BuildContext context, LegalType type) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _LegalDialog(type: type),
  );
}

/// ------------------------------------------------------------
/// POPUP DIALOG
/// ------------------------------------------------------------
class _LegalDialog extends StatelessWidget {
  final LegalType type;

  const _LegalDialog({required this.type});

  @override
  Widget build(BuildContext context) {
    final isTerms = type == LegalType.terms;

    return Dialog(
      backgroundColor: const Color(0xFF0E121B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Text(
                isTerms ? 'Early Access Terms' : 'Privacy Policy',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7CC4FF),
                ),
              ),

              const SizedBox(height: 10),
              const Divider(color: Colors.white12),

              // CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    isTerms ? _termsText : _privacyText,
                    style: const TextStyle(
                      fontSize: 13.8,
                      height: 1.6,
                      color: Color(0xFFD0DBEA),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // CLOSE BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4FAAF7),
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

/// ------------------------------------------------------------
/// LEGAL TEXTS (MINIMUM – STORE SAFE)
/// ------------------------------------------------------------
const String _termsText = '''
Loudence Early Access provides selected users with early access to AI-powered Mix & Mastering features that are currently under development.

Early access features may be incomplete, unstable, or subject to change at any time without prior notice.

Loudence does not guarantee the availability, accuracy, performance, or reliability of early access features.

By participating in the Early Access Program, you agree not to misuse the service, attempt unauthorized access, or use the service for illegal purposes.

Loudence reserves the right to modify, suspend, or revoke early access at any time, with or without notice.

To the maximum extent permitted by law, Loudence shall not be liable for any damages, including data loss or business interruption, arising from the use of early access features.

Contact: support@loudence.com
''';

const String _privacyText = '''
Loudence collects your email address solely for the purpose of notifying you about early access availability and product updates.

Your email address is stored securely and is not shared with third parties.

We do not sell, rent, or trade your personal information.

You may request deletion of your personal data at any time.

Contact: support@loudence.com
''';
