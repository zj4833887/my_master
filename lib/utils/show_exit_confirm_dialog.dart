import 'dart:async';

import 'package:flutter/material.dart';

class _ExitConfirmDialogState {
  static Completer<bool>? pending;
}

Future<bool> showExitConfirmDialog(BuildContext context) async {
  // 多次点击时复用同一个弹框的 Future，避免产生多个对话框。
  if (_ExitConfirmDialogState.pending != null) {
    return _ExitConfirmDialogState.pending!.future;
  }

  final completer = Completer<bool>();
  _ExitConfirmDialogState.pending = completer;

  try {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('确认退出'),
          content: const Text('退出后程序将立即结束，是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    completer.complete(result == true);
    return result == true;
  } catch (_) {
    completer.complete(false);
    return false;
  } finally {
    _ExitConfirmDialogState.pending = null;
  }
}
