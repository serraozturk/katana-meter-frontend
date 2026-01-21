import 'package:flutter/material.dart';

import '../app/analysis_controller.dart';
import '../widgets/katana_background.dart';
import '../widgets/status_bar.dart';
import '../widgets/faq_section.dart'; // <-- sende hangi path ise onu kullan

import 'early_access.dart';
import '../widgets/loudence_header_bar.dart';

class CompatibilityPage extends StatelessWidget {
  final AnalysisResult result;

  const CompatibilityPage({super.key, required this.result});
  @override
  Widget build(BuildContext context) {
    final controller = AnalysisScope.of(context);
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    final r = result;

    return ValueListenableBuilder<AnalysisState>(
      valueListenable: controller,
      builder: (_, state, __) {
        final isBusy =
            state.phase == AnalysisPhase.uploading ||
            state.phase == AnalysisPhase.processing;

        return Scaffold(
          body: KatanaBackground(
            child: Stack(
              children: [
                if (state.phase != AnalysisPhase.idle &&
                    state.phase != AnalysisPhase.done)
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
                          // status bar görünürse üstte boşluk
                          if (state.phase != AnalysisPhase.idle &&
                              state.phase != AnalysisPhase.done)
                            const SizedBox(height: 62),

                          LoudenceHeaderBar(
                            onBack: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(height: 12),
                          const SoftDivider(),
                          const SizedBox(height: 22),
                          const Text(
                            'Platform Compatibility Check',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: Color.fromARGB(255, 90, 170, 255),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'How your song will behave across major platforms.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19.5,
                              height: 1.45,
                              color: Color.fromARGB(255, 159, 216, 255),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: Builder(
                                builder: (_) {
                                  final yt = mapStatus(
                                    checkPlatform(
                                      targetLufs: -14,
                                      maxTruePeak: -1.0,
                                      r: r,
                                    ),
                                    r,
                                    isMobile: isMobile,
                                  );

                                  final sp = mapStatus(
                                    checkPlatform(
                                      targetLufs: -14,
                                      maxTruePeak: -1.0,
                                      r: r,
                                    ),
                                    r,
                                    isMobile: isMobile,
                                  );

                                  final apple = mapStatus(
                                    checkPlatform(
                                      targetLufs:
                                          -16, // 🔥 SADECE BURASI FARKLI
                                      maxTruePeak: -1.0,
                                      r: r,
                                    ),
                                    r,
                                    isMobile: isMobile,
                                  );

                                  final dz = mapStatus(
                                    checkPlatform(
                                      targetLufs: -14,
                                      maxTruePeak: -1.0,
                                      r: r,
                                    ),
                                    r,
                                    isMobile: isMobile,
                                  );

                                  return Column(
                                    children: [
                                      _PlatformRow(
                                        leadingType: _LeadingType.youtube,
                                        statusType: yt.type,
                                        statusText: yt.text,
                                      ),
                                      const SizedBox(height: 10),

                                      _PlatformRow(
                                        leadingType: _LeadingType.spotify,
                                        statusType: sp.type,
                                        statusText: sp.text,
                                      ),
                                      const SizedBox(height: 10),

                                      _PlatformRow(
                                        leadingType: _LeadingType.appleMusic,
                                        statusType: apple.type,
                                        statusText: apple.text,
                                      ),
                                      const SizedBox(height: 10),

                                      _PlatformRow(
                                        leadingType: _LeadingType.deezer,
                                        statusType: dz.type,
                                        statusText: dz.text,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4FAAF7),
                                    foregroundColor: const Color(0xFF08141F),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ).copyWith(
                                    overlayColor:
                                        MaterialStateProperty.resolveWith<
                                          Color?
                                        >((states) {
                                          if (states.contains(
                                            MaterialState.pressed,
                                          )) {
                                            return Colors.black.withOpacity(
                                              0.08,
                                            );
                                          }
                                          if (states.contains(
                                            MaterialState.hovered,
                                          )) {
                                            return Colors.white.withOpacity(
                                              0.08,
                                            );
                                          }
                                          return null;
                                        }),
                                  ),

                                  onPressed:
                                      isBusy
                                          ? null
                                          : () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        const EarlyAccessPage(),
                                              ),
                                            );
                                          },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Optimize for Platforms',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.chevron_right, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // --- FAQ ---
                          const SizedBox(height: 28),
                          const SoftDivider(),
                          const SizedBox(height: 24),

                          // Rules placeholder (kuralları backend ekibi atınca listeyi buraya koyacağız)

                          // FAQ main sayfada
                          isMobile
                              ? const FaqSection()
                              : Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 860,
                                  ),
                                  child: const FaqSection(),
                                ),
                              ),

                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              _FooterLink(text: 'Terms'),
                              SizedBox(width: 10),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 120, 128, 144),
                                ),
                              ),
                              SizedBox(width: 10),
                              _FooterLink(text: 'Privacy Policy'),
                            ],
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
      },
    );
  }
}

enum PlatformStatus { compatible, willNormalize, belowTarget, clipping }

PlatformStatus checkPlatform({
  required double targetLufs,
  required double maxTruePeak,
  required AnalysisResult r,
}) {
  if (r.truePeak >= maxTruePeak) {
    return PlatformStatus.clipping;
  }

  final diff = r.lufs - targetLufs;

  if (diff > 1.0) {
    return PlatformStatus.willNormalize;
  }

  if (diff < -1.0) {
    return PlatformStatus.belowTarget;
  }

  return PlatformStatus.compatible;
}

({_StatusType type, String text}) mapStatus(
  PlatformStatus s,
  AnalysisResult r, {
  required bool isMobile,
}) {
  final g = r.gainAdjustment.abs().toStringAsFixed(1);
  final sign = r.gainAdjustment > 0 ? '+' : '−';

  switch (s) {
    case PlatformStatus.clipping:
      return (
        type: _StatusType.error,
        text:
            isMobile
                ? 'Clipping · $sign$g dB'
                : 'Clipping risk · Will be normalized ($g dB)',
      );

    case PlatformStatus.willNormalize:
      return (
        type: _StatusType.warning,
        text: isMobile ? 'Normalize $sign$g dB' : 'Will be normalized ($g dB)',
      );

    case PlatformStatus.belowTarget:
      return (
        type: _StatusType.warning,
        text: isMobile ? 'Boost $sign$g dB' : 'Will be boosted ($g dB)',
      );

    case PlatformStatus.compatible:
      return (type: _StatusType.ok, text: 'Ready');
  }
}

enum _LeadingType { youtube, spotify, appleMusic, deezer }

enum _StatusType { warning, error, ok }

class _PlatformRow extends StatelessWidget {
  final _LeadingType leadingType;
  final _StatusType statusType;
  final String statusText;

  const _PlatformRow({
    required this.leadingType,
    required this.statusType,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final bg = const Color.fromARGB(255, 24, 27, 35).withOpacity(0.55);
    final isWeb = MediaQuery.of(context).size.width >= 900;

    IconData leadingIcon;
    String name;
    Color leadingColor;

    switch (leadingType) {
      case _LeadingType.youtube:
        leadingIcon = Icons.play_circle_fill;
        name = 'YouTube';
        leadingColor = const Color.fromARGB(255, 230, 60, 60);
        break;
      case _LeadingType.spotify:
        leadingIcon = Icons.circle;
        name = 'Spotify';
        leadingColor = const Color.fromARGB(255, 60, 210, 120);
        break;
      case _LeadingType.appleMusic:
        leadingIcon = Icons.music_note;
        name = 'Apple Music';
        leadingColor = const Color.fromARGB(255, 210, 220, 235);
        break;
      case _LeadingType.deezer:
        leadingIcon = Icons.graphic_eq;
        name = 'Deezer';
        leadingColor = const Color(0xFFEF5466); // Deezer pink
        break;
    }

    IconData statusIcon;
    Color statusColor;

    switch (statusType) {
      case _StatusType.warning:
        statusIcon = Icons.warning_amber_rounded;
        statusColor = const Color(0xFFF4C430); // amber / slight deviation
        break;

      case _StatusType.error:
        statusIcon = Icons.close;
        statusColor = const Color(0xFFFF7A5A); // coral red / too loud
        break;

      case _StatusType.ok:
        statusIcon = Icons.check;
        statusColor = const Color(0xFF3BC9B0); // teal / safe
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 16 : 12,
        vertical: isWeb ? 18 : 14,
      ),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 SOL BLOK — PLATFORM
          Row(
            children: [
              Icon(leadingIcon, color: leadingColor, size: isWeb ? 24 : 22),

              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  fontSize: isWeb ? 17.5 : 15.5,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 232, 240, 255),
                ),
              ),
            ],
          ),

          const Spacer(),
          Container(
            width: 1,
            height: isWeb ? 32 : 26,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: Colors.white.withOpacity(0.08),
          ),

          // 🔹 SAĞ BLOK — SONUÇ
          _buildStatusBadge(
            icon: statusIcon,
            color: statusColor,
            text: statusText,
            isWeb: isWeb,
          ),
        ],
      ),
    );
  }
}

Widget _buildStatusBadge({
  required IconData icon,
  required Color color,
  required String text,
  required bool isWeb,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: isWeb ? 14 : 12,
      vertical: isWeb ? 8 : 6,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.45)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isWeb ? 18 : 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: isWeb ? 16.5 : 13.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color.fromARGB(255, 150, 158, 174),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
