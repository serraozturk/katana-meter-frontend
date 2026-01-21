import 'dart:ui';
import 'package:flutter/material.dart';

import '../widgets/katana_background.dart';

class DownloadAppPage extends StatelessWidget {
  const DownloadAppPage({super.key});

  // 🎨 RENKLER (Katana UI ile uyumlu)
  static const Color cardDark = Color(0xFF121824);
  static const Color brandBlue = Color(0xFF4FAAF7);
  static const Color textPrimary = Color(0xFFE8F0FF);
  static const Color textSecondary = Color(0xFF9FB4CC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: textPrimary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Download Loudence',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),

      body: KatanaBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
              child: ScrollConfiguration(
                behavior: const _NoGlowScrollBehavior(),
                child: ListView(
                  children: [
                    // ───────── HERO ─────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Install the app on your device',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose your platform below.',
                            style: TextStyle(
                              fontSize: 15.5,
                              height: 1.35,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ───────── PLATFORM GRID ─────────
                    LayoutBuilder(
                      builder: (context, c) {
                        final isNarrow = c.maxWidth < 860;
                        final w = isNarrow ? c.maxWidth : (c.maxWidth - 14) / 2;

                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            _PlatformCard(
                              width: w,
                              title: 'Windows',
                              subtitle: 'Desktop installer (.exe)',
                              icon: Icons.desktop_windows_rounded,
                              primaryLabel: 'Download for Windows',
                              primaryOnTap: null,
                            ),
                            _PlatformCard(
                              width: w,
                              title: 'macOS',
                              subtitle: 'Universal / Apple Silicon (.dmg)',
                              icon: Icons.laptop_mac_rounded,
                              primaryLabel: 'Download for macOS',
                              primaryOnTap: null,
                            ),
                            _PlatformCard(
                              width: w,
                              title: 'iOS',
                              subtitle: 'App Store',
                              icon: Icons.phone_iphone_rounded,
                              primaryLabel: 'Open App Store',
                              primaryOnTap: null,
                            ),
                            _PlatformCard(
                              width: w,
                              title: 'Android',
                              subtitle: 'Google Play',
                              icon: Icons.android_rounded,
                              primaryLabel: 'Open Google Play',
                              primaryOnTap: null,
                            ),

                            // PWA
                            _PlatformCard(
                              width: c.maxWidth,
                              title: 'Web (PWA)',
                              subtitle:
                                  'Install Loudence as an app from your browser',
                              icon: Icons.language_rounded,
                              primaryLabel: 'How to install',
                              primaryOnTap: () => _showPwaHelp(context),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // ───────── FOOTER NOTE ─────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: brandBlue,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tip: Replace disabled buttons with real store links when ready.',
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.35,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _showPwaHelp(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: cardDark,
            title: const Text(
              'Install as PWA',
              style: TextStyle(color: textPrimary),
            ),
            content: const Text(
              'Chrome / Edge: Click the install icon in the address bar.\n'
              'iOS Safari: Share → Add to Home Screen.\n'
              'Android Chrome: Menu → Install app.',
              style: TextStyle(color: textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: brandBlue)),
              ),
            ],
          ),
    );
  }
}

// ───────────────────────── PLATFORM CARD ─────────────────────────

class _PlatformCard extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryLabel;
  final VoidCallback? primaryOnTap;

  const _PlatformCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryLabel,
    required this.primaryOnTap,
  });

  static const Color cardDark = Color(0xFF121824);
  static const Color brandBlue = Color(0xFF4FAAF7);
  static const Color textPrimary = Color(0xFFE8F0FF);
  static const Color textSecondary = Color(0xFF9FB4CC);

  @override
  Widget build(BuildContext context) {
    final enabled = primaryOnTap != null;

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: brandBlue, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13.5, color: textSecondary),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: primaryOnTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      enabled ? brandBlue : const Color(0xFF1A2436),
                  foregroundColor:
                      enabled ? Colors.white : const Color(0xFF6F86A6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  primaryLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── OVERSCROLL FIX ─────────────────────────

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
