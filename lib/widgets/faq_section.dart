import 'package:flutter/material.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Why Loudence?',
        'Loudence is more than a loudness meter.\n'
            'It’s an AI-powered loudness analysis platform designed to understand how your audio behaves across major streaming platforms, not just measure raw values.\n\n'
            'Many tracks are turned down or even rejected by distribution platforms due to loudness, peak, or technical compliance issues.\n'
            'Loudence helps you avoid rejections before upload by analyzing all critical loudness metrics together.\n\n'
            'Thanks to its AI-driven interpretation:\n'
            '• You understand why a track might get penalized or rejected\n'
            '• You can confidently prepare your audio for release\n'
            '• If a track is rejected, Loudence helps you identify the exact technical reason\n\n'
            '🚀 Coming next:\n'
            'AI-powered automatic fixes for loudness and compliance issues.\n'
            'Early users will get early access to this feature.',
      ),
      (
        'What is LUFS?',
        'LUFS (Loudness Units relative to Full Scale) is a standard used to measure perceived loudness, not just volume.\n\n'
            'Most streaming platforms normalize audio loudness to provide consistent listening experiences.\n'
            'If a track exceeds recommended LUFS targets, it may be turned down automatically or flagged during distribution.\n\n'
            'Loudence analyzes LUFS in context, helping you understand how your track will behave after normalization, not just before upload.',
      ),
      (
        'Why does my track get quieter or rejected on streaming platforms?',
        'Streaming platforms apply strict loudness and technical standards.\n\n'
            'A track may:\n'
            '• Get quieter due to loudness normalization\n'
            '• Be rejected due to excessive loudness, True Peak issues, or technical inconsistencies\n\n'
            'These adjustments can affect punch, clarity, and overall impact.\n\n'
            'Loudence helps you detect both loudness penalties and rejection risks before upload, so you can fix issues early and release with confidence.',
      ),
      (
        'What is Gain?',
        'Gain refers to the overall level adjustment applied to an audio signal.\n\n'
            'While increasing gain can make a track louder, doing so without considering other metrics may cause distortion, clipping, or platform penalties.\n\n'
            'Loudence evaluates gain in relation to loudness, dynamics, and peak behavior, not as a standalone value.',
      ),
      (
        'What is True Peak?',
        'True Peak measures the actual peak level after digital-to-analog conversion, including inter-sample peaks.\n\n'
            'Even if your waveform appears safe, True Peak levels can exceed limits and cause distortion on playback systems or trigger distribution issues.\n\n'
            'Loudence accurately detects True Peak values to help prevent clipping and rejection risks.',
      ),
      (
        'What is Delta E (Loudness Deviation)?',
        'Delta E represents how far your track deviates from optimal loudness behavior, based on multiple metrics combined.\n\n'
            'Instead of focusing on a single number, Delta E reflects overall loudness balance and technical alignment.\n\n'
            'This makes Loudence’s analysis behavior-aware, not just numeric.',
      ),
      (
        'What metrics does Loudence analyze?',
        'Loudence analyzes a full set of loudness and technical metrics, including:\n'
            '• Integrated LUFS\n'
            '• Short-term & Momentary Loudness\n'
            '• True Peak\n'
            '• Gain behavior\n'
            '• Loudness deviation (Delta E)\n'
            '• Dynamic balance indicators\n\n'
            'All metrics are interpreted together and summarized into a unified evaluation.',
      ),
      (
        'What is the Overall Score?',
        'The Overall Score is Loudence’s AI-driven summary of your track’s loudness behavior.\n\n'
            'It does not judge musical quality.\n'
            'Instead, it indicates how well your track aligns with technical expectations, loudness stability, and platform compliance.\n\n'
            'This score helps creators quickly decide whether a track is technically ready for distribution.',
      ),
      (
        'Is Loudence completely free to use?',
        'Yes. Loudence provides free loudness analysis for supported audio formats, allowing creators to instantly analyze and understand their audio behavior.\n\n'
            'Additional AI-powered features may be introduced in future versions.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;

        final titleText =
            isMobile
                ? 'Frequently Asked Questions\nAbout Loudness & LUFS'
                : 'Frequently Asked Questions About Loudness & LUFS';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 24, 27, 35).withOpacity(0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            children: [
              Text(
                titleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  height: 1.15,
                  color: const Color.fromARGB(255, 232, 240, 255),
                ),
              ),
              const SizedBox(height: 16),

              // Items
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _FaqItem(
                      question: items[i].$1,
                      answer: items[i].$2,
                      isMobile: isMobile,
                    ),
                    if (i != items.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Divider(
                          height: 18,
                          thickness: 1,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isMobile;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.isMobile,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final qStyle = TextStyle(
      fontSize: widget.isMobile ? 16.8 : 16.2,
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(255, 210, 220, 235),
      height: 1.2,
    );

    final aStyle = TextStyle(
      fontSize: widget.isMobile ? 15.6 : 14.8, // readability artışı
      height: 1.55,
      color: const Color.fromARGB(255, 180, 190, 206),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(8),
        splashColor: const Color.fromARGB(255, 79, 170, 247).withOpacity(0.12),
        highlightColor: const Color.fromARGB(
          255,
          79,
          170,
          247,
        ).withOpacity(0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Text(widget.question, style: qStyle)),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _open ? 0.25 : 0.0, // sağ -> aşağı rotasyon hissi
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color:
                          _open
                              ? const Color.fromARGB(255, 210, 220, 235)
                              : const Color.fromARGB(255, 180, 190, 206),
                    ),
                  ),
                ],
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child:
                    _open
                        ? Padding(
                          padding: const EdgeInsets.only(top: 10, right: 6),
                          child: Text(widget.answer, style: aStyle),
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
