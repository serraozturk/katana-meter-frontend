import 'dart:async';
import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// CONFIG
/// ------------------------------------------------------------

const bool kDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

const int kMaxFileBytes = 50 * 1024 * 1024; // 50MB hard limit

/// ------------------------------------------------------------
/// ENUMS
/// ------------------------------------------------------------

enum AnalysisPhase { idle, uploading, processing, done, error }

enum AnalysisError {
  network,
  fileTooLarge,
  unsupportedFormat,
  cancelled,
  invalidState,
  unknown,
}

/// ------------------------------------------------------------
/// ERROR MAPPING (STORE SAFE)
/// ------------------------------------------------------------

String analysisErrorTitle(AnalysisError e) {
  switch (e) {
    case AnalysisError.network:
      return 'Network error';
    case AnalysisError.fileTooLarge:
      return 'File too large';
    case AnalysisError.unsupportedFormat:
      return 'Unsupported format';
    case AnalysisError.cancelled:
      return 'Analysis cancelled';
    case AnalysisError.invalidState:
      return 'Invalid state';
    case AnalysisError.unknown:
      return 'Something went wrong';
  }
}

String analysisErrorMessage(AnalysisError e) {
  switch (e) {
    case AnalysisError.network:
      return 'Please check your internet connection and try again.';
    case AnalysisError.fileTooLarge:
      return 'The selected file exceeds the maximum allowed size.';
    case AnalysisError.unsupportedFormat:
      return 'This audio format is not supported.';
    case AnalysisError.cancelled:
      return 'You cancelled the analysis.';
    case AnalysisError.invalidState:
      return 'The analysis could not continue.';
    case AnalysisError.unknown:
      return 'Unexpected error occurred. Please try again.';
  }
}

/// ------------------------------------------------------------
/// RESULT MODEL
/// ------------------------------------------------------------

class AnalysisResult {
  final double lufs;
  final double truePeak;
  final double gainAdjustment;
  final double deltaE;

  final String loudnessLabel;
  final String gainAction;
  final String peakRisk;

  final double targetLufs;

  final int sampleRate;
  final int channels;
  final String sourceFormat;
  final String decoder;

  final String lufsMethod;
  final String peakMethod;
  final String energyMethod;

  final List<String> warnings;

  const AnalysisResult({
    required this.lufs,
    required this.truePeak,
    required this.gainAdjustment,
    required this.deltaE,
    required this.loudnessLabel,
    required this.gainAction,
    required this.peakRisk,
    required this.targetLufs,
    required this.sampleRate,
    required this.channels,
    required this.sourceFormat,
    required this.decoder,
    required this.lufsMethod,
    required this.peakMethod,
    required this.energyMethod,
    required this.warnings,
  });
}

/// ------------------------------------------------------------
/// STATE (IMMUTABLE)
/// ------------------------------------------------------------

class AnalysisState {
  final AnalysisPhase phase;
  final double? progress;
  final String? message;
  final AnalysisResult? result;
  final AnalysisError? errorType;
  final bool isDemo;

  const AnalysisState({
    required this.phase,
    this.progress,
    this.message,
    this.result,
    this.errorType,
    required this.isDemo,
  });

  const AnalysisState.idle()
    : phase = AnalysisPhase.idle,
      progress = null,
      message = null,
      result = null,
      errorType = null,
      isDemo = kDemoMode;
}

/// ------------------------------------------------------------
/// CONTROLLER (PUBLISH-GRADE)
/// ------------------------------------------------------------

class AnalysisController extends ValueNotifier<AnalysisState>
    with WidgetsBindingObserver {
  AnalysisController() : super(const AnalysisState.idle()) {
    WidgetsBinding.instance.addObserver(this);
  }

  Timer? _fakeTimer;
  bool _cancelRequested = false;

  bool get isBusy =>
      value.phase == AnalysisPhase.uploading ||
      value.phase == AnalysisPhase.processing;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && isBusy) {
      cancel();
    }
  }

  void reset() {
    _stopFake();
    _cancelRequested = false;
    value = const AnalysisState.idle();
  }

  void cancel() {
    if (!isBusy) return;

    _cancelRequested = true;
    _stopFake();

    value = AnalysisState(
      phase: AnalysisPhase.error,
      progress: null,
      message: analysisErrorMessage(AnalysisError.cancelled),
      result: null,
      errorType: AnalysisError.cancelled,
      isDemo: value.isDemo,
    );
  }

  void startUpload({double? progress, String? message}) {
    if (!_canTransitionTo(AnalysisPhase.uploading)) {
      _failInvalidState();
      return;
    }

    value = AnalysisState(
      phase: AnalysisPhase.uploading,
      progress: (progress ?? 0.05).clamp(0.0, 1.0),
      message: message ?? 'Uploading…',
      result: null,
      errorType: null,
      isDemo: value.isDemo,
    );

    if (progress == null) {
      _startFakeProgress();
    }
  }

  void startProcessing({String? message}) {
    if (!_canTransitionTo(AnalysisPhase.processing)) {
      _failInvalidState();
      return;
    }

    value = AnalysisState(
      phase: AnalysisPhase.processing,
      progress: (value.progress ?? 0.1).clamp(0.0, 0.9),
      message: message ?? 'Analyzing audio…',
      result: null,
      errorType: null,
      isDemo: value.isDemo,
    );

    _startFakeProgress();
  }

  Future<void> finish(AnalysisResult result) async {
    if (!_canTransitionTo(AnalysisPhase.done)) {
      _failInvalidState();
      return;
    }

    _stopFake();

    value = AnalysisState(
      phase: AnalysisPhase.done,
      progress: 1.0,
      message: 'Analysis complete',
      result: result,
      errorType: null,
      isDemo: value.isDemo,
    );
  }

  void fail(AnalysisError type) {
    _stopFake();

    value = AnalysisState(
      phase: AnalysisPhase.error,
      progress: null,
      message: analysisErrorMessage(type),
      result: null,
      errorType: type,
      isDemo: value.isDemo,
    );
  }

  // -----------------------------
  // 🔧 SADECE BURASI DÜZELTİLDİ
  // -----------------------------
  void _startFakeProgress() {
    _stopFake();

    _fakeTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (_cancelRequested ||
          (value.phase != AnalysisPhase.uploading &&
              value.phase != AnalysisPhase.processing)) {
        _stopFake();
        return;
      }

      final current = value.progress ?? 0.05;
      if (current >= 0.95) return;

      final next = current + (0.95 - current) * 0.05;

      // 🚨 KRİTİK: aynı progress tekrar set edilmez
      if ((next - current).abs() < 0.002) return;

      value = AnalysisState(
        phase: value.phase,
        progress: next.clamp(0.0, 0.95),
        message: value.message,
        result: null,
        errorType: null,
        isDemo: value.isDemo,
      );
    });
  }

  void _stopFake() {
    _fakeTimer?.cancel();
    _fakeTimer = null;
  }

  bool _canTransitionTo(AnalysisPhase next) {
    switch (value.phase) {
      case AnalysisPhase.idle:
        return next == AnalysisPhase.uploading;
      case AnalysisPhase.uploading:
        return next == AnalysisPhase.processing || next == AnalysisPhase.error;
      case AnalysisPhase.processing:
        return next == AnalysisPhase.done || next == AnalysisPhase.error;
      case AnalysisPhase.done:
      case AnalysisPhase.error:
        return next == AnalysisPhase.idle;
    }
  }

  void _failInvalidState() {
    fail(AnalysisError.invalidState);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopFake();
    super.dispose();
  }
}

/// ------------------------------------------------------------
/// INHERITED SCOPE
/// ------------------------------------------------------------

class AnalysisScope extends InheritedNotifier<AnalysisController> {
  const AnalysisScope({
    super.key,
    required AnalysisController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static AnalysisController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AnalysisScope>();
    assert(scope != null, 'AnalysisScope not found');
    return scope!.notifier!;
  }
}
