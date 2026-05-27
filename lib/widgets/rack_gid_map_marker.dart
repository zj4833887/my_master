import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/device_status_colors.dart';

/// 设备点位图上的 GID 机柜标记（与报到设备 device22 叠层一致，按比例缩小）。
class RackGidMapMarker extends StatelessWidget {
  const RackGidMapMarker({
    super.key,
    required this.width,
    required this.screenStatus,
    this.masterStatus,
    this.backupStatus,
    this.showMaster = true,
    this.showBackup = true,
  });

  final double width;
  final String screenStatus;
  final String? masterStatus;
  final String? backupStatus;
  final bool showMaster;
  final bool showBackup;

  static const String asset = 'assets/images/device22.png';
  static const double imageAspect = 1044 / 1490;

  static const double _screenLeft = 280 / 1044;
  static const double _screenTop = 100 / 1490;
  static const Alignment _screenPanelAlign = Alignment(-0.14, -0.22);
  static const double _screenRight = (1044 - 854) / 1044;
  static const double _screenBottom = (1490 - 1034) / 1490;
  static const double _panelWidthFrac = 0.5;
  static const double _panelHeightFrac = 0.88;
  static const double _charGapFrac = 0.48;
  static const double _ipcMasterX = 395 / 1044;
  static const double _ipcBackupX = 696 / 1044;
  static const double _ipcStatusTop = 1050 / 1490;
  static const double _ipcBarWidthFrac = 48 / 1044;
  static const double _ipcBarHeightFrac = 14 / 1490;

  @override
  Widget build(BuildContext context) {
    final h = width / imageAspect;
    return SizedBox(
      width: width,
      height: h,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Image.asset(
            asset,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
          Positioned(
            left: width * _screenLeft,
            top: h * _screenTop,
            right: width * _screenRight,
            bottom: h * _screenBottom,
            child: Align(
              alignment: _screenPanelAlign,
              child: _ScreenPanel(
                status: screenStatus,
                slotWidth: width * (1 - _screenLeft - _screenRight),
                slotHeight: h * (1 - _screenTop - _screenBottom),
              ),
            ),
          ),
          if (showMaster && masterStatus != null)
            _IpcSlot(
              w: width,
              h: h,
              centerX: width * _ipcMasterX,
              status: masterStatus!,
              label: '主',
            ),
          if (showBackup && backupStatus != null)
            _IpcSlot(
              w: width,
              h: h,
              centerX: width * _ipcBackupX,
              status: backupStatus!,
              label: '备',
            ),
        ],
      ),
    );
  }
}

class _ScreenPanel extends StatelessWidget {
  const _ScreenPanel({
    required this.status,
    required this.slotWidth,
    required this.slotHeight,
  });

  final String status;
  final double slotWidth;
  final double slotHeight;

  @override
  Widget build(BuildContext context) {
    final blockW = slotWidth * RackGidMapMarker._panelWidthFrac;
    final blockH = slotHeight * RackGidMapMarker._panelHeightFrac;
    final fontSize = (blockH * 0.14).clamp(7.0, 14.0);
    final gap = fontSize * RackGidMapMarker._charGapFrac;
    final chars = _displayChars(status);
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: _rackStatusTextColor(status),
      fontFamily: 'Microsoft YaHei',
      height: 1.0,
    );

    return SizedBox(
      width: blockW,
      height: blockH,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _rackStatusBackgroundColor(status),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < chars.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                Text(chars[i], style: textStyle, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static List<String> _displayChars(String status) {
    switch (status) {
      case '空闲':
        return const ['空', '闲'];
      case '联机':
        return const ['联', '机'];
      case '工作':
        return const ['工', '作'];
      case '结束':
        return const ['结', '束'];
      case '脱机':
        return const ['脱', '机'];
      case '错卡':
        return const ['错', '卡'];
      case '报到':
        return const ['报', '到'];
      case '重报':
        return const ['重', '报'];
      default:
        if (status.length <= 1) return [status];
        return [status.substring(0, 1), status.substring(1)];
    }
  }
}

class _IpcSlot extends StatelessWidget {
  const _IpcSlot({
    required this.w,
    required this.h,
    required this.centerX,
    required this.status,
    required this.label,
  });

  final double w;
  final double h;
  final double centerX;
  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final barW = math.max(10.0, w * RackGidMapMarker._ipcBarWidthFrac);
    final barH = math.max(4.0, h * RackGidMapMarker._ipcBarHeightFrac);
    final labelSize = (w * 0.10).clamp(5.0, 9.0);
    final top = h * RackGidMapMarker._ipcStatusTop;
    final barColor = _rackStatusBackgroundColor(status);

    return Positioned(
      left: centerX - barW / 2,
      top: top,
      width: barW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: barW,
            height: barH,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          SizedBox(height: math.max(1.0, barH * 0.35)),
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Microsoft YaHei',
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

Color _rackStatusTextColor(String status) =>
    DeviceStatusColors.foreground(status);

Color _rackStatusBackgroundColor(String status) =>
    DeviceStatusColors.background(status);
