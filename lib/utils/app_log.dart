import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Centralized logging switch.
///
/// - Default: off (quiet in production).
/// - Enable temporarily by setting [enabled] to true.
class AppLog {
  static bool enabled = false;

  static void d(String message, {String tag = 'APP'}) {
    if (!enabled) return;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$tag] $message');
    } else {
      developer.log(message, name: tag);
    }
  }
}

