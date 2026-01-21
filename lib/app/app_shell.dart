import 'package:flutter/material.dart';
import 'theme.dart';
import 'analysis_controller.dart';
import '../pages/upload_pages.dart';

class KatanaApp extends StatefulWidget {
  const KatanaApp({super.key});

  @override
  State<KatanaApp> createState() => _KatanaAppState();
}

class _KatanaAppState extends State<KatanaApp> {
  late final AnalysisController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnalysisController(); // ✅ SADECE 1 KERE
  }

  @override
  void dispose() {
    _controller.dispose(); // varsa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnalysisScope(
      controller: _controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: loudenceTheme(),
        home: const UploadPage(),
      ),
    );
  }
}
