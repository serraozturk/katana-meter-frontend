import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DropBoxWeb extends StatelessWidget {
  const DropBoxWeb({
    super.key,
    required this.onFileDropped,
    required this.onHover,
    required this.onLeave,
    required this.onError, // 👈 MUTLAKA VAR
  });

  final ValueChanged<PlatformFile> onFileDropped;
  final VoidCallback onHover;
  final VoidCallback onLeave;
  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) {
    // Mobil / native app → DROP YOK
    return const SizedBox.shrink();
  }
}
