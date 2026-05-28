import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/station_stat_lookup.dart';
import 'attend_device_map_marker.dart';
import 'rack_gid_map_marker.dart';

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
      facilities: facilities,
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
      return FacilityRouteMap(
        routeId: routeId,
        meetId: meetId,
        subMeetId: subMeetId,
        settings: FacilityRouteSettings(
          imgName: json['ImgName']?.toString() ?? '',
          canvasSize: const Size(1250, 650),
          bgPath: '',
          facilities: const [],
        ),
      );
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
    this.routeMap,
    this.deviceStatusMap, // 设备状态映射：facilityId -> status
    this.port1030Map, // 设备是否 1030 端口：facilityId -> true/false
    this.port8084Map, // 设备是否 8084 端口：facilityId -> true/false
    this.facilityNameMap, // 设备显示名称：与 deviceStatusMap 相同的 key（FacilityID/IP/名称等）-> 名称
    this.deviceGidMap, // 设备 GID：key 与 deviceStatusMap 一致
    this.deviceIsMasterMap, // 是否主机：key 与 deviceStatusMap 一致
    this.deviceProcessTypeMap, // ProcessType：key 与 deviceStatusMap 一致
    this.gidMembersByGid, // 同 GID 的 WS 设备；设计图仅 1 个点时仍可画主备
    this.stationStats, // 站点人数：Station -> { attend, guest }（与 WS_StationNum 一致，查找见 lookupStationStatRow）
  });

  final FacilityRouteMap? routeMap; // 路由与点位数据
  final Map<String, String>? deviceStatusMap; // 设备状态映射：facilityId -> status (空闲/报到/工作/重报)
  final Map<String, bool>? port1030Map; // 设备是否 1030 端口：facilityId -> true/false
  final Map<String, bool>? port8084Map; // 设备是否 8084 端口：facilityId -> true/false
  final Map<String, String>? facilityNameMap;
  final Map<String, String>? deviceGidMap;
  final Map<String, bool>? deviceIsMasterMap;
  final Map<String, String>? deviceProcessTypeMap;
  final Map<String, List<GidMapMemberInfo>>? gidMembersByGid;
  final Map<String, Map<String, int>>? stationStats;

  @override
  State<DeviceMapWidget> createState() => _DeviceMapWidgetState();
}

/// 同 GID 在 WS_Client 中的一台设备（状态查找 key + 主备）
class GidMapMemberInfo {
  const GidMapMemberInfo({
    required this.statusLookupKey,
    this.isMaster,
    this.processType,
    this.status,
    this.isActive = false,
    this.attend = 0,
    this.guest = 0,
  });

  final String statusLookupKey;
  final bool? isMaster;
  final String? processType;
  final String? status;
  final bool isActive;
  final int attend;
  final int guest;
}

/// 点位图层项：单点或同 GID 合并
class _MapMarkerLayerItem {
  const _MapMarkerLayerItem.single(this.point)
      : points = const [],
        gid = '',
        members = const [];

  const _MapMarkerLayerItem.group(
    this.points,
    this.gid, {
    this.members = const [],
  }) : point = null;

  final FacilityPoint? point;
  final List<FacilityPoint> points;
  final String gid;
  final List<GidMapMemberInfo> members;

  bool get isGroup => points.length > 1;
  FacilityPoint get anchorPoint =>
      isGroup ? points.first : (point ?? points.first);
}

class _DeviceMapWidgetState extends State<DeviceMapWidget> {
  ImageProvider<Object>? _cachedBgImage;
  FacilityRouteSettings? _cachedSettings;
  String? _hoverMarkerKey;

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
    final routeMap = widget.routeMap;
    if (routeMap == null) {
      return const SizedBox(
        width: 1250,
        height: 630,
        child: ColoredBox(color: Color(0xFFF5F5F5)),
      );
    }

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
                final settings = routeMap.settings;
                final facilities = settings.facilities;

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
                          clipBehavior: Clip.none,
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
                              final rackCabinet =
                                  _isRackCabinetMapItem(item, anchor);
                              final layerWidth = item.isGroup && !rackCabinet
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
                              return Positioned(
                                left: left,
                                top: top,
                                child: rackCabinet
                                    ? _buildRackGidMapMarkerHover(
                                        point: anchor,
                                        members: () {
                                          if (item.isGroup) {
                                            return item.members;
                                          }
                                          final gidMembers =
                                              _membersForPointGid(anchor);
                                          return gidMembers.isNotEmpty
                                              ? gidMembers
                                              : item.members;
                                        }(),
                                        markerWidth: markerWidth,
                                      )
                                    : item.isGroup
                                        ? _buildGidGroupMarker(
                                            context,
                                            points: item.points,
                                            members: item.members,
                                            markerWidth: markerWidth,
                                            markerHeight: markerHeight,
                                          )
                                        : _buildFacilityMarker(
                                            context,
                                            point: anchor,
                                            status: _resolveStatus(
                                              widget.deviceStatusMap,
                                              anchor,
                                            ),
                                            isPort1030: isPort1030,
                                            isPort8084: isPort8084,
                                            markerWidth: markerWidth,
                                            markerHeight: markerHeight,
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

  String? _resolveProcessType(FacilityPoint point) =>
      _lookupDeviceField(widget.deviceProcessTypeMap, point);

  /// 与报到设备列表一致的 ProcessType（用于底图与状态叠层）。
  String _resolveMapProcessType(
    FacilityPoint point, {
    required bool isPort1030,
    required bool isPort8084,
  }) {
    final fromMap = _resolveProcessType(point)?.trim() ?? '';
    if (fromMap == 'rack') return 'rack';
    if (fromMap.isNotEmpty) return fromMap;
    if (isPort1030 || point.facilityType == FacilityType.floorDevice) {
      return 'didian';
    }
    if (point.facilityType == FacilityType.cabinet) return 'rack';
    return 'Client';
  }

  List<GidMapMemberInfo> _membersForPointGid(FacilityPoint point) {
    final gid = _resolveGid(point);
    if (gid.isEmpty) return const [];
    return widget.gidMembersByGid?[gid] ?? const [];
  }

  bool _isRackGidMapItem(_MapMarkerLayerItem item, FacilityPoint anchor) {
    final gid = item.gid.isNotEmpty ? item.gid : _resolveGid(anchor);
    if (gid.isEmpty) return false;
    if (item.members.any((m) => m.processType == 'rack')) return true;
    final ws = widget.gidMembersByGid?[gid];
    if (ws != null && ws.any((m) => m.processType == 'rack')) return true;
    if (_resolveProcessType(anchor) == 'rack') return true;
    return anchor.facilityType == FacilityType.cabinet;
  }

  /// 机柜点位（含无 GID 单机柜）与报到列表一致，用 device22 叠层。
  bool _isRackCabinetMapItem(_MapMarkerLayerItem item, FacilityPoint anchor) {
    if (_isRackGidMapItem(item, anchor)) return true;
    if (_resolveProcessType(anchor) == 'rack') return true;
    return anchor.facilityType == FacilityType.cabinet;
  }

  GidMapMemberInfo? _pickMasterMember(List<GidMapMemberInfo> members) {
    for (final m in members) {
      if (m.isMaster == true) return m;
    }
    return members.isNotEmpty ? members.first : null;
  }

  GidMapMemberInfo? _pickBackupMember(List<GidMapMemberInfo> members) {
    for (final m in members) {
      if (m.isMaster == false) return m;
    }
    if (members.length > 1) {
      final master = _pickMasterMember(members);
      for (final m in members) {
        if (!identical(m, master)) return m;
      }
    }
    return null;
  }

  /// 与报到设备 [_screenDeviceInGroup] 一致：主脱机时大屏展示备机状态。
  String _memberStatus(FacilityPoint point, GidMapMemberInfo member) {
    final cached = member.status?.trim() ?? '';
    if (cached.isNotEmpty) return cached;
    return _resolveStatusForMember(point, member) ?? '空闲';
  }

  String _resolveScreenStatusForRackGid(
    FacilityPoint point,
    List<GidMapMemberInfo> members,
  ) {
    if (members.isEmpty) {
      return _resolveStatus(widget.deviceStatusMap, point) ?? '空闲';
    }

    for (final m in members) {
      if (m.isActive) return _memberStatus(point, m);
    }
    for (final m in members) {
      final st = _memberStatus(point, m);
      if (st == '工作' || st == '报到' || st == '重报') return st;
    }

    final master = _pickMasterMember(members);
    final backup = _pickBackupMember(members);
    if (master != null &&
        backup != null &&
        _memberStatus(point, master) == '脱机') {
      return _memberStatus(point, backup);
    }

    for (final m in members) {
      final st = _memberStatus(point, m);
      if (st != '脱机') return st;
    }

    return master != null
        ? _memberStatus(point, master)
        : _memberStatus(point, members.first);
  }

  Widget _buildRackGidMapMarkerHover({
    required FacilityPoint point,
    required List<GidMapMemberInfo> members,
    required double markerWidth,
  }) {
    final master = _pickMasterMember(members);
    final backup = _pickBackupMember(members);
    final screenStatus = _resolveScreenStatusForRackGid(point, members);
    final rackW = markerWidth.clamp(20.0, 72.0);
    final rackH = rackW / RackGidMapMarker.imageAspect;
    final hoverKey = members.isEmpty
        ? _markerSelectionKey(point)
        : 'rackgid:${point.selectionKey}';

    return _wrapMapMarkerHoverTarget(
      point: point,
      lookupKey: master?.statusLookupKey,
      gidMembers: members,
      hoverKey: hoverKey,
      width: rackW,
      height: rackH,
      child: RackGidMapMarker(
        width: rackW,
        screenStatus: screenStatus,
        masterStatus: master != null ? _memberStatus(point, master) : null,
        backupStatus: backup != null ? _memberStatus(point, backup) : null,
        showMaster: master != null,
        showBackup: backup != null,
      ),
    );
  }

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
      final wsMembers = widget.gidMembersByGid?[gid] ?? const [];
      if (group.length > 1) {
        items.add(
          _MapMarkerLayerItem.group(
            _sortFacilitiesMasterFirst(group),
            gid,
            members: wsMembers,
          ),
        );
      } else if (group.length == 1 && wsMembers.length > 1) {
        final anchor = group.first;
        final displayCount = wsMembers.length > 2 ? 2 : wsMembers.length;
        items.add(
          _MapMarkerLayerItem.group(
            List<FacilityPoint>.filled(displayCount, anchor),
            gid,
            members: wsMembers,
          ),
        );
      } else {
        items.add(_MapMarkerLayerItem.single(group.first));
      }
    }
    return items;
  }

  String _roleLabelForFacility(
    FacilityPoint point,
    int indexInGroup, {
    GidMapMemberInfo? member,
  }) {
    if (member?.isMaster == true) return '主';
    if (member?.isMaster == false) return '备';
    final master = _resolveIsMaster(point);
    if (master == true) return '主';
    if (master == false) return '备';
    return indexInGroup == 0 ? '主' : '备';
  }

  String? _resolveStatusForMember(
    FacilityPoint point,
    GidMapMemberInfo? member,
  ) {
    if (member == null) {
      return _resolveStatus(widget.deviceStatusMap, point);
    }
    final cached = member.status?.trim() ?? '';
    if (cached.isNotEmpty) return cached;
    final key = member.statusLookupKey.trim();
    if (key.isNotEmpty) {
      final m = widget.deviceStatusMap;
      if (m != null && m.containsKey(key)) return m[key];
    }
    return _resolveStatus(widget.deviceStatusMap, point);
  }

  bool _resolvePortForMember(
    Map<String, bool>? portMap,
    FacilityPoint point,
    GidMapMemberInfo? member,
  ) {
    final key = member?.statusLookupKey.trim() ?? '';
    if (key.isNotEmpty && portMap != null && portMap.containsKey(key)) {
      return portMap[key] ?? false;
    }
    return _resolvePort(portMap, point);
  }

  String _markerSelectionKey(
    FacilityPoint point, {
    GidMapMemberInfo? member,
    int indexInGroup = 0,
  }) {
    final memberKey = member?.statusLookupKey.trim() ?? '';
    if (memberKey.isNotEmpty) return 'member:$memberKey';
    return '${point.selectionKey}@$indexInGroup';
  }

  String _resolveDisplayName(
    FacilityPoint point, {
    String? lookupKey,
  }) {
    final m = widget.facilityNameMap;
    if (m != null) {
      if (lookupKey != null && lookupKey.isNotEmpty) {
        final byKey = m[lookupKey];
        if (byKey != null && byKey.isNotEmpty) return byKey;
      }
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

  /// 悬停浮层用：去掉名称末尾主/备相关括号（含「备88」等），避免「东门南 (备88) (备)」重复。
  String _stripHoverMapNameDecorations(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return raw;
    final tail = RegExp(r'\s*[\(（]([^)）]+)[\)）]\s*$');
    while (true) {
      final m = tail.firstMatch(s);
      if (m == null) break;
      final inner = m.group(1)!.trim();
      final isRoleParen = inner == '主' ||
          inner == '备' ||
          RegExp(r'^备\d+$').hasMatch(inner) ||
          RegExp(r'^主\d+$').hasMatch(inner);
      if (!isRoleParen) break;
      s = s.substring(0, m.start).trimRight();
    }
    return s.isEmpty ? raw.trim() : s;
  }

  ({int attend, int guest}) _sumGidMemberCounts(
    List<GidMapMemberInfo> members,
  ) {
    var attend = 0;
    var guest = 0;
    for (final m in members) {
      attend += m.attend;
      guest += m.guest;
    }
    return (attend: attend, guest: guest);
  }

  ({int attend, int guest}) _resolveAttendGuest(
    FacilityPoint point, {
    String? lookupKey,
    List<GidMapMemberInfo> gidMembers = const [],
  }) {
    if (gidMembers.isNotEmpty) {
      return _sumGidMemberCounts(gidMembers);
    }

    final stats = widget.stationStats;
    if (stats == null) return (attend: 0, guest: 0);

    Map<String, int>? row;
    final key = lookupKey?.trim() ?? '';
    if (key.isNotEmpty) {
      row = lookupStationStatRow(
        stats,
        key,
        stationName: key,
        nodeId: key,
      );
    }
    row ??= lookupStationStatRow(
      stats,
      point.ip,
      stationName: point.stationName ?? '',
      nodeId: point.facilityId,
    );
    if (row == null) return (attend: 0, guest: 0);
    return (
      attend: row['attend'] ?? 0,
      guest: row['guest'] ?? 0,
    );
  }

  String _formatHoverPopupLabel(
    FacilityPoint point, {
    String? lookupKey,
    List<GidMapMemberInfo> gidMembers = const [],
  }) {
    final name = _stripHoverMapNameDecorations(
      _resolveDisplayName(point, lookupKey: lookupKey),
    );
    final counts = _resolveAttendGuest(
      point,
      lookupKey: lookupKey,
      gidMembers: gidMembers,
    );
    return '名称：$name\n出席人数：${counts.attend}\n列席人数：${counts.guest}';
  }

  Widget _buildMapPopupLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Microsoft YaHei',
          height: 1.35,
        ),
      ),
    );
  }

  Widget _wrapMapMarkerHoverTarget({
    required FacilityPoint point,
    String? lookupKey,
    List<GidMapMemberInfo> gidMembers = const [],
    required String hoverKey,
    required double width,
    required double height,
    required Widget child,
  }) {
    final isHovered = _hoverMarkerKey == hoverKey;
    final hoverLabel = _formatHoverPopupLabel(
      point,
      lookupKey: lookupKey,
      gidMembers: gidMembers,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hoverMarkerKey = hoverKey),
      onExit: (_) {
        if (_hoverMarkerKey == hoverKey) {
          setState(() => _hoverMarkerKey = null);
        }
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            child,
            if (isHovered)
              Positioned(
                left: 0,
                bottom: height + 2,
                child: _buildMapPopupLabel(hoverLabel),
              ),
          ],
        ),
      ),
    );
  }

  /// 同 GID 多台：紧凑并排，与报到设备列表一致
  Widget _buildGidGroupMarker(
    BuildContext context, {
    required List<FacilityPoint> points,
    List<GidMapMemberInfo> members = const [],
    required double markerWidth,
    required double markerHeight,
  }) {
    const overlap = 0.22;
    final showCount = points.length > 2 ? 2 : points.length;
    final showPoints = points.sublist(0, showCount);
    final showMembers =
        members.length > showCount ? members.sublist(0, showCount) : members;
    final unitW = markerWidth * 0.52;
    final totalW = unitW * showPoints.length -
        unitW * overlap * (showPoints.length - 1);

    return SizedBox(
      width: totalW,
      height: markerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < showPoints.length; i++)
            _buildGidGroupMarkerSlot(
              index: i,
              point: showPoints[i],
              member: i < showMembers.length ? showMembers[i] : null,
              gidMembers: members,
              unitW: unitW,
              overlap: overlap,
              markerHeight: markerHeight,
            ),
        ],
      ),
    );
  }

  Positioned _buildGidGroupMarkerSlot({
    required int index,
    required FacilityPoint point,
    GidMapMemberInfo? member,
    required List<GidMapMemberInfo> gidMembers,
    required double unitW,
    required double overlap,
    required double markerHeight,
  }) {
    final role = _roleLabelForFacility(point, index, member: member);
    final hoverKey = _markerSelectionKey(
      point,
      member: member,
      indexInGroup: index,
    );
    return Positioned(
      left: index * unitW * (1 - overlap),
      top: 0,
      bottom: 0,
      width: unitW,
      child: _wrapMapMarkerHoverTarget(
        point: point,
        lookupKey: member?.statusLookupKey,
        gidMembers: gidMembers.length > 1 ? gidMembers : const [],
        hoverKey: hoverKey,
        width: unitW,
        height: markerHeight,
        child: _buildFacilityMarkerVisual(
          point: point,
          markerWidth: unitW,
          markerHeight: markerHeight,
          roleLabel: role,
          status: _resolveStatusForMember(point, member),
          isPort1030: _resolvePortForMember(widget.port1030Map, point, member),
          isPort8084: _resolvePortForMember(widget.port8084Map, point, member),
        ),
      ),
    );
  }

  Widget _buildFacilityMarkerVisual({
    required FacilityPoint point,
    required double markerWidth,
    required double markerHeight,
    String? roleLabel,
    String? status,
    bool? isPort1030,
    bool? isPort8084,
  }) {
    final resolvedStatus =
        status ?? _resolveStatus(widget.deviceStatusMap, point) ?? '空闲';
    final port1030 = isPort1030 ?? _resolvePort(widget.port1030Map, point);
    final port8084 = isPort8084 ?? _resolvePort(widget.port8084Map, point);
    final processType = _resolveMapProcessType(
      point,
      isPort1030: port1030,
      isPort8084: port8084,
    );

    return AttendDeviceMapMarker(
      width: markerWidth,
      height: markerHeight,
      status: resolvedStatus,
      processType: processType,
      roleLabel: roleLabel,
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
    String? status,
    bool isPort1030 = false,
    bool isPort8084 = false,
    double markerWidth = 20,
    double markerHeight = 20,
  }) {
    final double effectiveWidth =
        markerWidth > 0 ? markerWidth : 20.0;
    final double effectiveHeight =
        markerHeight > 0 ? markerHeight : (isPort8084 ? 40.0 : 20.0);
    final resolvedStatus =
        status ?? _resolveStatus(widget.deviceStatusMap, point) ?? '空闲';
    final processType = _resolveMapProcessType(
      point,
      isPort1030: isPort1030,
      isPort8084: isPort8084,
    );

    final visual = AttendDeviceMapMarker(
      width: effectiveWidth,
      height: effectiveHeight,
      status: resolvedStatus,
      processType: processType,
    );

    return _wrapMapMarkerHoverTarget(
      point: point,
      hoverKey: _markerSelectionKey(point),
      width: effectiveWidth,
      height: effectiveHeight,
      child: visual,
    );
  }

}


