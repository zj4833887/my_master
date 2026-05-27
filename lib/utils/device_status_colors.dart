import 'package:flutter/material.dart';

/// 报到设备状态色（「空闲」为浅蓝监控风，其余与历史设定一致）。
abstract final class DeviceStatusColors {
  static Color background(String status) {
    switch (status) {
      case '空闲':
        return const Color(0xFFE3F2FD);
      case '工作':
        return const Color(0xFFFFFFFF);
      case '结束':
        return const Color(0xFFFF6600);
      case '联机':
        return Colors.blue;
      case '脱机':
        return Colors.green;
      case '设备':
        return Colors.purple.withOpacity(0.8);
      case '重报':
        return const Color(0xFF00F7DE);
      case '报到':
        return const Color(0xFFFFFF00);
      case '错卡':
        return const Color(0xFFFFA500);
      default:
        return Colors.black.withOpacity(0.6);
    }
  }

  static Color foreground(String status) {
    switch (status) {
      case '空闲':
        return const Color(0xFF1565C0);
      case '工作':
      case '报到':
      case '重报':
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  /// 机柜/GID 卡片外框底色
  static const Color rackCardSurface = Color(0xFFFAFBFF);

  /// 机柜卡片描边
  static const Color rackCardBorder = Color(0xFFE0E7EF);
}
