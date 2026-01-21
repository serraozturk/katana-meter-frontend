import 'package:flutter/material.dart';
import '../pages/download_app_page.dart';

class LoudenceHeaderBar extends StatelessWidget {
  final VoidCallback? onBack;
  final bool showSlogan;
  final String slogan;
  final VoidCallback? onDownloadApp;

  const LoudenceHeaderBar({
    super.key,
    this.onBack,
    this.showSlogan = true,
    this.slogan = 'We measure loudness and understand your music.',
    this.onDownloadApp,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;
        final isTightDesktop = !isMobile && c.maxWidth < 980;

        if (isMobile) {
          return _MobileHeader(
            slogan: slogan,
            showSlogan: showSlogan,
            onBack: onBack, // 🔥 BU SATIR EKSİKTİ
          );
        }

        return _DesktopHeader(
          slogan: slogan,
          showSlogan: showSlogan,
          isTightDesktop: isTightDesktop,
          onBack: onBack,
          onDownloadApp: onDownloadApp,
        );
      },
    );
  }
}

//
// ───────────────────────── MOBILE HEADER ─────────────────────────
//

class _MobileHeader extends StatelessWidget {
  final String slogan;
  final bool showSlogan;
  final VoidCallback? onBack;

  const _MobileHeader({
    required this.slogan,
    required this.showSlogan,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: EdgeInsets.only(
        top: topInset + 20, // ← header aşağı insin
        left: 16,
        right: 16,
        bottom: 10,
      ),
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (onBack != null) ...[
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color.fromARGB(255, 210, 220, 235),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Image.asset(
                'assets/images/loudence_header.png',
                height: 34,
                fit: BoxFit.contain,
              ),
            ],
          ),
          if (showSlogan) ...[
            const SizedBox(height: 10),
            Text(
              slogan,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.0,
                height: 1.15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: const Color(0xFFE8F0FF).withOpacity(0.96),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

//
// ───────────────────────── DESKTOP HEADER ─────────────────────────
//

class _DesktopHeader extends StatelessWidget {
  final String slogan;
  final bool showSlogan;
  final bool isTightDesktop;
  final VoidCallback? onBack;
  final VoidCallback? onDownloadApp;

  const _DesktopHeader({
    required this.slogan,
    required this.showSlogan,
    required this.isTightDesktop,
    this.onBack,
    this.onDownloadApp,
  });

  @override
  Widget build(BuildContext context) {
    final sloganStyle = TextStyle(
      fontSize: isTightDesktop ? 20.0 : 21.5,
      // ⬅️ biraz daha dengeli
      height: 1.15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: const Color(0xFFE8F0FF).withOpacity(0.96),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 8, // ⬅️ 10 → 8 (header sıkılaştı)
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onBack != null) ...[
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color.fromARGB(255, 210, 220, 235),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Image.asset(
                    'assets/images/loudence_header.png',
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              if (showSlogan)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                  ), // ⬅️ slogan aşağı indi
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      slogan,
                      maxLines: isTightDesktop ? 2 : 1,
                      overflow: TextOverflow.fade,
                      style: sloganStyle,
                    ),
                  ),
                ),

              _DownloadAppButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DownloadAppPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ───────────────────────── DOWNLOAD BUTTON ─────────────────────────
//

class _DownloadAppButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _DownloadAppButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed, // 👈 başka sayfa BURADAN açılacak
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4FAAF7).withOpacity(0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.download_rounded, size: 18, color: Color(0xFF9FD8FF)),
            SizedBox(width: 10),
            Text(
              'Download our app',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: Color(0xFFE8F0FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// İstersen her sayfada aynı ince “soft” çizgi için:
class SoftDivider extends StatelessWidget {
  const SoftDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.10),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
