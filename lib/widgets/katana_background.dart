import 'dart:ui';

import 'package:flutter/material.dart';

class KatanaBackground extends StatelessWidget {
  final Widget child;

  const KatanaBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // 1️⃣ SABİT GRADIENT (DEĞİŞMEZ)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 37, 41, 52),
                  Color.fromARGB(255, 19, 22, 29),
                ],
              ),
            ),
          ),

          // 2️⃣ RADIAL OVERLAY (STATİK, BLUR YOK)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.45),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3️⃣ CONTENT
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
