import 'package:flutter/material.dart';
import '../app/analysis_controller.dart';
import '../widgets/katana_background.dart';
import '../widgets/status_bar.dart';

import 'compatibility_page.dart';
import 'early_access.dart';
import '../widgets/faq_section.dart';
import '../widgets/loudence_header_bar.dart';
import '../widgets/metric_info_popup.dart';

// NOTE: UploadPage’de kullandığın FAQ widget’ını aynı sayfada tekrar kullanıyorum.
// En doğrusu: _FaqSection'ı widgets/faq_section.dart'a taşıyıp iki sayfada import etmek.
// Şimdilik hızlı ilerlemek için burada kullanmaya devam edebilirsin.

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  Future<bool> _confirmDiscard(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // ⬅️ dışarı tıklanamaz
      barrierColor: Colors.black.withOpacity(0.65), // ⬅️ arka plan karardı
      builder: (_) => const _ConfirmBackDialog(),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AnalysisScope.of(context);
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;

    return ValueListenableBuilder<AnalysisState>(
      valueListenable: controller,
      builder: (_, state, __) {
        // 🔴 EKLENEN FAIL STATE (BURASI)
        if (state.phase == AnalysisPhase.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message ?? 'Analysis failed.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.reset();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context, 'reset');
                      }
                    },
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          );
        }

        final isReady =
            state.phase == AnalysisPhase.done && state.result != null;

        // Back confirm: sadece "done" durumundayken soralım
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            // Alt sayfalardan dönüşte tetiklenmesin
            if (didPop) return;

            final hasData =
                state.phase == AnalysisPhase.done && state.result != null;

            if (hasData) {
              final ok = await _confirmDiscard(context);
              if (!ok) return;
            }

            // 🔥 SADECE UPLOAD PAGE'E DÖNERKEN RESET
            controller.reset();

            if (context.mounted) {
              Navigator.pop(context, 'reset');
            }
          },

          child: Scaffold(
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
                              onBack: () async {
                                final hasData =
                                    state.phase == AnalysisPhase.done &&
                                    state.result != null;

                                if (hasData) {
                                  final ok = await _confirmDiscard(context);
                                  if (!ok) return;
                                }

                                controller.reset();
                                if (context.mounted) {
                                  Navigator.pop(context, 'reset');
                                }
                              },
                            ),

                            const SizedBox(height: 20),
                            const SoftDivider(),
                            const SizedBox(height: 26),

                            Text(
                              'Analysis Results',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                height: 1.2,
                                color: Color.fromARGB(255, 90, 170, 255),
                              ),
                            ),

                            const SizedBox(height: 8),
                            Text(
                              "Here are your song’s detailed loudness metrics",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 19.5,
                                height: 1.5,
                                color: Color(0xFF9FD8FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 22),

                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1100,
                                ),
                                child: _MetricsGrid(
                                  enabled: isReady,
                                  result: state.result,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            // Advanced details (ince bar, butonların ÜSTÜNDE)
                            if (isReady) ...[
                              _AdvancedDetailsCard(result: state.result!),
                              const SizedBox(height: 18),
                            ],

                            const SizedBox(height: 15),

                            // Buttons (max width)
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),
                                child: Column(
                                  children: [
                                    _PrimaryWideButton(
                                      text: 'Platform Compatibility Check',
                                      onPressed:
                                          isReady
                                              ? () => Navigator.of(
                                                context,
                                              ).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => CompatibilityPage(
                                                        result: state.result!,
                                                      ),
                                                ),
                                              )
                                              : null,
                                    ),
                                    const SizedBox(height: 10),
                                    _SecondaryWideButton(
                                      onPressed:
                                          isReady
                                              ? () => Navigator.of(
                                                context,
                                              ).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          const EarlyAccessPage(),
                                                ),
                                              )
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 26),
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

                            // Footer (istersen UploadPage’deki ile aynı bırakabiliriz)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Terms',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 150, 158, 174),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '|',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 120, 128, 144),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 150, 158, 174),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
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
          ),
        );
      },
    );
  }
}

void showMetricPopup(
  BuildContext context,
  String title,
  String value,
  String status,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    builder:
        (_) => MetricInfoPopup(
          value: '$value',
          status: status,
          description: getMetricDescription(title),
        ),
  );
}

class _ConfirmBackDialog extends StatelessWidget {
  const _ConfirmBackDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF121824),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4FAAF7).withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4FAAF7).withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 28,
                  color: Color(0xFF4FAAF7),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Go back?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE8F0FF),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your analysis results will be permanently cleared.\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.5,
                  color: Color(0xFF9FB4CC),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _PopupButton(
                      text: 'Cancel',
                      filled: false,
                      onTap: () {
                        Navigator.maybePop(context, false);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PopupButton(
                      text: 'Go back',
                      filled: true,
                      onTap: () {
                        Navigator.maybePop(context, true);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupButton extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const _PopupButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF4FAAF7) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4FAAF7).withOpacity(0.45)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: filled ? const Color(0xFF08141F) : const Color(0xFF4FAAF7),
          ),
        ),
      ),
    );
  }
}

/// ---------- Top header (UploadPage ile aynı) ----------

/// ---------- Metrics (5 kutu) ----------
class _MetricsGrid extends StatelessWidget {
  final bool enabled;
  final AnalysisResult? result;

  const _MetricsGrid({required this.enabled, required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    String fmtNum(double v, {int frac = 1}) => v.toStringAsFixed(frac);

    final items = [
      _MetricItem(
        title: 'LUFS',
        value: r != null ? fmtNum(r.lufs) : '--',
        unit: 'LUFS',
        badge: r?.loudnessLabel ?? '...',
        valueColor: const Color(0xFF7CC4FF),
      ),

      _MetricItem(
        title: 'Gain',
        value: r != null ? fmtNum(r.gainAdjustment) : '--',
        unit: 'dB',
        badge: r?.gainAction ?? '...',
        valueColor: const Color(0xFF7CC4FF),
      ),

      _MetricItem(
        title: 'True Peak',
        value: r != null ? fmtNum(r.truePeak) : '--',
        unit: 'dBTP',
        badge: r?.peakRisk ?? '...',
        valueColor: const Color(0xFF7CC4FF),
      ),

      _MetricItem(
        title: 'Overall',
        value: r != null ? fmtNum(r.deltaE, frac: 2) : '--',
        unit: 'ΔE',
        badge: 'Balanced',
        valueColor: const Color(0xFF4FAAF7),
      ),
    ];

    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      /// 📱 MOBİL → ALT ALTA
      return Column(
        children: [
          for (final it in items) ...[
            _MetricCard(item: it, enabled: enabled),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    /// 🖥️ DESKTOP → 2–2 + ALTA 1
    /// 🖥️ DESKTOP → 2 × 2 GRID (4 KUTU)
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(item: items[0], enabled: enabled)),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(item: items[1], enabled: enabled)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MetricCard(item: items[2], enabled: enabled)),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(item: items[3], enabled: enabled)),
          ],
        ),
      ],
    );
  }
}

class _MetricItem {
  final String title;
  final String value;
  final String unit;
  final String badge;
  final Color valueColor;
  const _MetricItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.badge,
    required this.valueColor,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricItem item;
  final bool enabled;

  const _MetricCard({required this.item, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final isOverall = item.title == 'Overall';

    return Opacity(
      opacity: enabled ? 1.0 : 0.65,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20), // ⬅️ %15 civarı

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 24, 27, 35).withOpacity(0.55),

          border: Border.all(
            color:
                isOverall
                    ? const Color(0xFF4FAAF7).withOpacity(0.55)
                    : Colors.white.withOpacity(0.10),
            width: isOverall ? 1.4 : 1,
          ),

          boxShadow:
              isOverall
                  ? [
                    BoxShadow(
                      color: const Color(0xFF4FAAF7).withOpacity(0.18),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                  : [],
        ),
        child: _metricRow(context),
      ),
    );
  }

  Widget _metricRow(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 520;
    final isOverall = item.title == 'Overall';
    final c = statusColor(item.badge);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ───────── SOL: BAŞLIK + INFO ─────────
        SizedBox(
          width: isMobile ? null : 140, // webte sabit, mobil serbest
          child: Row(
            mainAxisSize: MainAxisSize.min, // ⬅️ OVERFLOW FIX
            children: [
              Flexible(
                child: Text(
                  isOverall ? 'Energy\nBalance' : item.title,

                  maxLines: isOverall ? 2 : 1, // ⬅️ sadece overall 2 satır
                  overflow: TextOverflow.visible, // ⬅️ sc... yok
                  style: TextStyle(
                    fontSize: isMobile ? 16.5 : 18,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE8F0FF),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  showMetricPopup(context, item.title, item.value, item.badge);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.info_outline,
                    size: isMobile ? 20 : 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ───────── ORTA: DEĞER ─────────
        Expanded(
          flex: 3,
          child: Align(
            alignment: isMobile ? Alignment.center : Alignment.centerLeft,
            child: RichText(
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: item.value,
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w900,
                      color: c,
                    ),
                  ),
                  if (item.unit.isNotEmpty)
                    TextSpan(
                      text: ' ${item.unit}',
                      style: TextStyle(
                        fontSize: isMobile ? 13.5 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBEC8D6),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // ───────── SAĞ: BADGE ─────────
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: _badge(item.badge),
          ),
        ),
      ],
    );
  }

  // =========================
  // 🏷️ BADGE (ORTAK)
  // =========================
  Widget _badge(String text) {
    final c = statusColor(text);

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.45)),
      ),
      child: Center(
        child: Text(
          titleCase(text),
          maxLines: 2, // ⬅️ İKİ SATIR
          softWrap: true,
          overflow: TextOverflow.visible, // ⬅️ ... YOK
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5, // ⬅️ biraz büyüdü
            color: c,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  String titleCase(String value) {
    if (value.isEmpty) return value;

    return value
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

Color statusColor(String badge) {
  final b = badge.toLowerCase();

  // 🟢 İYİ / SORUNSUZ
  if (b.contains('excellent') ||
      b.contains('safe') ||
      b.contains('balanced') ||
      b.contains('ok') ||
      b.contains('none')) {
    return const Color(0xFF3DDC97); // YEŞİL
  }

  // 🔴 SORUNLU / DEĞİŞMELİ
  if (b.contains('too') ||
      b.contains('poor') ||
      b.contains('clipping') ||
      b.contains('reduce') ||
      b.contains('needs') ||
      b.contains('loud')) {
    return const Color(0xFFFF6B6B); // KIRMIZI
  }

  // 🟡 Kararsızsa (çok nadir)
  return const Color(0xFF3DDC97);
}

String getMetricDescription(String title) {
  switch (title) {
    case 'LUFS':
      return 'LUFS stands for Loudness Units relative to Full Scale and measures '
          'the average perceived loudness of a track as heard by the human ear.\n\n'
          'Streaming platforms usually normalize tracks to around –14 LUFS.\n\n'
          '–12 LUFS or higher is considered very loud and will likely be '
          'automatically reduced during playback.\n\n'
          'Lower LUFS values provide a calmer and more natural listening experience.';

    case 'Gain':
      return 'Gain shows how much volume adjustment is recommended for your track '
          'to reach the target loudness level.\n\n'
          'A positive value (+ dB) means the track is below the target level and '
          'can be increased.\n\n'
          'A negative value (– dB) means the track is too loud and should be '
          'reduced for platform compatibility.\n\n'
          'Values close to 0 dB indicate that no adjustment is needed.';

    case 'True Peak':
      return 'True Peak measures the highest signal level that may occur after '
          'digital-to-analog conversion.\n\n'
          'Values above 0 dBTP indicate a risk of distortion on some playback '
          'systems.\n\n'
          '–1 dBTP or lower is considered safe, while around –3 dBTP provides '
          'ample headroom for clean playback.';

    case 'Overall':
      return 'Overall Balance reflects how balanced your track is in terms of '
          'energy, dynamics, and loudness distribution.\n\n'
          'This evaluation is based on the ΔE (Delta-E) value.\n\n'
          'Lower ΔE values indicate a natural and balanced sound, while higher '
          'values may suggest an over-compressed or fatiguing mix.';

    default:
      return '';
  }
}

/// ---------- Buttons ----------
class _PrimaryWideButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryWideButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;
    return SizedBox(
      width: double.infinity,
      height: isWeb ? 46 : 46, // biraz daha büyük
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FAAF7),
          foregroundColor: const Color.fromARGB(255, 8, 12, 20),
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.08);
            }
            if (states.contains(MaterialState.hovered)) {
              return Colors.white.withOpacity(0.08);
            }
            return null;
          }),
        ),

        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SecondaryWideButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SecondaryWideButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;
    return SizedBox(
      width: double.infinity,
      height: isWeb ? 42 : 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),

          // 🎨 Background renkleri (Default / Hover / Pressed)
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xFF16304A); // Pressed
            }
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.focused)) {
              return const Color(0xFF2A4A6A); // Hover / Focus
            }
            return const Color(0xFF1E2F44); // Default
          }),

          // 🎨 Text rengi
          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed)) {
              return const Color(0xFFEAF4FF);
            }
            return const Color(0xFF9FD8FF);
          }),

          // 🎨 Border
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color(0xFF4FAAF7).withOpacity(0.35),
              ),
            ),
          ),

          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // ⏳ Kum saati (korundu)
            Icon(Icons.hourglass_bottom, size: 18, color: Color(0xFF4FAAF7)),
            SizedBox(width: 8),

            // 🧠 Metin
            Text(
              'Fix with AI – Early Access',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedDetailsCard extends StatefulWidget {
  final AnalysisResult result;
  const _AdvancedDetailsCard({required this.result});

  @override
  State<_AdvancedDetailsCard> createState() => _AdvancedDetailsCardState();
}

class _AdvancedDetailsCardState extends State<_AdvancedDetailsCard>
    with SingleTickerProviderStateMixin {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    TextStyle label = const TextStyle(
      color: Color(0xFF9FB4CC),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    TextStyle value = const TextStyle(
      color: Color(0xFFE8F0FF),
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );

    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160, // 🔥 KRİTİK: label sabit genişlik
            child: Text(k, style: label, softWrap: true),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(v, style: value, softWrap: true)),
        ],
      ),
    );
    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF7CC4FF),
        ),
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520), // 🎯 BUTON GENİŞLİĞİ
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 24, 27, 35).withOpacity(0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            children: [
              // ───────── İNCECİK BAR (HER ZAMAN GÖRÜNÜR) ─────────
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _open = !_open),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: _open ? 14 : 10, // 🔥 KAPALIYKEN İNCE
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Advanced details',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7CC4FF),
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.expand_more,
                          size: 20,
                          color: Color(0xFF7CC4FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ───────── AÇILAN İÇERİK ─────────
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child:
                    _open
                        ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionTitle('Overview'),
                              row('Loudness status', loudnessSentence(r)),
                              row('Gain recommendation', gainSentence(r)),
                              row('Peak safety', peakSentence(r)),
                              row('Energy balance (ΔE)', deltaESentence(r)),

                              const Divider(height: 24),

                              sectionTitle('Measured values'),

                              // 2️⃣ Ölçülen değerler
                              row(
                                'Average loudness',
                                '${r.lufs.toStringAsFixed(2)} LUFS',
                              ),
                              row('Target loudness', '${r.targetLufs} LUFS'),
                              row(
                                'Gain required',
                                '${r.gainAdjustment.toStringAsFixed(2)} dB',
                              ),
                              row(
                                'True peak',
                                '${r.truePeak.toStringAsFixed(2)} dBTP',
                              ),

                              const Divider(height: 24),

                              // 3️⃣ Teknik bilgiler
                              row('Sample rate', '${r.sampleRate} Hz'),
                              row('Channels', r.channels.toString()),
                              row('Source format', r.sourceFormat),
                              row('Decoder', r.decoder),

                              const Divider(height: 24),

                              // 4️⃣ Analiz metodları
                              row('LUFS measurement', r.lufsMethod),
                              row('Peak measurement', r.peakMethod),
                              row('Energy method', r.energyMethod),

                              if (r.warnings.isNotEmpty) ...[
                                const Divider(height: 24),
                                row('Warnings', r.warnings.join(', ')),
                              ],
                            ],
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String loudnessSentence(AnalysisResult r) {
  final label = r.loudnessLabel.toLowerCase();

  switch (label) {
    case 'very loud':
      return 'Overall loudness is very loud and will be aggressively normalized on streaming platforms.';

    case 'loud':
      return 'Overall loudness is loud and slightly above typical streaming targets.';

    case 'dynamic':
    case 'balanced':
      return 'Overall loudness is dynamic and suitable for streaming platforms.';

    case 'quiet':
      return 'Overall loudness is relatively quiet and below common streaming targets.';

    default:
      return 'Overall loudness is within an acceptable range for streaming platforms.';
  }
}

String gainSentence(AnalysisResult r) {
  final g = r.gainAdjustment;
  final action = r.gainAction.toLowerCase();

  switch (action) {
    case 'none':
    case 'ok':
      return 'No gain adjustment is required.';

    case 'optional':
      return 'A minor gain adjustment of ${g.abs().toStringAsFixed(2)} dB '
          'may be applied if desired.';

    case 'needs lift':
      return 'A gain increase of ${g.toStringAsFixed(2)} dB is suggested '
          'to meet the target loudness.';

    case 'needs trim':
    case 'reduce':
    case 'needs reduction':
      return 'A gain reduction of ${g.abs().toStringAsFixed(2)} dB is suggested '
          'to meet the target loudness.';

    default:
      // 🔒 Güvenli fallback
      if (g.abs() < 0.3) {
        return 'No gain adjustment is required.';
      }
      if (g > 0) {
        return 'A gain increase of ${g.toStringAsFixed(2)} dB is suggested '
            'to meet the target loudness.';
      }
      return 'A gain reduction of ${g.abs().toStringAsFixed(2)} dB is suggested '
          'to meet the target loudness.';
  }
}

String peakSentence(AnalysisResult r) {
  final risk = r.peakRisk.toLowerCase();

  if (risk.contains('clipping')) {
    return 'Peak levels are at the clipping threshold and may cause distortion on some playback systems.';
  }

  if (risk.contains('near')) {
    return 'Peak levels are close to the limit and should be monitored carefully.';
  }

  return 'Peak levels are safe, with sufficient headroom and no clipping risk.';
}

String deltaESentence(AnalysisResult r) {
  if (r.deltaE < 0.3) {
    return 'Energy balance is very natural with preserved dynamics.';
  }
  if (r.deltaE < 0.6) {
    return 'Energy balance is stable with no aggressive compression.';
  }
  return 'Energy balance shows noticeable deviation and may require further review.';
}
