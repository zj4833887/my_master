import 'dart:async';
import 'dart:io';

import 'app_log.dart';

class LocalExitApi {
  LocalExitApi._();

  static const _url = 'http://localhost:8083/client/exit';
  static bool _called = false;

  /// 应用退出时通知后端释放资源。
  ///
  /// 说明：
  /// - 这里使用短超时，且异常会被吞掉，避免影响用户关闭程序的体验。
  static Future<void> callExit({Duration timeout = const Duration(seconds: 2)}) async {
    if (_called) {
      AppLog.d('already called, skip.', tag: 'LocalExitApi');
      return;
    }
    _called = true;

    try {
      final uri = Uri.parse(_url);
      AppLog.d('calling $_url (POST)', tag: 'LocalExitApi');

      final client = HttpClient();
      try {
        final request = await client.postUrl(uri);
        // 后端如果要求 JSON/body，可以在这里补充；当前退出只需要通知。
        final response = await request.close().timeout(timeout);
        AppLog.d('response status=${response.statusCode}', tag: 'LocalExitApi');
        await response.drain().timeout(timeout);
      } finally {
        client.close(force: true);
      }
    } catch (_) {
      // 忽略所有异常：退出动作优先级更高。
      AppLog.d('call failed.', tag: 'LocalExitApi');
    }
  }

  /// 如果你需要重新触发（例如重新登录后再退出），可以调用该方法。
  static void reset() {
    _called = false;
  }
}

