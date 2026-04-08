/// Compile-time environment configuration.
///
/// Inject values at build time using --dart-define:
///
///   Debug (local):
///     flutter run --dart-define=SIGNAL_HOST=192.168.1.34:8080 --dart-define=SIGNAL_SECURE=false
///
///   Staging:
///     flutter run --dart-define=SIGNAL_HOST=staging.yourserver.com --dart-define=SIGNAL_SECURE=true
///
///   Production (App Store / Play Store):
///     flutter build apk --dart-define=SIGNAL_HOST=signal.yourapp.com --dart-define=SIGNAL_SECURE=true
///     flutter build ipa --dart-define=SIGNAL_HOST=signal.yourapp.com --dart-define=SIGNAL_SECURE=true
///
/// In VS Code add to .vscode/launch.json:
///   "toolArgs": ["--dart-define=SIGNAL_HOST=signal.yourapp.com", "--dart-define=SIGNAL_SECURE=true"]
///
/// In Android Studio add to Run/Debug Configurations → Additional run args.

class AppConfig {
  AppConfig._();

  // ── Signaling server ─────────────────────────────────────────────
  /// Host without scheme, e.g. "192.168.1.34:8080" or "signal.yourapp.com"
  static const String signalingHost = String.fromEnvironment(
    'SIGNAL_HOST',
    defaultValue: '192.168.1.34:8080', // fallback for plain `flutter run`
  );

  /// true  → uses wss:// (required for App Store / Play Store)
  /// false → uses ws://  (local development only)
  static const bool signalingSecure = bool.fromEnvironment(
    'SIGNAL_SECURE',
    defaultValue: false,
  );

  /// Full WebSocket URL, e.g. wss://signal.yourapp.com
  static String get signalingUrl {
    final scheme = signalingSecure ? 'wss' : 'ws';
    return '$scheme://$signalingHost';
  }

  // ── Environment label (for debug display) ───────────────────────
  static String get env {
    if (signalingSecure && !signalingHost.contains('staging')) return 'production';
    if (signalingHost.contains('staging')) return 'staging';
    return 'development';
  }
}
