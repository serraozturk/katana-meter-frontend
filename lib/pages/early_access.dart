import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/gestures.dart';

import '../app/analysis_controller.dart';
import '../widgets/katana_background.dart';
import '../widgets/status_bar.dart';
import '../widgets/faq_section.dart';
import '../widgets/loudence_header_bar.dart';
import 'package:http/http.dart' as http;

class EarlyAccessPage extends StatefulWidget {
  const EarlyAccessPage({super.key});

  @override
  State<EarlyAccessPage> createState() => _EarlyAccessPageState();
}

class _EarlyAccessPageState extends State<EarlyAccessPage> {
  final _email = TextEditingController();
  bool _agree = false;
  bool _submitted = false;
  String? _errorText;

  late TapGestureRecognizer _termsTap;
  late TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () {};
    _privacyTap = TapGestureRecognizer()..onTap = () {};
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AnalysisScope.of(context);
    final state = controller.value;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;

    final isBusy =
        state.phase == AnalysisPhase.uploading ||
        state.phase == AnalysisPhase.processing;
    return Scaffold(
      body: KatanaBackground(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: GlobalStatusBar(state: state),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.phase != AnalysisPhase.idle &&
                          state.phase != AnalysisPhase.done)
                        const SizedBox(height: 62),

                      LoudenceHeaderBar(
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 20),
                      const SoftDivider(),
                      const SizedBox(height: 18),

                      /// HERO TITLE
                      LayoutBuilder(
                        builder: (context, c) {
                          final isMobile = c.maxWidth < 520;
                          return Column(
                            children: [
                              Text(
                                "AI Mix & Mastering is coming. You're early.",
                                textAlign: TextAlign.center,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: isMobile ? 22 : 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                  color: const Color(
                                    0xFF7CC4FF,
                                  ), // 🔵 aynı mavi
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      /// SUBTITLE
                      LayoutBuilder(
                        builder: (context, c) {
                          final isMobile = c.maxWidth < 520;
                          return Text(
                            'Loudence will soon move from analysis to action.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 15.5 : 19.5,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9FB4CC),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      /// MAIN CARD
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                255,
                                24,
                                27,
                                35,
                              ).withOpacity(0.55),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// BENEFITS
                                LayoutBuilder(
                                  builder: (context, c) {
                                    final isMobile = c.maxWidth < 520;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Early Access members will receive',
                                          style: TextStyle(
                                            fontSize: isMobile ? 16 : 18,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF7CC4FF),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        _ValueItem(
                                          text:
                                              'AI Mix & Mastering access (Phase 2)',
                                          isMobile: isMobile,
                                        ),
                                        _ValueItem(
                                          text:
                                              'Early feature access before public release',
                                          isMobile: isMobile,
                                        ),
                                        _ValueItem(
                                          text:
                                              'Founding user pricing (lower than public plans)',
                                          isMobile: isMobile,
                                        ),
                                        _ValueItem(
                                          text:
                                              'Ability to test and help shape the system',
                                          isMobile: isMobile,
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                if (_submitted)
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 12),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size:
                                                  isMobile
                                                      ? 26
                                                      : 34, // ⬅️ biraz küçültüldü, daha dengeli
                                              color: Color(0xFF3BC9B0),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "You're on the list.",
                                              style: TextStyle(
                                                fontSize: isMobile ? 18.5 : 21,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF3BC9B0),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 12),

                                        Text(
                                          isMobile
                                              ? 'We’ll notify you when AI Mix & Mastering is ready and send you an early access discount.'
                                              : 'We’ll notify you when AI Mix & Mastering is ready\nand send you an early access discount.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isMobile ? 16.5 : 17.5,
                                            height: isMobile ? 1.5 : 1.6,
                                            fontWeight:
                                                FontWeight
                                                    .w500, // ⬅️ biraz güçlendi
                                            color: Color(0xFFD0DBEA),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 520,
                                      ),
                                      child: Column(
                                        children: [
                                          /// EMAIL INPUT
                                          TextField(
                                            controller: _email,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            onChanged: (_) => setState(() {}),
                                            decoration: InputDecoration(
                                              hintText: 'Email address',
                                              filled: true,
                                              fillColor: const Color.fromARGB(
                                                255,
                                                16,
                                                18,
                                                23,
                                              ).withOpacity(0.55),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: const Color(
                                                    0xFF4FAAF7,
                                                  ).withOpacity(0.35),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF4FAAF7),
                                                  width: 1.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (_errorText != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: Text(
                                                _errorText!,
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),

                                          /// CHECKBOX + TERMS
                                          Row(
                                            children: [
                                              Theme(
                                                data: Theme.of(
                                                  context,
                                                ).copyWith(
                                                  checkboxTheme: CheckboxThemeData(
                                                    fillColor:
                                                        MaterialStateProperty.resolveWith((
                                                          states,
                                                        ) {
                                                          if (states.contains(
                                                            MaterialState
                                                                .selected,
                                                          )) {
                                                            return const Color(
                                                              0xFF4FAAF7,
                                                            );
                                                          }
                                                          return Colors
                                                              .transparent;
                                                        }),
                                                    side: BorderSide(
                                                      color: const Color(
                                                        0xFF4FAAF7,
                                                      ).withOpacity(0.6),
                                                    ),
                                                  ),
                                                ),
                                                child: Checkbox(
                                                  value: _agree,
                                                  onChanged:
                                                      isBusy
                                                          ? null
                                                          : (v) => setState(
                                                            () =>
                                                                _agree =
                                                                    v ?? false,
                                                          ),
                                                ),
                                              ),
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      color: Color.fromARGB(
                                                        255,
                                                        190,
                                                        200,
                                                        214,
                                                      ),
                                                    ),
                                                    children: [
                                                      const TextSpan(
                                                        text: 'I agree to ',
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            'Early Access Terms',
                                                        style: const TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: Color(
                                                            0xFF9FD8FF,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        recognizer: _termsTap,
                                                      ),
                                                      const TextSpan(
                                                        text: ' & ',
                                                      ),
                                                      TextSpan(
                                                        text: 'Privacy Policy',
                                                        style: const TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: Color(
                                                            0xFF9FD8FF,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        recognizer: _privacyTap,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          /// CTA
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed:
                                                  (isBusy ||
                                                          _submitted ||
                                                          !_agree ||
                                                          !_isValidEmail(
                                                            _email.text,
                                                          ))
                                                      ? null
                                                      : () async {
                                                        setState(() {
                                                          _errorText = null;
                                                        });

                                                        final email =
                                                            _email.text.trim();
                                                        await Future.delayed(
                                                          Duration.zero,
                                                        );
                                                        try {
                                                          await submitEarlyAccessEmail(
                                                            email,
                                                          );

                                                          if (!mounted) return;

                                                          setState(() {
                                                            _submitted = true;
                                                          });
                                                        } catch (e) {
                                                          debugPrint(
                                                            'EARLY ACCESS SUBMIT ERROR: $e',
                                                          );

                                                          if (!mounted) return;

                                                          // 🔥 ilk denemede sessiz kal
                                                          setState(() {
                                                            _errorText =
                                                                'Could not submit your email. Please try again.';
                                                          });
                                                        }
                                                      },

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF3A8DDE,
                                                ),
                                                foregroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      8,
                                                      12,
                                                      20,
                                                    ),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Get Early Access',
                                                style: TextStyle(
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 42),
                      const SoftDivider(),
                      const SizedBox(height: 24),

                      // Rules placeholder (kuralları backend ekibi atınca listeyi buraya koyacağız)

                      // FAQ main sayfada
                      isMobile
                          ? const FaqSection()
                          : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 860),
                              child: const FaqSection(),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }

  Future<void> submitEarlyAccessEmail(String email) async {
    final uri = Uri.parse(
      'https://script.google.com/macros/s/AKfycbzD2IeisVmrXaa2gNQwUaDAqZe2i-ba3IXO7BULZOv7m-kZk9FmBgnwYHdo_ibfrVxB/exec',
    );

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'email': email, 'platform': 'mobile'},
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('STATUS: ${response.statusCode}');

      // ✅ 200 VE 302 BAŞARI
      if (response.statusCode == 200 || response.statusCode == 302) {
        return;
      }

      throw Exception('Unexpected status: ${response.statusCode}');
    } catch (e) {
      debugPrint('SUBMIT ERROR: $e');
      rethrow;
    }
  }
}

/// VALUE ITEM
class _ValueItem extends StatelessWidget {
  final String text;
  final bool isMobile;

  const _ValueItem({required this.text, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle,
              size: isMobile ? 18 : 20,
              color: const Color(0xFF3BC9B0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isMobile ? 15.5 : 16.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 200, 208, 222),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
