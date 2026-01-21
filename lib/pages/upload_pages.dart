import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/analysis_controller.dart';
import '../widgets/katana_background.dart';
import '../widgets/status_bar.dart';
import '../widgets/primary_button.dart';
import 'results_page.dart';
import '../widgets/faq_section.dart';
import '../widgets/loudence_header_bar.dart';
import 'dropbox_stub.dart' if (dart.library.html) 'dropbox_web.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app/api_config.dart';
import 'dart:async';

class UploadPage extends StatefulWidget {
  final VoidCallback? onReset;

  const UploadPage({super.key, this.onReset});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

String deltaEBadge(double v) {
  if (v < 1.0) return 'Excellent';
  if (v < 2.5) return 'Slight Deviation';
  if (v < 4.0) return 'Noticeable';
  return 'Poor Balance';
}

class _UploadPageState extends State<UploadPage> {
  PlatformFile? _file;
  String? _error;

  Future<void> _pickFile() async {
    setState(() => _error = null);

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp3', 'wav', 'aiff', 'aif'],
        withData: kIsWeb, // webde bytes lazım
      );

      if (res == null || res.files.isEmpty) return;

      final picked = res.files.first;

      // 🔒 BOYUT KONTROLÜ (STORE SAFE)
      if (picked.size > kMaxFileBytes) {
        setState(() {
          _error = 'File is too large. Maximum size is 50MB.';
          _file = null;
        });
        return;
      }

      setState(() {
        _file = picked;
      });
    } catch (e) {
      setState(() {
        _error = 'File picker error.';
      });
    }
  }

  Future<void> _analyze() async {
    final controller = AnalysisScope.of(context);

    if (_file == null || controller.isBusy) return;

    // ---- FILE GUARDS (WEB + MOBILE SAFE)
    if (kIsWeb && _file!.bytes == null) {
      controller.fail(AnalysisError.invalidState);
      return;
    }

    if (!kIsWeb && _file!.path == null) {
      controller.fail(AnalysisError.invalidState);
      return;
    }

    try {
      // 1️⃣ UPLOADING
      controller.startUpload(message: 'Uploading…');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/analyze/upload'),
      );

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _file!.bytes!,
            filename: _file!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _file!.path!,
            filename: _file!.name,
          ),
        );
      }

      final streamed = await request.send();

      controller.startProcessing(message: 'Analyzing audio…');

      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        controller.fail(AnalysisError.network);
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final result = AnalysisResult(
        lufs: (data['lufs'] as num).toDouble(),
        truePeak: (data['peak_dbtp_approx'] as num).toDouble(),
        gainAdjustment: (data['gain_to_target_db'] as num).toDouble(),
        deltaE: (data['delta_e'] as num).toDouble(),

        loudnessLabel: data['labels']['loudness'],
        gainAction: data['labels']['gain_action'],
        peakRisk: data['labels']['peak_risk'],

        targetLufs: (data['target_lufs'] as num).toDouble(),

        sampleRate: data['info']['sr'],
        channels: data['info']['channels'],
        sourceFormat: data['info']['src_format'],
        decoder: data['info']['decoder'],

        lufsMethod: data['info']['lufs_kind'],
        peakMethod: data['info']['peak_kind'],
        energyMethod: data['info']['delta_e_kind'],

        warnings: List<String>.from(data['warnings']),
      );

      // 4️⃣ DONE
      await controller.finish(result);

      if (!mounted) return;

      final navResult = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ResultsPage()));

      if (navResult == 'reset') {
        clearSelectedFile();
        controller.reset();
      }
    } on TimeoutException {
      controller.fail(AnalysisError.network);
    } catch (e) {
      controller.fail(AnalysisError.unknown);
      if (kDebugMode) debugPrint('ANALYZE ERROR: $e');
    }
  }

  void _openTerms() {
    showDialog(
      context: context,
      builder:
          (_) => const _SimpleModal(
            title: 'Terms',
            body:
                'Terms content will be provided.\n\nFor now this is a placeholder modal.',
          ),
    );
  }

  void clearSelectedFile() {
    setState(() {
      _file = null;
      _error = null;
    });
  }

  void _openPrivacy() {
    showDialog(
      context: context,
      builder:
          (_) => const _SimpleModal(
            title: 'Privacy Policy',
            body:
                'Privacy Policy content will be provided.\n\nFor now this is a placeholder modal.',
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AnalysisScope.of(context);

    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    final isTablet = w >= 600 && w < 900;

    final isBusy = controller.isBusy;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 1) BACKGROUND + SAYFA (AYNI KALDI)
          KatanaBackground(
            child: Stack(
              children: [
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
                          const _StatusSpacer(),

                          const LoudenceHeaderBar(),
                          const SizedBox(height: 18),
                          const SoftDivider(),

                          SizedBox(height: isMobile ? 18 : 26),

                          Text(
                            isMobile
                                ? 'Free LUFS Meter & AI\nMusic Loudness Analyzer'
                                : 'Free LUFS Meter & AI Music Loudness Analyzer',
                            textAlign: TextAlign.center,
                            maxLines: isMobile ? 2 : 1,
                            overflow: TextOverflow.visible,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontSize: isMobile ? 24 : (isTablet ? 32 : 34),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              height: isMobile ? 1.18 : 1.08,
                              color: const Color.fromARGB(255, 90, 170, 255),
                            ),
                          ),

                          const SizedBox(height: 36),

                          Center(
                            child: SizedBox(
                              width: 640,
                              height: isMobile ? 240 : 212, // 🔥 KRİTİK
                              child: _DropBox(
                                fileName: _file?.name,
                                onBrowse: _pickFile,
                                onFileDropped: (file) {
                                  if (file.size > kMaxFileBytes) {
                                    setState(() {
                                      _error =
                                          'File is too large. Maximum size is 50MB.';
                                      _file = null;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    _file = file;
                                    _error = null;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: PrimaryButton(
                                text: 'Analyze Loudness',
                                onPressed:
                                    (isBusy || _file == null) ? null : _analyze,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Supports MP3, WAV, and AIFF formats.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 16.5 : 17.0,
                              color: const Color.fromARGB(255, 165, 172, 186),
                              height: 1.35,
                            ),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 150, 150),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 11),
                          Text(
                            'Instant AI-powered loudness analysis. No signup required.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 16.5 : 17.5,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: const Color.fromARGB(255, 190, 205, 225),
                            ),
                          ),

                          const SizedBox(height: 18),
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

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FooterLink(text: 'Terms', onTap: _openTerms),
                              const SizedBox(width: 10),
                              const Text(
                                '|',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 120, 128, 144),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _FooterLink(
                                text: 'Privacy Policy',
                                onTap: _openPrivacy,
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
          ValueListenableBuilder<AnalysisState>(
            valueListenable: controller,
            builder: (_, state, __) {
              if (state.phase == AnalysisPhase.idle ||
                  state.phase == AnalysisPhase.done) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GlobalStatusBar(state: state),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------- UI pieces ----------------

class _DropBox extends StatefulWidget {
  final String? fileName;
  final VoidCallback onBrowse;
  final ValueChanged<PlatformFile> onFileDropped;

  const _DropBox({
    required this.fileName,
    required this.onBrowse,
    required this.onFileDropped,
  });

  @override
  State<_DropBox> createState() => _DropBoxState();
}

class _DropBoxState extends State<_DropBox> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final enableDropzone = kIsWeb && !isMobile;

    return DottedBorder(
      dashPattern: const [8, 6],
      color: Colors.white.withOpacity(0.14),
      strokeWidth: 1,
      radius: const Radius.circular(10),
      borderType: BorderType.RRect,
      child: SizedBox(
        height: double.infinity, // 🔒 SABİT YÜKSEKLİK (ZORUNLU)
        width: double.infinity,
        child: Stack(
          children: [
            /// 🌐 DROPZONE — SADECE WEB DESKTOP
            if (enableDropzone)
              Positioned.fill(
                child: DropBoxWeb(
                  onHover: () => setState(() => _isDragging = true),
                  onLeave: () => setState(() => _isDragging = false),
                  onFileDropped: (file) {
                    widget.onFileDropped(file);
                    setState(() => _isDragging = false);
                  },
                  onError: (msg) {
                    setState(() => _isDragging = false);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                ),
              ),

            /// 🎨 UI OVERLAY (HER PLATFORMDA)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color:
                    _isDragging
                        ? const Color.fromARGB(
                          255,
                          25,
                          40,
                          60,
                        ).withOpacity(0.65)
                        : const Color.fromARGB(
                          255,
                          18,
                          21,
                          28,
                        ).withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    widget.fileName == null
                        ? _EmptyState(
                          onBrowse: widget.onBrowse,
                          isMobile: isMobile,
                        )
                        : _SelectedState(
                          fileName: widget.fileName!,
                          onBrowse: widget.onBrowse,
                          isMobile: isMobile,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBrowse;
  final bool isMobile;

  const _EmptyState({required this.onBrowse, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final base = isMobile ? 22.0 : 21.0; // web & mobil dengeli

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(
            'Drop your audio file',
            style: TextStyle(
              fontSize: base + 2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: const Color.fromARGB(255, 232, 240, 255),
            ),
          ),
          Text(
            'or',
            style: TextStyle(
              fontSize: base,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 170, 178, 192),
            ),
          ),
          InkWell(
            onTap: onBrowse,
            borderRadius: BorderRadius.circular(6),
            child: Text(
              'Browse file',
              style: TextStyle(
                fontSize: base + 2,
                fontWeight: FontWeight.w800,
                color: const Color.fromARGB(255, 90, 170, 255),
                decoration: TextDecoration.underline,
                decorationColor: const Color.fromARGB(255, 90, 170, 255),
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedState extends StatelessWidget {
  final String fileName;
  final VoidCallback onBrowse;
  final bool isMobile;

  const _SelectedState({
    required this.fileName,
    required this.onBrowse,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = isMobile ? 19.5 : 20.0;
    final fileSize = isMobile ? 18.0 : 17.5;
    final linkSize = isMobile ? 18.5 : 18.5;

    return Column(
      key: const ValueKey('selected'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: LayoutBuilder(
            builder: (context, c) {
              // Dosya adının max genişliği: kutunun %60’ı gibi düşün.

              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected file: ',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 232, 240, 255),
                      ),
                    ),

                    Flexible(
                      child: Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: fileSize,
                          color: const Color.fromARGB(255, 180, 190, 206),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        InkWell(
          onTap: onBrowse,
          child: Text(
            'Browse another file',
            style: TextStyle(
              fontSize: linkSize,
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 90, 170, 255),
              decoration: TextDecoration.underline,
              decorationThickness: 2,
              decorationColor: const Color.fromARGB(255, 90, 170, 255),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

class _SimpleModal extends StatelessWidget {
  final String title;
  final String body;

  const _SimpleModal({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 18, 21, 28),
      title: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 220, 230, 245)),
      ),
      content: Text(
        body,
        style: const TextStyle(color: Color.fromARGB(255, 180, 190, 206)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.maybePop(context);
          },

          child: const Text('Close'),
        ),
      ],
    );
  }
}

Map<String, dynamic> parseAnalysis(String body) {
  return jsonDecode(body) as Map<String, dynamic>;
}

class _StatusSpacer extends StatelessWidget {
  const _StatusSpacer();

  @override
  Widget build(BuildContext context) {
    final controller = AnalysisScope.of(context);

    return ValueListenableBuilder<AnalysisState>(
      valueListenable: controller,
      builder: (_, state, __) {
        if (state.phase == AnalysisPhase.idle ||
            state.phase == AnalysisPhase.done) {
          return const SizedBox.shrink();
        }

        return const SizedBox(height: 62);
      },
    );
  }
}
