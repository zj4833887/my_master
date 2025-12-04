import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

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

  /// 相对坐标：0~1，基于 RouteSettings.canvasSize 映射
  final double x;
  final double y;
  final String cameraUri;

  const FacilityPoint({
    required this.facilityId,
    required this.facilityType,
    required this.x,
    required this.y,
    required this.cameraUri,
  });

  factory FacilityPoint.fromBackend(
    Map<String, dynamic> json,
    double canvasWidth,
    double canvasHeight,
  ) {
    final type = _facilityTypeFromString(
      json['FacilityType'] ?? json['facilityType'],
    );

    final rawX = _asDouble(json['X'] ?? json['x'], canvasWidth / 2);
    final rawY = _asDouble(json['Y'] ?? json['y'], canvasHeight / 2);

    final relativeX = canvasWidth == 0 ? 0.5 : rawX / canvasWidth;
    final relativeY = canvasHeight == 0 ? 0.5 : rawY / canvasHeight;

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
    );
  }

  static double _clamp01(double value) =>
      value.clamp(0.0, 1.0); // ignore: avoid_dynamic_calls

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

/// RouteSettings 中的配置：底图 + 尺寸 + 点位
class FacilityRouteSettings {
  final String imgName;
  final Size canvasSize;
  final String bgPath;
  final Uint8List? bgBytes;
  final List<FacilityPoint> facilities;

  const FacilityRouteSettings({
    required this.imgName,
    required this.canvasSize,
    required this.bgPath,
    this.bgBytes,
    required this.facilities,
  });

  factory FacilityRouteSettings.fromBackend(Map<String, dynamic> json) {
    final canvasSize =
        json['CanvasSize'] as List<dynamic>? ?? const <dynamic>[1920, 1080];
    final canvasWidth =
        canvasSize.isNotEmpty ? _asDouble(canvasSize[0], 1920) : 1920.0;
    final canvasHeight =
        canvasSize.length > 1 ? _asDouble(canvasSize[1], 1080) : 1080.0;

    final facilitiesJson = json['Devices'] as List<dynamic>? ?? const [];
    final facilities = facilitiesJson
        .whereType<Map<String, dynamic>>()
        .map(
          (deviceJson) =>
              FacilityPoint.fromBackend(deviceJson, canvasWidth, canvasHeight),
        )
        .toList();

    Uint8List? bgBytes;
    final bgImg = json['BgImg']?.toString() ?? '';
    if (bgImg.isNotEmpty) {
      try {
        bgBytes = base64Decode(bgImg);
      } catch (_) {
        bgBytes = null;
      }
    }

    final backendBgPath = json['BgImgUrl']?.toString() ??
        json['BgImgPath']?.toString() ??
        json['ImgUrl']?.toString() ??
        json['ImgPath']?.toString() ??
        '';

    final resolvedBgPath = backendBgPath.isNotEmpty
        ? backendBgPath
        : 'assets/images/device_map.png';

    return FacilityRouteSettings(
      imgName: json['ImgName']?.toString() ?? '会议场地',
      canvasSize: Size(canvasWidth, canvasHeight),
      // 后端可返回 base64 或 URL，URL 兜底为本地图片
      bgPath: resolvedBgPath,
      bgBytes: bgBytes,
      facilities: facilities.isEmpty
          ? FacilityRouteMap.demo().settings.facilities
          : facilities,
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
          ),
          FacilityPoint(
            facilityId: '南门-2',
            facilityType: FacilityType.floorDevice,
            x: 0.10,
            y: 0.50,
            cameraUri: 'rtsp://south-2',
          ),
          FacilityPoint(
            facilityId: '南门-3',
            facilityType: FacilityType.floorDevice,
            x: 0.08,
            y: 0.65,
            cameraUri: 'rtsp://south-3',
          ),
          // 东门（下边）9 台设备
          FacilityPoint(
            facilityId: '东门-1',
            facilityType: FacilityType.terminal,
            x: 0.20,
            y: 0.92,
            cameraUri: 'rtsp://east-1',
          ),
          FacilityPoint(
            facilityId: '东门-2',
            facilityType: FacilityType.terminal,
            x: 0.30,
            y: 0.93,
            cameraUri: 'rtsp://east-2',
          ),
          FacilityPoint(
            facilityId: '东门-3',
            facilityType: FacilityType.terminal,
            x: 0.40,
            y: 0.94,
            cameraUri: 'rtsp://east-3',
          ),
          FacilityPoint(
            facilityId: '东门-4',
            facilityType: FacilityType.terminal,
            x: 0.50,
            y: 0.95,
            cameraUri: 'rtsp://east-4',
          ),
          FacilityPoint(
            facilityId: '东门-5',
            facilityType: FacilityType.terminal,
            x: 0.60,
            y: 0.94,
            cameraUri: 'rtsp://east-5',
          ),
          FacilityPoint(
            facilityId: '东门-6',
            facilityType: FacilityType.terminal,
            x: 0.70,
            y: 0.93,
            cameraUri: 'rtsp://east-6',
          ),
          FacilityPoint(
            facilityId: '东门-7',
            facilityType: FacilityType.terminal,
            x: 0.80,
            y: 0.92,
            cameraUri: 'rtsp://east-7',
          ),
          FacilityPoint(
            facilityId: '东门-8',
            facilityType: FacilityType.terminal,
            x: 0.32,
            y: 0.88,
            cameraUri: 'rtsp://east-8',
          ),
          FacilityPoint(
            facilityId: '东门-9',
            facilityType: FacilityType.terminal,
            x: 0.68,
            y: 0.88,
            cameraUri: 'rtsp://east-9',
          ),
          // 北门（右边）4 台设备
          FacilityPoint(
            facilityId: '北门-1',
            facilityType: FacilityType.cabinet,
            x: 0.92,
            y: 0.30,
            cameraUri: 'rtsp://north-1',
          ),
          FacilityPoint(
            facilityId: '北门-2',
            facilityType: FacilityType.cabinet,
            x: 0.90,
            y: 0.45,
            cameraUri: 'rtsp://north-2',
          ),
          FacilityPoint(
            facilityId: '北门-3',
            facilityType: FacilityType.cabinet,
            x: 0.92,
            y: 0.60,
            cameraUri: 'rtsp://north-3',
          ),
          FacilityPoint(
            facilityId: '北门-4',
            facilityType: FacilityType.cabinet,
            x: 0.88,
            y: 0.75,
            cameraUri: 'rtsp://north-4',
          ),
          // 西门（上边）5 台设备
          FacilityPoint(
            facilityId: '西门-1',
            facilityType: FacilityType.master,
            x: 0.25,
            y: 0.08,
            cameraUri: 'rtsp://west-1',
          ),
          FacilityPoint(
            facilityId: '西门-2',
            facilityType: FacilityType.master,
            x: 0.40,
            y: 0.07,
            cameraUri: 'rtsp://west-2',
          ),
          FacilityPoint(
            facilityId: '西门-3',
            facilityType: FacilityType.master,
            x: 0.55,
            y: 0.06,
            cameraUri: 'rtsp://west-3',
          ),
          FacilityPoint(
            facilityId: '西门-4',
            facilityType: FacilityType.master,
            x: 0.70,
            y: 0.07,
            cameraUri: 'rtsp://west-4',
          ),
          FacilityPoint(
            facilityId: '西门-5',
            facilityType: FacilityType.master,
            x: 0.85,
            y: 0.08,
            cameraUri: 'rtsp://west-5',
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
        map.containsKey('ImgName');
  }
}

class DeviceMapWidget extends StatelessWidget {
  const DeviceMapWidget({
    super.key,
    this.onCabinetTap,
    this.selectedGateName,
    this.routeMap,
  });

  final Function(String)? onCabinetTap; // 点击机柜/设备的回调
  final String? selectedGateName; // 当前选中的设备/门名称
  final FacilityRouteMap? routeMap; // 路由与点位数据

  FacilityRouteMap get _effectiveRouteMap =>
      routeMap ?? FacilityRouteMap.demo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // 设备分布图
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final settings = _effectiveRouteMap.settings;
                final facilities = settings.facilities.isEmpty
                    ? FacilityRouteMap.demo().settings.facilities
                    : settings.facilities;
                final baseWidth =
                    settings.canvasSize.width == 0 ? 1920 : settings.canvasSize.width;
                final baseHeight =
                    settings.canvasSize.height == 0 ? 1080 : settings.canvasSize.height;

                final scale = math.min(
                  constraints.maxWidth / baseWidth,
                  constraints.maxHeight / baseHeight,
                );

                final effectiveScale =
                    (scale.isFinite && scale > 0 ? scale : 1.0).toDouble();
                final renderWidth = (baseWidth * effectiveScale).toDouble();
                final renderHeight = (baseHeight * effectiveScale).toDouble();

                return Center(
                  child: ClipRect(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 3.5,
                      boundaryMargin: const EdgeInsets.all(160),
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
                                    image: _buildBgImage(settings),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            ...facilities.map((f) {
                              final left = renderWidth * f.x;
                              final top = renderHeight * f.y;
                              return Positioned(
                                left: left - 12,
                                top: top - 12,
                                child: _buildFacilityMarker(
                                  context,
                                  point: f,
                                  isSelected: selectedGateName == f.facilityId,
                                  onTap: onCabinetTap,
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

  ImageProvider<Object> _buildBgImage(FacilityRouteSettings settings) {
    final bytes = settings.bgBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return MemoryImage(bytes);
    }
    final path = settings.bgPath;
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
    Function(String)? onTap,
  }) {
    final color = _facilityColor(point.facilityType);
    return GestureDetector(
      onTap: () => onTap?.call(point.facilityId),
      child: Tooltip(
        message: '${point.facilityId}\n${point.cameraUri}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 26 : 20,
          height: isSelected ? 26 : 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.black26,
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.7),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              point.facilityId,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 不同类型设备对应不同颜色
  static Color _facilityColor(FacilityType type) {
    switch (type) {
      case FacilityType.cabinet:
        return Colors.blue.shade400;
      case FacilityType.floorDevice:
        return Colors.green.shade400;
      case FacilityType.terminal:
        return Colors.orange.shade400;
      case FacilityType.master:
        return Colors.purple.shade400;
    }
  }
}


