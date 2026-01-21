import 'package:flutter/material.dart';
import '../app/analysis_controller.dart';

class GlobalStatusBar extends StatelessWidget {
  final AnalysisState state;
  const GlobalStatusBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Done state'te görünmez
    if (state.phase == AnalysisPhase.done) {
      return const SizedBox.shrink();
    }

    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      return const SizedBox.shrink();
    }

    final controller = AnalysisScope.of(context);

    final isBusy =
        state.phase == AnalysisPhase.uploading ||
        state.phase == AnalysisPhase.processing;

    final isError = state.phase == AnalysisPhase.error;
    final p = (state.progress ?? 0.0).clamp(0.0, 1.0);
    final percent = (p * 100).round().clamp(0, 99);

    final bg = isError ? const Color(0xFF682222) : const Color(0xFF1A1F29);

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(color: bg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 ÜST SATIR: MESAJ + CANCEL
            Row(
              children: [
                Expanded(
                  child: Text(
                    isError
                        ? (state.message ?? 'Error')
                        : '${state.message ?? ''}  $percent%',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.1,
                      color: Color(0xFFC9D1D9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // ❌ CANCEL (SADECE BUSY)
                if (isBusy)
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 18,
                    splashRadius: 16,
                    color: const Color(0xFFC9D1D9),
                    tooltip: 'Cancel',
                    onPressed: () {
                      controller.cancel();
                    },
                  ),

                // 🔁 ERROR RESET
                if (isError)
                  TextButton(
                    onPressed: () {
                      controller.reset();
                    },
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(color: Color(0xFF5AAAFF), fontSize: 12),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 PROGRESS BAR
            if (isBusy)
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: p,
                  minHeight: 3.5,
                  backgroundColor: const Color(0xFF111522),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF5AAAFF),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
