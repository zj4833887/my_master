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
  final String ip;

  const FacilityPoint({
    required this.facilityId,
    required this.facilityType,
    required this.x,
    required this.y,
    required this.cameraUri,
    required this.ip,
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
      ip: json['IP']?.toString() ?? '',
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

// 解码后端返回的 Base64 底图，容错常见格式问题
Uint8List? _decodeBase64Image(dynamic raw) {
  if (raw == null) return null;
  var bgImg = raw.toString();
  if (bgImg.isEmpty) return null;

  // 移除 data:image/png;base64, 之类的前缀
  bgImg = bgImg.replaceFirst(RegExp(r'^data:image/[^;]+;base64,'), '');
  // 去掉空白字符
  bgImg = bgImg.replaceAll(RegExp(r'\\s+'), '');
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

    final bgBytes = _decodeBase64Image(json['BgImg']);

    // 兼容多种字段名，并进行 trim，避免空字符串导致 AssetImage('')
    final backendBgPath = (json['BgImgUrl'] ??
            json['BgImgPath'] ??
            json['BgPath'] ??
            json['ImgUrl'] ??
            json['ImgPath'] ??
            json['Img'])
        ?.toString()
        .trim();

    final resolvedBgPath = backendBgPath != null && backendBgPath.isNotEmpty
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

class DeviceMapWidget extends StatefulWidget {
  const DeviceMapWidget({
    super.key,
    this.onCabinetTap,
    this.selectedGateName,
    this.routeMap,
    this.deviceStatusMap, // 设备状态映射：facilityId -> status
    this.port1030Map, // 设备是否 1030 端口：facilityId -> true/false
    this.port8084Map, // 设备是否 8084 端口：facilityId -> true/false
  });

  final Function(String)? onCabinetTap; // 点击机柜/设备的回调
  final String? selectedGateName; // 当前选中的设备/门名称
  final FacilityRouteMap? routeMap; // 路由与点位数据
  final Map<String, String>? deviceStatusMap; // 设备状态映射：facilityId -> status (空闲/报到/工作/重报)
  final Map<String, bool>? port1030Map; // 设备是否 1030 端口：facilityId -> true/false
  final Map<String, bool>? port8084Map; // 设备是否 8084 端口：facilityId -> true/false

  @override
  State<DeviceMapWidget> createState() => _DeviceMapWidgetState();
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
                            ...facilities.map((f) {
                              final status = _resolveStatus(widget.deviceStatusMap, f);
                              final isPort1030 = _resolvePort(widget.port1030Map, f);
                              final isPort8084 = _resolvePort(widget.port8084Map, f);
                              final markerWidth = 20.0;
                              final markerHeight = isPort8084 ? 40.0 : 20.0;
                              final left = renderWidth * f.x - markerWidth / 2;
                              final top = renderHeight * f.y - markerHeight / 2;
                              return Positioned(
                                left: left,
                                top: top,
                                child: _buildFacilityMarker(
                                  context,
                                  point: f,
                                  isSelected: widget.selectedGateName == f.facilityId,
                                  status: status,
                                  isPort1030: isPort1030,
                                  isPort8084: isPort8084,
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
        (point.cameraUri.isNotEmpty ? statusMap[point.cameraUri] : null);
  }

  bool _resolvePort(
    Map<String, bool>? portMap,
    FacilityPoint point,
  ) {
    if (portMap == null) return false;
    return portMap[point.facilityId] ??
        (point.ip.isNotEmpty ? portMap[point.ip] : null) ??
        (point.cameraUri.isNotEmpty ? portMap[point.cameraUri] : null) ??
        false;
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
    const double markerWidth = 20;
    final double effectiveHeight = isPort8084 ? markerHeight : 20;

    return GestureDetector(
      onTap: () => onTap?.call(point.facilityId),
      child: Tooltip(
        message: '${point.facilityId}\n${status ?? '未知状态'}\n${point.cameraUri}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: markerWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: isSelected ? 3 : 1.5,
            ),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              statusImagePath ?? fallbackImage,
              width: markerWidth,
              height: effectiveHeight,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // 如果图片加载失败，显示默认颜色圆圈
                return _buildDefaultMarker(point, isSelected, effectiveHeight);
              },
            ),
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


