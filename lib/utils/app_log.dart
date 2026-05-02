import 'dart:developer' as developer;

/// Centralized logging switch.
///
/// - Default: off (quiet in production).
/// - Enable temporarily by setting [enabled] to true.
class AppLog {
  static bool enabled = false;

  static void d(String message, {String tag = 'APP'}) {
    if (!enabled) return;
    // 统一走 developer.log，避免 debug 下 print 刷屏 flutter run 控制台
    developer.log(message, name: tag);
  }
}

