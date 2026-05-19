import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/station_stat_lookup.dart';

/// 设备类型，用于控制颜色与图例
enum FacilityType {
  cabinet, // 报到机柜
  floorDevice, // 地垫式报到设备
  terminal, // 报到终端
  master, // 报到主控
}

/// 设备点位
class FacilityPoint {
  final String facilityId; // 设备ID或名称（这里直接用“东门”等）
  final FacilityType facilityType;

  /// 相对坐标 0~1（由设计页 X/Y 按 [DesignCoordinateMode] 换算，常见为 mm÷CanvasSize）
  final double x;
  final double y;
  final String cameraUri;
  final String ip;

  /// 后端返回的报到设备名称（若有）
  final String? stationName;

  /// 设计页上的设备宽高（与 CanvasSize 同单位，多为 mm），来自 DevicesSize
  final double designWidthMm;
  final double designHeightMm;

  /// 设计页原始坐标（未换算为 0~1）
  final double rawX;
  final double rawY;

  const FacilityPoint({
    required this.facilityId,
    required this.facilityType,
    required this.x,
    required this.y,
    required this.cameraUri,
    required this.ip,
    this.stationName,
    this.designWidthMm = 0,
    this.designHeightMm = 0,
    this.rawX = 0,
    this.rawY = 0,
  });

  /// 地图点位选中用的唯一键（避免多个点共用同一 FacilityID 时一起高亮）。
  String get selectionKey {
    final ipTrim = ip.trim();
    if (ipTrim.isNotEmpty) return 'ip:$ipTrim';
    final id = facilityId.trim();
    if (id.isNotEmpty && id != '未知设备') {
      return 'fid:$id@${x.toStringAsFixed(6)}@${y.toStringAsFixed(6)}';
    }
    return 'xy:${x.toStringAsFixed(6)}@${y.toStringAsFixed(6)}';
  }

  factory FacilityPoint.fromBackend(
    Map<String, dynamic> json,
    double canvasWidth,
    double canvasHeight, {
    DesignCoordinateMode coordinateMode = DesignCoordinateMode.designCanvasUnit,
  }) {
    final type = _facilityTypeFromString(
      json['FacilityType'] ?? json['facilityType'],
    );

    final rawX = _asDouble(json['X'] ?? json['x'], canvasWidth / 2);
    final rawY = _asDouble(json['Y'] ?? json['y'], canvasHeight / 2);

    final relativeX = _normalizeDesignAxis(
      rawX,
      canvasWidth,
      coordinateMode,
    );
    final relativeY = _normalizeDesignAxis(
      rawY,
      canvasHeight,
      coordinateMode,
    );

    final stationName = json['StationName']?.toString() ??
        json['stationName']?.toString() ??
        json['Name']?.toString() ??
        json['name']?.toString();

    double designWidthMm = 0;
    double designHeightMm = 0;
    final devicesSize = json['DevicesSize'] as List<dynamic>?;
    if (devicesSize != null && devicesSize.length >= 2) {
      designWidthMm = _asDouble(devicesSize[0], 0);
      designHeightMm = _asDouble(devicesSize[1], 0);
    }

    return FacilityPoint(
      facilityId: json['FacilityID']?.toString() ??
          json['facilityId']?.toString() ??
          json['metric']?.toString() ??
          '未知设备',
      facilityType: type,
      x: _clamp01(relativeX),
      y: _clamp01(relativeY),
      cameraUri: json['CameraURI']?.toString() ??
          json['cameraUri']?.toString() ??
          json['stream']?.toString() ??
          '',
      ip: json['IP']?.toString() ?? '',
      stationName: (stationName != null && stationName.isNotEmpty)
          ? stationName
          : null,
      designWidthMm: designWidthMm,
      designHeightMm: designHeightMm,
      rawX: rawX,
      rawY: rawY,
    );
  }

  static double _clamp01(double value) =>
      value.clamp(0.0, 1.0); // ignore: avoid_dynamic_calls

  /// 热重载后旧实例可能缺字段，读取时兜底避免红屏。
  static double _readLayoutDouble(double Function() read, {double fallback = 0}) {
    try {
      final v = read();
      if (v.isFinite) return v;
    } catch (_) {}
    return fallback;
  }

  double get layoutX => FacilityPoint._readLayoutDouble(() => x, fallback: 0);
  double get layoutY => FacilityPoint._readLayoutDouble(() => y, fallback: 0);
  double get layoutDesignWidthMm =>
      FacilityPoint._readLayoutDouble(() => designWidthMm, fallback: 0);
  double get layoutDesignHeightMm =>
      FacilityPoint._readLayoutDouble(() => designHeightMm, fallback: 0);
  double get layoutRawX =>
      FacilityPoint._readLayoutDouble(() => rawX, fallback: 0);
  double get layoutRawY =>
      FacilityPoint._readLayoutDouble(() => rawY, fallback: 0);

  static FacilityType _facilityTypeFromString(dynamic value) {
    final type = value?.toString().toLowerCase();
    switch (type) {
      case 'cabinet':
      case '机柜':
        return FacilityType.cabinet;
      case 'floor':
      case 'floordevice':
      case '地垫':
        return FacilityType.floorDevice;
      case 'terminal':
      case '终端':
        return FacilityType.terminal;
      case 'master':
      case '主控':
        return FacilityType.master;
      default:
        return FacilityType.terminal;
    }
  }
}

double _asDouble(dynamic value, double fallback) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

/// 设计页 X/Y 相对 [FacilityRouteSettings.canvasSize] 的换算方式。
enum DesignCoordinateMode {
  /// 已是 0~1
  relative01,
  /// 0~100 百分比
  percent100,
  /// 与 CanvasSize 同单位（设计页导出多为 mm），显示时除以 canvas 宽高
  designCanvasUnit,
}

/// 设计页 X/Y 锚点：左上角 或 中心点
enum DesignCoordinateAnchor {
  topLeft,
  center,
}

bool _hasMmLikeFraction(double value) {
  final frac = (value - value.truncate()).abs();
  if (frac < 0.001) return false;
  if ((frac - 0.5).abs() < 0.001) return false;
  return true;
}

DesignCoordinateMode? _coordinateModeFromUnitField(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString().trim().toLowerCase();
  if (s.isEmpty) return null;
  if (s.contains('mm') ||
      s.contains('millimeter') ||
      s == '1' ||
      s == 'canvas' ||
      s == 'design') {
    return DesignCoordinateMode.designCanvasUnit;
  }
  if (s.contains('percent') ||
      s.contains('%') ||
      s == '100' ||
      s == '0-100') {
    return DesignCoordinateMode.percent100;
  }
  if (s.contains('relative') || s == '0-1' || s == '01') {
    return DesignCoordinateMode.relative01;
  }
  return null;
}

DesignCoordinateMode _detectDesignCoordinateMode(
  List<dynamic> devicesJson,
  double canvasWidth,
  double canvasHeight, {
  Map<String, dynamic>? settingsJson,
}) {
  final fromUnit = _coordinateModeFromUnitField(
    settingsJson?['Unit'] ??
        settingsJson?['CoordinateUnit'] ??
        settingsJson?['PosUnit'] ??
        settingsJson?['unit'],
  );
  if (fromUnit != null) return fromUnit;

  var maxX = 0.0;
  var maxY = 0.0;
  var hasCoord = false;
  var hasMmHint = false;

  for (final item in devicesJson) {
    if (item is! Map) continue;
    final map = item.cast<String, dynamic>();
    if (!map.containsKey('X') &&
        !map.containsKey('x') &&
        !map.containsKey('Y') &&
        !map.containsKey('y')) {
      continue;
    }
    final x = _asDouble(map['X'] ?? map['x'], -1);
    final y = _asDouble(map['Y'] ?? map['y'], -1);
    if (x < 0 || y < 0) continue;
    hasCoord = true;
    maxX = math.max(maxX, x);
    maxY = math.max(maxY, y);
    if (x > 100 || y > 100) {
      hasMmHint = true;
    } else if (_hasMmLikeFraction(x) || _hasMmLikeFraction(y)) {
      hasMmHint = true;
    }
  }

  if (!hasCoord) return DesignCoordinateMode.designCanvasUnit;

  if (maxX <= 1.0 && maxY <= 1.0) {
    return DesignCoordinateMode.relative01;
  }

  // 0~100 百分比（四角测试点 5/95 等）；带 .14/.23 等非整刻度则按 mm
  if (!hasMmHint && maxX <= 100.0 && maxY <= 100.0) {
    return DesignCoordinateMode.percent100;
  }

  return DesignCoordinateMode.designCanvasUnit;
}

DesignCoordinateAnchor _detectDesignCoordinateAnchor(
  Map<String, dynamic>? settingsJson,
) {
  final raw = settingsJson?['Anchor'] ??
      settingsJson?['CoordinateAnchor'] ??
      settingsJson?['PosAnchor'];
  if (raw != null) {
    final s = raw.toString().toLowerCase();
    if (s.contains('center') || s.contains('中')) {
      return DesignCoordinateAnchor.center;
    }
    if (s.contains('left') ||
        s.contains('top') ||
        s.contains('左上') ||
        s.contains('topleft')) {
      return DesignCoordinateAnchor.topLeft;
    }
  }
  // 设计页导出带 DevicesSize 时，X/Y 一般为符号左上角
  return DesignCoordinateAnchor.topLeft;
}

bool _looksLikeRawBase64Image(String value) {
  final s = value.trim();
  if (s.length < 80) return false;
  if (s.startsWith('http') || s.startsWith('assets/')) return false;
  if (s.startsWith('data:image')) return true;
  return RegExp(r'^[A-Za-z0-9+/=\s_-]+$').hasMatch(s.substring(0, 80));
}

double _normalizeDesignAxis(
  double raw,
  double canvasExtent,
  DesignCoordinateMode mode,
) {
  switch (mode) {
    case DesignCoordinateMode.relative01:
      return FacilityPoint._clamp01(raw);
    case DesignCoordinateMode.percent100:
      return FacilityPoint._clamp01(raw / 100.0);
    case DesignCoordinateMode.designCanvasUnit:
      if (canvasExtent <= 0) return 0.5;
      return FacilityPoint._clamp01(raw / canvasExtent);
  }
}

// 解码后端返回的 Base64 底图，容错常见格式问题
Uint8List? _decodeBase64Image(dynamic raw) {
  if (raw == null) return null;
  var bgImg = raw.toString();
  if (bgImg.isEmpty) return null;

  // 移除 data:image/png;base64, 之类的前缀
  bgImg = bgImg.replaceFirst(RegExp(r'^data:image/[^;]+;base64,'), '');
  // 去掉空白字符
  bgImg = bgImg.replaceAll(RegExp(r'\s+'), '');
  // URL-safe 字符替换
  bgImg = bgImg.replaceAll('-', '+').replaceAll('_', '/');
  // 补全 padding
  final mod = bgImg.length % 4;
  if (mod != 0) {
    bgImg = bgImg.padRight(bgImg.length + (4 - mod), '=');
  }

  try {
    return base64Decode(bgImg);
  } catch (_) {
    return null;
  }
}

/// RouteSettings 中的配置：底图 + 尺寸 + 点位
class FacilityRouteSettings {
  final String imgName;
  final Size canvasSize;
  final String bgPath;
  final Uint8List? bgBytes;
  final List<FacilityPoint> facilities;
  final DesignCoordinateMode coordinateMode;
  final DesignCoordinateAnchor coordinateAnchor;

  const FacilityRouteSettings({
    required this.imgName,
    required this.canvasSize,
    required this.bgPath,
    this.bgBytes,
    required this.facilities,
    this.coordinateMode = DesignCoordinateMode.designCanvasUnit,
    this.coordinateAnchor = DesignCoordinateAnchor.topLeft,
  });

  factory FacilityRouteSettings.fromBackend(Map<String, dynamic> json) {
    final canvasSize =
        json['CanvasSize'] as List<dynamic>? ?? const <dynamic>[1920, 1080];
    final canvasWidth =
        canvasSize.isNotEmpty ? _asDouble(canvasSize[0], 1920) : 1920.0;
    final canvasHeight =
        canvasSize.length > 1 ? _asDouble(canvasSize[1], 1080) : 1080.0;

    final facilitiesJson = json['Devices'] as List<dynamic>? ?? const [];
    final coordinateMode = _detectDesignCoordinateMode(
      facilitiesJson,
      canvasWidth,
      canvasHeight,
      settingsJson: json,
    );
    final coordinateAnchor = _detectDesignCoordinateAnchor(json);
    final facilities = facilitiesJson
        .whereType<Map<String, dynamic>>()
        .map(
          (deviceJson) => FacilityPoint.fromBackend(
            deviceJson,
            canvasWidth,
            canvasHeight,
            coordinateMode: coordinateMode,
          ),
        )
        .toList();

    var bgBytes = _decodeBase64Image(json['BgImg']);

    // 兼容多种字段名，并进行 trim，避免空字符串导致 AssetImage('')
    final backendBgPath = (json['BgImgUrl'] ??
            json['BgImgPath'] ??
            json['BgPath'] ??
            json['ImgUrl'] ??
            json['ImgPath'] ??
            json['Img'])
        ?.toString()
        .trim();

    if ((bgBytes == null || bgBytes.isEmpty) &&
        backendBgPath != null &&
        backendBgPath.isNotEmpty &&
        _looksLikeRawBase64Image(backendBgPath)) {
      bgBytes = _decodeBase64Image(backendBgPath);
    }

    final resolvedBgPath = backendBgPath != null &&
            backendBgPath.isNotEmpty &&
            !_looksLikeRawBase64Image(backendBgPath)
        ? backendBgPath
        : 'assets/images/device_map.png';

    return FacilityRouteSettings(
      imgName: json['ImgName']?.toString() ?? '会议场地',
      canvasSize: Size(canvasWidth, canvasHeight),
      bgPath: resolvedBgPath,
      bgBytes: bgBytes,
      facilities: facilities.isEmpty
          ? FacilityRouteMap.demo().settings.facilities
          : facilities,
      coordinateMode: coordinateMode,
      coordinateAnchor: coordinateAnchor,
    );
  }
}

/// 设备路由图数据模型（与后端 FacilityRouteMap 对应的精简版）
class FacilityRouteMap {
  final String routeId;
  final String meetId;
  final String subMeetId;
  final FacilityRouteSettings settings;

  const FacilityRouteMap({
    required this.routeId,
    required this.meetId,
    required this.subMeetId,
    required this.settings,
  });

  /// 示例数据：人大大会堂布局 + 四个门的设备点位
  factory FacilityRouteMap.demo() {
    return FacilityRouteMap(
      routeId: 'route-001',
      meetId: 'meet-001',
      subMeetId: 'sub-001',
      settings: const FacilityRouteSettings(
        imgName: '会议场地',
        canvasSize: Size(1920, 1080),
        bgPath: 'assets/images/device_map.png',
        facilities: <FacilityPoint>[
          // 南门（左边）3 台设备
          FacilityPoint(
            facilityId: '南门-1',
            facilityType: FacilityType.floorDevice,
            x: 0.08,
            y: 0.35,
            cameraUri: 'rtsp://south-1',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '南门-2',
            facilityType: FacilityType.floorDevice,
            x: 0.10,
            y: 0.50,
            cameraUri: 'rtsp://south-2',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '南门-3',
            facilityType: FacilityType.floorDevice,
            x: 0.08,
            y: 0.65,
            cameraUri: 'rtsp://south-3',
            ip: '',
          ),
          // 东门（下边）9 台设备
          FacilityPoint(
            facilityId: '东门-1',
            facilityType: FacilityType.terminal,
            x: 0.20,
            y: 0.92,
            cameraUri: 'rtsp://east-1',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '东门-2',
            facilityType: FacilityType.terminal,
            x: 0.30,
            y: 0.93,
            cameraUri: 'rtsp://east-2',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '东门-3',
            facilityType: FacilityType.terminal,
            x: 0.40,
            y: 0.94,
            cameraUri: 'rtsp://east-3',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '东门-4',
            facilityType: FacilityType.terminal,
            x: 0.50,
            y: 0.95,
            cameraUri: 'rtsp://east-4',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '东门-5',
            facilityType: FacilityType.terminal,
            x: 0.60,
            y: 0.94,
            cameraUri: 'rtsp://east-5',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '东门-6',
            facilityType: FacilityType.terminal,
            x: 0.70,
            y: 0.93,
            cameraUri: 'rtsp://east-6',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '东门-7',
            facilityType: FacilityType.terminal,
            x: 0.80,
            y: 0.92,
            cameraUri: 'rtsp://east-7',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '东门-8',
            facilityType: FacilityType.terminal,
            x: 0.32,
            y: 0.88,
            cameraUri: 'rtsp://east-8',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '东门-9',
            facilityType: FacilityType.terminal,
            x: 0.68,
            y: 0.88,
            cameraUri: 'rtsp://east-9',
            ip: '',
          ),
          // 北门（右边）4 台设备
          FacilityPoint(
            facilityId: '北门-1',
            facilityType: FacilityType.cabinet,
            x: 0.92,
            y: 0.30,
            cameraUri: 'rtsp://north-1',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '北门-2',
            facilityType: FacilityType.cabinet,
            x: 0.90,
            y: 0.45,
            cameraUri: 'rtsp://north-2',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '北门-3',
            facilityType: FacilityType.cabinet,
            x: 0.92,
            y: 0.60,
            cameraUri: 'rtsp://north-3',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '北门-4',
            facilityType: FacilityType.cabinet,
            x: 0.88,
            y: 0.75,
            cameraUri: 'rtsp://north-4',
            ip: '',
          ),
          // 西门（上边）5 台设备
          FacilityPoint(
            facilityId: '西门-1',
            facilityType: FacilityType.master,
            x: 0.25,
            y: 0.08,
            cameraUri: 'rtsp://west-1',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '西门-2',
            facilityType: FacilityType.master,
            x: 0.40,
            y: 0.07,
            cameraUri: 'rtsp://west-2',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '西门-3',
            facilityType: FacilityType.master,
            x: 0.55,
            y: 0.06,
            cameraUri: 'rtsp://west-3',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '西门-4',
            facilityType: FacilityType.master,
            x: 0.70,
            y: 0.07,
            cameraUri: 'rtsp://west-4',
            ip: '',
          ),
          FacilityPoint(
            facilityId: '西门-5',
            facilityType: FacilityType.master,
            x: 0.85,
            y: 0.08,
            cameraUri: 'rtsp://west-5',
            ip: '',
          ),
        ],
      ),
    );
  }

  factory FacilityRouteMap.fromPayload(Map<String, dynamic> json) {
    Map<String, dynamic>? selected;

    final rawSettings =
        (json['RouteMapSettings'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            <Map<String, dynamic>>[];

    if (rawSettings.isNotEmpty) {
      selected = rawSettings.firstWhere(
        _isRouteSettingsMap,
        orElse: () => rawSettings.first,
      );
    }

    final routeId = json['RouteID']?.toString() ??
        json['RouteMapID']?.toString() ??
        selected?['RouteID']?.toString() ??
        'route-unknown';
    final meetId = json['MeetID']?.toString() ??
        json['meetID']?.toString() ??
        selected?['MeetID']?.toString() ??
        'meet-unknown';
    final subMeetId = json['SubMeetID']?.toString() ??
        json['subMeetID']?.toString() ??
        selected?['SubMeetID']?.toString() ??
        'sub-unknown';

    if (selected == null || selected.isEmpty) {
      if (_isRouteSettingsMap(json)) {
        selected = json;
      } else if (json['data'] is Map<String, dynamic> &&
          _isRouteSettingsMap(json['data'] as Map<String, dynamic>)) {
        selected = json['data'] as Map<String, dynamic>;
      }
    }

    if (selected == null || selected.isEmpty) {
      return FacilityRouteMap.demo();
    }

    return FacilityRouteMap(
      routeId: routeId,
      meetId: meetId,
      subMeetId: subMeetId,
      settings: FacilityRouteSettings.fromBackend(selected),
    );
  }

  static bool _isRouteSettingsMap(Map<String, dynamic> map) {
    return map.containsKey('Devices') ||
        map.containsKey('CanvasSize') ||
        map.containsKey('BgImg') ||
        map.containsKey('BgImgUrl') ||
        map.containsKey('BgImgPath') ||
        map.containsKey('BgPath') ||
        map.containsKey('ImgName');
  }
}

/// 按设计页 DevicesSize（mm）换算标记像素尺寸；无则沿用默认图标大小。
Size _markerSizeOnCanvas({
  required FacilityPoint point,
  required double renderWidth,
  required double renderHeight,
  required double canvasWidth,
  required double canvasHeight,
  required bool isPort8084,
}) {
  final designW = point.layoutDesignWidthMm;
  final designH = point.layoutDesignHeightMm;
  if (designW > 0 &&
      designH > 0 &&
      canvasWidth > 0 &&
      canvasHeight > 0) {
    final w = renderWidth * designW / canvasWidth;
    final h = renderHeight * designH / canvasHeight;
    return Size(
      w.clamp(12.0, renderWidth * 0.35),
      h.clamp(16.0, renderHeight * 0.45),
    );
  }
  return Size(20.0, isPort8084 ? 40.0 : 20.0);
}

class DeviceMapWidget extends StatefulWidget {
  const DeviceMapWidget({
    super.key,
    this.onCabinetTap,
    this.selectedGateName,
    this.routeMap,
    this.deviceStatusMap, // 设备状态映射：facilityId -> status
    this.port1030Map, // 设备是否 1030 端口：facilityId -> true/false
    this.port8084Map, // 设备是否 8084 端口：facilityId -> true/false
    this.facilityNameMap, // 设备显示名称：与 deviceStatusMap 相同的 key（FacilityID/IP/名称等）-> 名称
    this.deviceGidMap, // 设备 GID：key 与 deviceStatusMap 一致
    this.deviceIsMasterMap, // 是否主机：key 与 deviceStatusMap 一致
    this.stationStats, // 站点人数：Station -> { attend, guest }（与 WS_StationNum 一致，查找见 lookupStationStatRow）
  });

  final Function(String)? onCabinetTap; // 点击机柜/设备的回调
  final String? selectedGateName; // 当前选中点位的 selectionKey（见 FacilityPoint.selectionKey）
  final FacilityRouteMap? routeMap; // 路由与点位数据
  final Map<String, String>? deviceStatusMap; // 设备状态映射：facilityId -> status (空闲/报到/工作/重报)
  final Map<String, bool>? port1030Map; // 设备是否 1030 端口：facilityId -> true/false
  final Map<String, bool>? port8084Map; // 设备是否 8084 端口：facilityId -> true/false
  final Map<String, String>? facilityNameMap;
  final Map<String, String>? deviceGidMap;
  final Map<String, bool>? deviceIsMasterMap;
  final Map<String, Map<String, int>>? stationStats;

  @override
  State<DeviceMapWidget> createState() => _DeviceMapWidgetState();
}

/// 点位图层项：单点或同 GID 合并
class _MapMarkerLayerItem {
  const _MapMarkerLayerItem.single(this.point)
      : points = const [],
        gid = '';

  const _MapMarkerLayerItem.group(this.points, this.gid) : point = null;

  final FacilityPoint? point;
  final List<FacilityPoint> points;
  final String gid;

  bool get isGroup => points.length > 1;
  FacilityPoint get anchorPoint =>
      isGroup ? points.first : (point ?? points.first);
}

class _DeviceMapWidgetState extends State<DeviceMapWidget> {
  ImageProvider<Object>? _cachedBgImage;
  FacilityRouteSettings? _cachedSettings;

  FacilityRouteMap get _effectiveRouteMap =>
      widget.routeMap ?? FacilityRouteMap.demo();

  ImageProvider<Object> _getOrBuildBgImage(FacilityRouteSettings settings) {
    // 如果 settings 没变，直接返回缓存的 ImageProvider
    if (_cachedSettings == settings && _cachedBgImage != null) {
      return _cachedBgImage!;
    }
    // settings 变了，重新创建并缓存
    _cachedSettings = settings;
    _cachedBgImage = _buildBgImage(settings);
    return _cachedBgImage!;
  }

  DesignCoordinateAnchor _readCoordinateAnchor(FacilityRouteSettings settings) {
    try {
      return settings.coordinateAnchor;
    } catch (_) {
      return DesignCoordinateAnchor.topLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设备分布图：固定渲染区域 1250x650，保证底图铺满
          SizedBox(
            width: 1250,
            height: 630,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final settings = _effectiveRouteMap.settings;
                final facilities = settings.facilities.isEmpty
                    ? FacilityRouteMap.demo().settings.facilities
                    : settings.facilities;

                // 固定为 1250x650，若外部约束更小则按可用空间等比缩放
                final targetWidth = 1250.0;
                final targetHeight = 650.0;
                final baseWidth =
                    settings.canvasSize.width == 0 ? targetWidth : settings.canvasSize.width;
                final baseHeight =
                    settings.canvasSize.height == 0 ? targetHeight : settings.canvasSize.height;

                final scale = math.min(
                  constraints.maxWidth / baseWidth,
                  constraints.maxHeight / baseHeight,
                );

                final effectiveScale =
                    (scale.isFinite && scale > 0 ? scale : 1.0).toDouble();
                final renderWidth = (baseWidth * effectiveScale).toDouble();
                final renderHeight = (baseHeight * effectiveScale).toDouble();

                final markerItems = _buildMapMarkerLayerItems(facilities);

                return Center(
                  child: ClipRect(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 3.5,
                      boundaryMargin: const EdgeInsets.all(0),
                      child: SizedBox(
                        width: renderWidth,
                        height: renderHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage(
                                    image: _getOrBuildBgImage(settings),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            ...markerItems.map((item) {
                              final anchor = item.anchorPoint;
                              final isPort1030 =
                                  _resolvePort(widget.port1030Map, anchor);
                              final isPort8084 =
                                  _resolvePort(widget.port8084Map, anchor);
                              final markerSize = _markerSizeOnCanvas(
                                point: anchor,
                                renderWidth: renderWidth,
                                renderHeight: renderHeight,
                                canvasWidth: baseWidth,
                                canvasHeight: baseHeight,
                                isPort8084: isPort8084,
                              );
                              final markerWidth = markerSize.width;
                              final markerHeight = markerSize.height;
                              final layoutX = anchor.layoutX;
                              final layoutY = anchor.layoutY;
                              final coordAnchor =
                                  _readCoordinateAnchor(settings);
                              final layerWidth = item.isGroup
                                  ? markerWidth *
                                      (1.85 + 0.12 * (item.points.length - 2))
                                      .clamp(1.85, 2.4)
                                  : markerWidth;
                              final left =
                                  coordAnchor == DesignCoordinateAnchor.center
                                      ? renderWidth * layoutX - layerWidth / 2
                                      : renderWidth * layoutX;
                              final top =
                                  coordAnchor == DesignCoordinateAnchor.center
                                      ? renderHeight * layoutY -
                                          markerHeight / 2
                                      : renderHeight * layoutY;
                              final isSelected = item.isGroup
                                  ? item.points.any((p) =>
                                      widget.selectedGateName ==
                                      p.selectionKey)
                                  : widget.selectedGateName ==
                                      anchor.selectionKey;

                              return Positioned(
                                left: left,
                                top: top,
                                child: item.isGroup
                                    ? _buildGidGroupMarker(
                                        context,
                                        points: item.points,
                                        isSelected: isSelected,
                                        markerWidth: markerWidth,
                                        markerHeight: markerHeight,
                                        onTap: widget.onCabinetTap,
                                      )
                                    : _buildFacilityMarker(
                                        context,
                                        point: anchor,
                                        isSelected: isSelected,
                                        status: _resolveStatus(
                                          widget.deviceStatusMap,
                                          anchor,
                                        ),
                                        isPort1030: isPort1030,
                                        isPort8084: isPort8084,
                                        markerWidth: markerWidth,
                                        markerHeight: markerHeight,
                                        onTap: widget.onCabinetTap,
                                      ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox.shrink(), // 图例暂时隐藏
        ],
      ),
    );
  }

  String? _resolveStatus(
    Map<String, String>? statusMap,
    FacilityPoint point,
  ) {
    if (statusMap == null) return null;
    return statusMap[point.facilityId] ??
        (point.ip.isNotEmpty ? statusMap[point.ip] : null) ??
        (point.cameraUri.isNotEmpty ? statusMap[point.cameraUri] : null) ??
        (point.stationName != null && point.stationName!.isNotEmpty
            ? statusMap[point.stationName!]
            : null);
  }

  bool _resolvePort(
    Map<String, bool>? portMap,
    FacilityPoint point,
  ) {
    if (portMap == null) return false;
    return portMap[point.facilityId] ??
        (point.ip.isNotEmpty ? portMap[point.ip] : null) ??
        (point.cameraUri.isNotEmpty ? portMap[point.cameraUri] : null) ??
        (point.stationName != null && point.stationName!.isNotEmpty
            ? portMap[point.stationName!]
            : null) ??
        false;
  }

  T? _lookupDeviceField<T>(
    Map<String, T>? map,
    FacilityPoint point,
  ) {
    if (map == null) return null;
    final keys = <String>[
      point.facilityId,
      if (point.ip.isNotEmpty) point.ip,
      if (point.cameraUri.isNotEmpty) point.cameraUri,
      if (point.stationName != null && point.stationName!.isNotEmpty)
        point.stationName!,
    ];
    for (final k in keys) {
      if (map.containsKey(k)) return map[k];
    }
    return null;
  }

  String _resolveGid(FacilityPoint point) =>
      (_lookupDeviceField(widget.deviceGidMap, point) ?? '').trim();

  bool? _resolveIsMaster(FacilityPoint point) =>
      _lookupDeviceField(widget.deviceIsMasterMap, point);

  List<FacilityPoint> _sortFacilitiesMasterFirst(List<FacilityPoint> group) {
    final sorted = List<FacilityPoint>.from(group);
    sorted.sort((a, b) {
      final am = _resolveIsMaster(a) == true;
      final bm = _resolveIsMaster(b) == true;
      if (am != bm) return am ? -1 : 1;
      return a.facilityId.compareTo(b.facilityId);
    });
    if (sorted.every((p) => _resolveIsMaster(p) == null) && sorted.length > 1) {
      // 无明确主备时保持原顺序，仅取前两台展示
    }
    return sorted;
  }

  List<_MapMarkerLayerItem> _buildMapMarkerLayerItems(
    List<FacilityPoint> facilities,
  ) {
    final processedGids = <String>{};
    final items = <_MapMarkerLayerItem>[];

    for (final f in facilities) {
      final gid = _resolveGid(f);
      if (gid.isEmpty) {
        items.add(_MapMarkerLayerItem.single(f));
        continue;
      }
      if (processedGids.contains(gid)) continue;
      processedGids.add(gid);

      final group =
          facilities.where((p) => _resolveGid(p) == gid).toList(growable: false);
      if (group.length > 1) {
        items.add(
          _MapMarkerLayerItem.group(_sortFacilitiesMasterFirst(group), gid),
        );
      } else {
        items.add(_MapMarkerLayerItem.single(group.first));
      }
    }
    return items;
  }

  String _roleLabelForFacility(FacilityPoint point, int indexInGroup) {
    final master = _resolveIsMaster(point);
    if (master == true) return '主';
    if (master == false) return '备';
    return indexInGroup == 0 ? '主' : '备';
  }

  /// 同 GID 多台：紧凑并排，与报到设备列表一致
  Widget _buildGidGroupMarker(
    BuildContext context, {
    required List<FacilityPoint> points,
    required bool isSelected,
    required double markerWidth,
    required double markerHeight,
    Function(String)? onTap,
  }) {
    const overlap = 0.22;
    final show = points.length > 2 ? points.sublist(0, 2) : points;
    final unitW = markerWidth * 0.52;
    final totalW = unitW * show.length - unitW * overlap * (show.length - 1);
    final anchor = show.first;
    final displayName = _resolveDisplayName(anchor);
    final masterCounts = _resolveAttendGuest(anchor);
    final tooltipBuf = StringBuffer()
      ..writeln('设备名称：$displayName')
      ..writeln('出席人数：${masterCounts.attend}')
      ..writeln('列席人数：${masterCounts.guest}');

    return GestureDetector(
      onTap: () => onTap?.call(anchor.selectionKey),
      child: Tooltip(
        message: tooltipBuf.toString().trimRight(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: totalW,
          height: markerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
                for (int i = 0; i < show.length; i++)
                  Positioned(
                    left: i * unitW * (1 - overlap),
                    top: 0,
                    bottom: 0,
                    width: unitW,
                    child: _buildFacilityMarkerVisual(
                      point: show[i],
                      markerWidth: unitW,
                      markerHeight: markerHeight,
                      roleLabel: _roleLabelForFacility(show[i], i),
                    ),
                  ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildFacilityMarkerVisual({
    required FacilityPoint point,
    required double markerWidth,
    required double markerHeight,
    String? roleLabel,
  }) {
    final status = _resolveStatus(widget.deviceStatusMap, point);
    final isPort1030 = _resolvePort(widget.port1030Map, point);
    final isPort8084 = _resolvePort(widget.port8084Map, point);
    final statusImagePath = _getStatusImagePath(
      status,
      isPort1030: isPort1030,
      isPort8084: isPort8084,
    );
    final fallbackImage = isPort1030
        ? 'assets/images/dj_kongxian.png'
        : (isPort8084
            ? 'assets/images/jb_konxian.png'
            : 'assets/images/jsj_kongxian.png');

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          statusImagePath ?? fallbackImage,
          width: markerWidth,
          height: markerHeight,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultMarker(point, false, markerHeight);
          },
        ),
        if (roleLabel != null)
          Positioned(
            bottom: markerHeight * 0.12,
            left: 0,
            right: 0,
            child: Text(
              roleLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (markerWidth * 0.26).clamp(6.0, 8.0),
                fontWeight: FontWeight.w600,
                fontFamily: 'Microsoft YaHei',
                color: const Color(0xFF616161),
                height: 1,
                shadows: const [
                  Shadow(color: Colors.white, blurRadius: 2),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _resolveDisplayName(FacilityPoint point) {
    final m = widget.facilityNameMap;
    if (m != null) {
      final byFacility = m[point.facilityId];
      if (byFacility != null && byFacility.isNotEmpty) return byFacility;
      if (point.ip.isNotEmpty) {
        final byIp = m[point.ip];
        if (byIp != null && byIp.isNotEmpty) return byIp;
      }
      if (point.cameraUri.isNotEmpty) {
        final byCam = m[point.cameraUri];
        if (byCam != null && byCam.isNotEmpty) return byCam;
      }
    }
    final sn = point.stationName;
    if (sn != null && sn.isNotEmpty) return sn;
    return point.facilityId;
  }

  ({int attend, int guest}) _resolveAttendGuest(FacilityPoint point) {
    final stats = widget.stationStats;
    if (stats == null || point.ip.isEmpty) {
      return (attend: 0, guest: 0);
    }
    final row = lookupStationStatRow(
      stats,
      point.ip,
      stationName: point.stationName ?? '',
    );
    if (row == null) return (attend: 0, guest: 0);
    return (
      attend: row['attend'] ?? 0,
      guest: row['guest'] ?? 0,
    );
  }

  ImageProvider<Object> _buildBgImage(FacilityRouteSettings settings) {
    final bytes = settings.bgBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return MemoryImage(bytes);
    }
    final path = settings.bgPath;
    if (path.isEmpty) {
      return const AssetImage(''); // 返回一个空的占位，避免异常
    }
    if (path.startsWith('data:image')) {
      final parts = path.split(',');
      if (parts.length == 2) {
        final decoded = _decodeBase64Image(parts[1]);
        if (decoded != null && decoded.isNotEmpty) {
          return MemoryImage(decoded);
        }
      }
      return const AssetImage(''); // 兜底，避免 AssetImage('data:...') 报错
    }
    if (_looksLikeRawBase64Image(path)) {
      final decoded = _decodeBase64Image(path);
      if (decoded != null && decoded.isNotEmpty) {
        return MemoryImage(decoded);
      }
      return const AssetImage('');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  /// 单个设备点位图标
  Widget _buildFacilityMarker(
    BuildContext context, {
    required FacilityPoint point,
    required bool isSelected,
    String? status,
    bool isPort1030 = false,
    bool isPort8084 = false,
    double markerWidth = 20,
    double markerHeight = 20,
    Function(String)? onTap,
  }) {
    // 根据状态获取对应的图片路径
    final statusImagePath = _getStatusImagePath(
      status,
      isPort1030: isPort1030,
      isPort8084: isPort8084,
    );
    final fallbackImage = isPort1030
        ? 'assets/images/dj_kongxian.png'
        : (isPort8084
            ? 'assets/images/jb_konxian.png'
            : 'assets/images/jsj_kongxian.png');
    final double effectiveWidth =
        markerWidth > 0 ? markerWidth : (isPort8084 ? 20.0 : 20.0);
    final double effectiveHeight =
        markerHeight > 0 ? markerHeight : (isPort8084 ? 40.0 : 20.0);

    final displayName = _resolveDisplayName(point);
    final counts = _resolveAttendGuest(point);
    final tooltipBuf = StringBuffer()
      ..writeln('设备名称：$displayName')
      ..writeln('状态：${status ?? '未知状态'}')
      ..writeln('出席人数：${counts.attend}')
      ..writeln('列席人数：${counts.guest}');

    return GestureDetector(
      onTap: () => onTap?.call(point.selectionKey),
      child: Tooltip(
        message: tooltipBuf.toString().trimRight(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Image.asset(
            statusImagePath ?? fallbackImage,
            width: effectiveWidth,
            height: effectiveHeight,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultMarker(point, isSelected, effectiveHeight);
            },
          ),
        ),
      ),
    );
  }

  /// 根据状态获取对应的图片路径
  String? _getStatusImagePath(
    String? status, {
    bool isPort1030 = false,
    bool isPort8084 = false,
  }) {
    if (status == null) {
      return isPort1030
          ? 'assets/images/dj_kongxian.png'
          : (isPort8084
              ? 'assets/images/jb_konxian.png'
              : 'assets/images/jsj_kongxian.png');
    }

    // 1030 端口使用 dj_ 前缀图片
    if (isPort1030) {
      switch (status) {
        case '空闲':
          return 'assets/images/dj_kongxian.png';
        case '报到':
          return 'assets/images/dj_baodao.png';
        case '工作':
          return 'assets/images/dj_gongzuo.png';
        case '重报':
          return 'assets/images/dj_chongbao.png';
        default:
          return 'assets/images/dj_kongxian.png';
      }
    }
    
    // 8084 端口使用 jb_ 前缀图片
    if (isPort8084) {
      switch (status) {
        case '空闲':
          return 'assets/images/jb_konxian.png';
        case '报到':
          return 'assets/images/jb_baodao.png';
        case '工作':
          return 'assets/images/jb_gongzuo.png';
        case '重报':
          return 'assets/images/jb_chongbao.png';
        default:
          return 'assets/images/jb_konxian.png';
      }
    }

    // 其他端口统一用 jsj_ 前缀图片
    switch (status) {
      case '空闲':
        return 'assets/images/jsj_kongxian.png';
      case '报到':
        return 'assets/images/jsj_baodao.png';
      case '工作':
        return 'assets/images/jsj_gongzuo.png';
      case '重报':
        return 'assets/images/jsj_chongbao.png';
      default:
        return 'assets/images/jsj_kongxian.png';
    }
  }

  /// 默认标记样式（当没有状态图片时使用）
  Widget _buildDefaultMarker(
    FacilityPoint point,
    bool isSelected,
    double markerHeight,
  ) {
    return Container(
      width: 20,
      height: markerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black26,
          width: 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          point.facilityId.length > 4
              ? point.facilityId.substring(0, 4)
              : point.facilityId,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}


