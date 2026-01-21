import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:file_picker/file_picker.dart';

import 'upload_config.dart';

class DropBoxWeb extends StatelessWidget {
  const DropBoxWeb({
    super.key,
    required this.onFileDropped,
    required this.onHover,
    required this.onLeave,
    required this.onError, // 👈 YENİ
  });

  final ValueChanged<PlatformFile> onFileDropped;
  final VoidCallback onHover;
  final VoidCallback onLeave;
  final ValueChanged<String> onError; // 👈 YENİ

  @override
  Widget build(BuildContext context) {
    DropzoneViewController? controller;

    return DropzoneView(
      onCreated: (c) => controller = c,
      onHover: onHover,
      onLeave: onLeave,

      onDropFile: (file) async {
        if (controller == null) {
          onError('Dropzone not ready');
          return;
        }

        try {
          final name = await controller!.getFilename(file);
          final parts = name.split('.');
          if (parts.length < 2) {
            onError('File extension not found');
            return;
          }
          final ext = parts.last.toLowerCase();

          if (!allowedExtensions.contains(ext)) {
            onError('Unsupported file type');
            return;
          }

          final bytes = await controller!.getFileData(file);

          if (bytes.length > maxFileSizeBytes) {
            onError('File is too large');
            return;
          }

          onFileDropped(
            PlatformFile(name: name, size: bytes.length, bytes: bytes),
          );
        } catch (e) {
          onError('File could not be processed');
        }
      },
    );
  }
}
