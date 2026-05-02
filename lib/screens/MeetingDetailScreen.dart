import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_html/flutter_html.dart';
import '../utils/app_log.dart';
import '../utils/station_stat_lookup.dart';
import '../scc/scc_client.dart';
import '../scc/board.dart';
import '../widgets/device_map_widget.dart';
import '../widgets/mixed_font_text.dart';
import '../utils/hex_color.dart';
import '../utils/local_exit_api.dart';
import '../utils/show_exit_confirm_dialog.dart';

class _ProgressStepInfo {
  final String title;
  final int step;
  final bool executed;

  const _ProgressStepInfo({
    required this.title,
    required this.step,
    required this.executed,
  });

  _ProgressStepInfo copyWith({
    String? title,
    int? step,
    bool? executed,
  }) {
    return _ProgressStepInfo(
      title: title ?? this.title,
      step: step ?? this.step,
      executed: executed ?? this.executed,
    );
  }
}

const List<_ProgressStepInfo> _kDefaultProgressSteps = [
  _ProgressStepInfo(title: '需求分析', step: 1, executed: false),
  _ProgressStepInfo(title: '方案设计', step: 2, executed: false),
  _ProgressStepInfo(title: '开发实施', step: 3, executed: false),
  _ProgressStepInfo(title: '测试验证', step: 4, executed: false),
  _ProgressStepInfo(title: '上线部署', step: 5, executed: false),
];

class MeetingDetailScreen extends StatefulWidget {
  final String meetingName;
  final String? meetId;

  MeetingDetailScreen({required this.meetingName, this.meetId});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMeetingManagementSelected = true;

  // 统计数据 - 从 NormalData 获取
  Map<String, int> attendStats = {
    '应到': 0,
    '实到': 0,
    '未到': 0,
    '请假': 0,
    '实缺': 0,
  };
  Map<String, int> guestStats = {
    '应到': 0,
    '实到': 0,
    '未到': 0,
    '请假': 0,
    '实缺': 0,
  };

  // 会议名称 - 从 NormalData 获取
  String _meetingTitle = '';
  String get _meetingTitleDisplay {
    final title = _meetingTitle.isNotEmpty ? _meetingTitle : widget.meetingName;
    return title.replaceAll('@', '-');
  }

  // 会议状态
  int _meetStatus = 0; // 0=未开启, 1=进行中, 2=结束
  
  // 会议是否已开始（用于控制按钮显示）
  bool _isMeetingStarted = false;

  // 客户端列表
  List<Map<String, dynamic>> _clientList = [];

  // 站点统计：WS_StationNum 的 `Station` 字段为 key；与客户端 IP/站名 的匹配见 [lookupStationStatRow]
  Map<String, Map<String, int>> _stationStats = {};

  // MetricBoard 实例
  final MetricBoard _metricBoard = MetricBoard();

  // 订阅流
  StreamSubscription? _metricsSubscription;

  // 设备数据（从客户端列表生成）
  List<Map<String, dynamic>> _devices = [];
  Map<String, int> _lastWsClientOrderByDevice = {};
  static const bool _kLogWsClientOrderDiff = false;

  // 调试：打印设备排序（用于定位“乱跳”）
  static const bool _kLogDeviceOrder = false;

  // 数据检查相关
  Timer? _dataCheckTimer;
  List<Map<String, dynamic>> _dataCheckResults = [];
  List<String> _selectedDataCheckTables = [];
  Timer? _usbAutoImportTimer;
  bool _isUsbAutoImporting = false;
  Set<String> _knownUsbRoots = {};
  String? _lastUsbAutoImportError;

  // 加载状态
  bool _isLoading = false;
  bool _isFileImporting = false;

  // 会议开始/结束操作序号：用于丢弃过期异步返回，避免提示与状态不一致
  int _meetingActionSeq = 0;

  // 通知信息（右侧卡片）
  String _notificationText = '';

  // 调试：输出 gRPC 推送原始数据（不受 AppLog.enabled 限制）
  static const bool _kLogGrpcPush = false;

  /// 调试「出席/列席」人数：改为 true 后在 Debug 控制台输出 WS_StationNum 与匹配结果（使用 dart `developer.log`）
  static const bool _kLogStationNumAttend = false;

  String get _defaultMeetingStatusText {
    switch (_meetStatus) {
      case 1:
        return '会议正在进行';
      case 2:
        return '会议已经结束';
      case 0:
      default:
        return '会议暂未开始';
    }
  }

  // 显示管理（会标/报到情况/标语）状态与数据
  String _displayManagementType = '标语';
  bool _isDisplayLoading = false;
  List<dynamic> _sloganTableData = [];
  List<dynamic> _sloganBannerItems = [];
  List<dynamic> _sloganCheckInItems = [];
  bool _showSloganTable = false;
  dynamic _pendingQuickDisplayItem;
  String _pendingQuickDisplayType = '';
  final Set<int> _sloganPreviewedRowIndices = {};
  bool _isSendingSlogan = false;
  bool _isSloganPreviewVisible = false;
  String _sloganPreviewText = '';
  String _sloganPreviewTemplate = '';
  String _sloganPreviewResolvedHtml = '';
  bool _sloganPreviewFreeze = false;
  Widget? _frozenSloganPreviewWidget;
  final ScrollController _sloganTableScrollController = ScrollController();
  Timer? _sloganPreviewTimer;
  Color _sloganPreviewBackground = Colors.white;

  // 设备点位数据（单独的 notifier，避免其他 setState 影响底图）
  final ValueNotifier<FacilityRouteMap?> _routeMapNotifier =
      ValueNotifier<FacilityRouteMap?>(FacilityRouteMap.demo());
  final ValueNotifier<String?> _selectedFacilityIdNotifier =
      ValueNotifier<String?>(null);
  String? _lastRouteMapSignature; // 避免相同数据重复刷新造成闪烁

  // 步骤进度状态
  bool _isStepLoading = false;
  bool _isStepUpdating = false;
  List<_ProgressStepInfo> _progressSteps =
      List<_ProgressStepInfo>.from(_kDefaultProgressSteps);
  int _completedStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _meetingTitle = widget.meetingName;
    _initializeData();
    _startUsbAutoImportWatcher();
    // 页面初始化后默认拉取“标语”（等首帧渲染完，确保 ScaffoldMessenger 可用）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDisplayManagementData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _routeMapNotifier.dispose();
    _selectedFacilityIdNotifier.dispose();
    _sloganTableScrollController.dispose();
    _metricsSubscription?.cancel();
    _dataCheckTimer?.cancel();
    _usbAutoImportTimer?.cancel();
    _sloganPreviewTimer?.cancel();
    super.dispose();
  }

  void _startUsbAutoImportWatcher() {
    if (!Platform.isWindows && !Platform.isLinux) {
      return;
    }
    _usbAutoImportTimer?.cancel();
    _usbAutoImportTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _scanAndImportUsbTxtFiles(),
    );
    Future<void>.microtask(_scanAndImportUsbTxtFiles);
  }

  Future<void> _scanAndImportUsbTxtFiles() async {
    if (!mounted || _isUsbAutoImporting) {
      return;
    }
    _isUsbAutoImporting = true;
    try {
      final currentRoots = await _discoverUsbRoots();
      final newRoots =
          currentRoots.where((root) => !_knownUsbRoots.contains(root)).toList();
      _knownUsbRoots = currentRoots.toSet();
      for (final root in newRoots) {
        await _importTxtFilesFromUsbRoot(root);
      }
    } catch (e) {
      _reportUsbAutoImportError('U盘扫描失败: $e');
    } finally {
      _isUsbAutoImporting = false;
    }
  }

  void _reportUsbAutoImportError(String message) {
    if (_lastUsbAutoImportError == message) {
      return;
    }
    _lastUsbAutoImportError = message;
    AppLog.d(message, tag: 'USB Auto Import');
    if (mounted) {
      _showMessage(message, isError: true);
    }
  }

  Future<List<String>> _discoverUsbRoots() async {
    if (Platform.isWindows) {
      return _discoverWindowsUsbRoots();
    }
    if (Platform.isLinux) {
      return _discoverLinuxUsbRoots();
    }
    return <String>[];
  }

  Future<List<String>> _discoverWindowsUsbRoots() async {
    final roots = <String>{};
    Future<void> parseDriveText(String text) async {
      final lines = text.split('\n');
      for (final rawLine in lines) {
        final line = rawLine.trim();
        final match = RegExp(r'^([A-Za-z]):').firstMatch(line);
        if (match == null) continue;
        final drive = '${match.group(1)}:\\';
        if (await Directory(drive).exists()) {
          roots.add(drive);
        }
      }
    }

    try {
      final wmic = await Process.run(
        'wmic',
        <String>['logicaldisk', 'where', 'DriveType=2', 'get', 'DeviceID'],
      );
      if (wmic.exitCode == 0) {
        await parseDriveText((wmic.stdout ?? '').toString());
      }
    } catch (_) {
      // Ignore and try PowerShell fallback.
    }

    if (roots.isEmpty) {
      try {
        final ps = await Process.run(
          'powershell',
          <String>[
            '-NoProfile',
            '-Command',
            "Get-CimInstance Win32_LogicalDisk | Where-Object {\$_.DriveType -eq 2} | Select-Object -ExpandProperty DeviceID",
          ],
        );
        if (ps.exitCode == 0) {
          await parseDriveText((ps.stdout ?? '').toString());
        }
      } catch (_) {
        // Ignore fallback failures.
      }
    }

    final result = roots.toList()..sort();
    return result;
  }

  Future<List<String>> _discoverLinuxUsbRoots() async {
    final roots = <String>{};
    final user = Platform.environment['USER'] ?? '';
    final baseDirs = <String>[
      if (user.isNotEmpty) '/media/$user',
      if (user.isNotEmpty) '/run/media/$user',
      '/media',
      '/run/media',
    ];

    for (final basePath in baseDirs) {
      final base = Directory(basePath);
      if (!await base.exists()) continue;
      try {
        await for (final entity in base.list(followLinks: false)) {
          if (entity is Directory) {
            roots.add(entity.path);
          }
        }
      } catch (_) {
        // Ignore inaccessible mount roots.
      }
    }

    final result = roots.toList()..sort();
    return result;
  }

  Future<void> _importTxtFilesFromUsbRoot(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return;

    final txtFiles = <File>[];
    try {
      await for (final entity in rootDir.list(followLinks: false)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.txt')) {
          txtFiles.add(entity);
        }
      }
    } catch (_) {
      return;
    }

    if (txtFiles.isEmpty) return;

    final fileWithTime = <MapEntry<File, DateTime>>[];
    for (final file in txtFiles) {
      try {
        final stat = await file.stat();
        fileWithTime.add(MapEntry<File, DateTime>(file, stat.modified));
      } catch (_) {
        // Skip unreadable files.
      }
    }
    fileWithTime.sort((a, b) => b.value.compareTo(a.value));

    for (final entry in fileWithTime) {
      final file = entry.key;
      try {
        final importResult = await _importFileFromPath(file.path);
        if (importResult) {
          // 不改名：允许同一个文件在后续重复被识别导入
        }
      } catch (e) {
        _reportUsbAutoImportError('处理文件失败(${file.path}): $e');
      }
    }
  }

  // 初始化数据
  Future<void> _initializeData() async {
    // 加载客户端列表
    await _loadClientList();
    
    // 如果提供了 meetId，先通过 queryMeetInfo 获取初始数据
    if (widget.meetId != null && widget.meetId!.isNotEmpty) {
      await _loadInitialMeetingInfo();
    }

    // 无论是否有 WS 推送，先尝试通过接口获取一次设备点位图
    await _loadDeviceRouteMap();

    // 加载步骤进度
    await _loadProgressStep();
    
    // 订阅指标数据流
    _subscribeMetrics();
  }

  // 加载初始会议信息
  Future<void> _loadInitialMeetingInfo() async {
    try {
      final result = await SccClientWrapper.queryMeetInfo(widget.meetId!);
      if (result.isSuccess && result.data != null) {
        // 将 queryMeetInfo 返回的数据格式转换为 _handleMeetInfo 能处理的格式
        _handleMeetInfo(result.data!);
      }
    } catch (e) {
      // 错误处理
    }
  }

  Future<void> _loadProgressStep() async {
    if (_isStepLoading) return;
    if (!mounted) return;
    setState(() {
      _isStepLoading = true;
    });
    try {
      final result =
          await SccClientWrapper.queryProgressStep(meetID: widget.meetId);
      if (result.isSuccess && result.data != null) {
        final parsedSteps = _parseProgressSteps(result.data!.payload);
        final effectiveSteps =
            parsedSteps.isNotEmpty ? parsedSteps : _cloneDefaultProgressSteps();
        final currentStepValue = result.data!.step;
        final updatedSteps = effectiveSteps
            .map((step) => step.copyWith(executed: step.executed))
            .toList();
        final matchedIndex =
            updatedSteps.indexWhere((step) => step.step == currentStepValue);
        final lastExecutedIndex =
            updatedSteps.lastIndexWhere((step) => step.executed);
        final serverIndex = updatedSteps.isEmpty
            ? 0
            : (matchedIndex >= 0
                ? matchedIndex
                : (currentStepValue - 1).clamp(0, updatedSteps.length - 1));
        final effectiveCompletedIndex = lastExecutedIndex >= 0
            ? lastExecutedIndex
            : serverIndex.clamp(0, updatedSteps.length - 1);
        if (mounted) {
          setState(() {
            _progressSteps = updatedSteps;
            _completedStepIndex = effectiveCompletedIndex;
          });
        }
      } else if (!result.isSuccess &&
          result.msg.isNotEmpty &&
          mounted) {
        _showMessage(result.msg, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('加载步骤进度失败: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStepLoading = false;
        });
      }
    }
  }

  Future<bool> _updateProgressStep(int newIndex) async {
    if (!mounted) return false;
    if (_isStepUpdating ||
        newIndex < 0 ||
        newIndex >= _progressSteps.length) {
      return false;
    }

    setState(() {
      _isStepUpdating = true;
    });

    try {
      final targetStep = _progressSteps[newIndex].step;
      final result = await SccClientWrapper.setProgressStep(
        step: targetStep,
        meetID: widget.meetId,
      );
      if (result.isSuccess && result.data == true) {
        // 成功后重新拉取，以服务器状态为准
        await _loadProgressStep();
        return true;
      } else {
        final message =
            result.msg.isNotEmpty ? result.msg : '更新步骤失败';
        if (mounted) {
          _showMessage(message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('更新步骤异常: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStepUpdating = false;
        });
      }
    }
    return false;
  }

  Future<void> _loadDeviceRouteMap() async {
    try {
      final result =
          await SccClientWrapper.queryDeviceRouteMap(meetID: widget.meetId);
      if (result.isSuccess && result.data != null) {
        _handleDeviceRouteData(result.data!);
      }
    } catch (_) {
      // 忽略接口异常，等待后续 WS 推送
    }
  }

  /// 按 IP 端口与设施类型推断 ProcessType（与 WS / HTTP 列表一致）。
  /// 地垫为 **:1030**，需优先于 FacilityTypeName；否则后端未标「报到终端」时会误为 Client（计算机图标）。
  void _applyProcessTypeForClientList(Map<String, dynamic> client) {
    final facilityType = client['FacilityTypeName']?.toString() ?? '';
    final ip = client['IP']?.toString() ?? '';
    if (ip.contains(':1030') || ip.endsWith('1030')) {
      client['ProcessType'] = 'didian';
      return;
    }
    if (facilityType == '报到终端') {
      client['ProcessType'] = 'rack';
    } else {
      client['ProcessType'] = 'Client';
    }
  }

  // 加载客户端列表
  Future<void> _loadClientList() async {
    try {
      final result = await SccClientWrapper.queryClient();
      if (result.isSuccess && result.data != null) {
        setState(() {
          _clientList = (result.data as List).map((item) {
            final client = Map<String, dynamic>.from(item);
            // 根据 ClientStatus 设置 disabled
            if (client['ClientStatus'] == 0 || client['ClientStatus'] == 4) {
              client['disabled'] = true;
            } else {
              client['disabled'] = false;
            }
            
            _applyProcessTypeForClientList(client);

            return client;
          }).toList();
          
          // 生成设备列表用于显示
          _updateDevicesList();
        });
      }
    } catch (e) {
      // 错误处理
    }
  }

  // 订阅指标数据流
  void _subscribeMetrics() {
    _metricsSubscription = SccClientWrapper.subscribeMetricsData(
      metricBoard: _metricBoard,
      onData: (Map<String, dynamic> data, String channel) {
        final remark = data['remark']?.toString() ?? '';
        if (_kLogGrpcPush) {
          _logGrpcPushPayload(channel: channel, remark: remark, data: data);
        }
        final bool looksLikeMeetInfo = channel == 'WS_MeetInfo' ||
            channel.isEmpty ||
            data.containsKey('Personnum') ||
            (data['data'] is Map &&
                (data['data'] as Map).containsKey('Personnum'));

        final bool looksLikeCheckIn = channel == 'WS_CheckInInfo' ||
            (data.containsKey('code') &&
                data['data'] is Map &&
                ((data['data'] as Map).containsKey('CheckInSatus') ||
                    (data['data'] as Map).containsKey('NodeID')));

        // 设备点位图：优先根据 channel 判断，其次再兜底看字段
        final bool looksLikeDeviceRoute =
            channel == 'DeviceRouteMap' ||
            remark.contains('DeviceRoute') ||
            remark.contains('RouteMap') ||
            data.containsKey('RouteID') ||
            (data['data'] is Map &&
                ((data['data'] as Map).containsKey('RouteID') ||
                    (data['data'] as Map).containsKey('RouteMapSettings')));

        if (channel == 'WS_Client') {
          _handleWsClient(data);
        } else if (channel == 'WS_StationNum') {
          _handleWsStationNum(data);
        } else if (looksLikeCheckIn) {
          _logPayloadKeysBrief('CheckIn', channel, remark, data);
          _handleCheckInInfo(data);
        } else if (looksLikeDeviceRoute) {
          // 仅当 channel 确认是 DeviceRouteMap 时更新底图，其他推送不触发刷新
          if (channel == 'DeviceRouteMap') {
            AppLog.d(
              'received at ${DateTime.now().toIso8601String()}',
              tag: 'DeviceRouteMap',
            );
            _logPayloadKeysBrief('DeviceRouteMap', channel, remark, data);
            _handleDeviceRouteData(data);
          } else {
            // 忽略非 DeviceRouteMap 频道的“像点位图”的数据，避免闪烁
          }
        } else if (looksLikeMeetInfo) {
          _handleMeetInfo(data);
        }
      },
      onError: (String error) {
        // 错误处理
      },
    );
  }

  // 处理会议信息 (WS_MeetInfo)
  void _handleMeetInfo(Map<String, dynamic> data) {
    setState(() {
      // 获取嵌套的数据结构 data.data
      final dataData = data['data'] as Map<String, dynamic>?;

      // 获取会议状态
      if (dataData != null) {
        final serverStatus = dataData['serverStatus'] as Map<String, dynamic>?;
        if (serverStatus != null) {
          _meetStatus = _parseInt(serverStatus['Meetstatus'] ?? 0);
          
          // 根据会议状态更新标题显示和按钮状态
          switch (_meetStatus) {
            case 0:
              _meetingTitle = '会议暂未开始';
              _isMeetingStarted = false;
              break;
            case 1:
              _meetingTitle = '会议正在进行';
              _isMeetingStarted = true;
              break;
            case 2:
              _meetingTitle = '会议已经结束';
              _isMeetingStarted = false;
              break;
            default:
              _meetingTitle = widget.meetingName;
          }
        }

        // 获取会议名称（优先使用 onMeet.Content）
        final onMeet = dataData['onMeet'] as Map<String, dynamic>?;
        if (onMeet != null && onMeet['Content'] != null) {
          final content = onMeet['Content'].toString();
          if (content.isNotEmpty) {
            _meetingTitle = content;
          }
        }

        // 获取服务器连接状态
        final serverConnect = _parseInt(dataData['serverConnect'] ?? 0);
        if (serverConnect == 1) {
          // 如果服务器连接，更新所有客户端状态
          for (int i = 0; i < _clientList.length; i++) {
            _clientList[i]['PassDoorStatus'] = -2;
            _clientList[i]['ClientStatus'] = 4;
          }
          _updateDevicesList();
        }
      }

      // 获取会议名称（兼容其他格式）
      if (_meetingTitle.isEmpty || _meetingTitle == widget.meetingName) {
        if (data['Name'] != null) {
          _meetingTitle = data['Name'].toString();
        } else if (data['title'] != null) {
          _meetingTitle = data['title'].toString();
        }
      }

      // 获取统计数据 - 支持多种数据格式
      Map<String, dynamic>? nums;
      
      // 方式1: 尝试从 data.data.nums 获取（WebSocket WS_MeetInfo 格式）
      if (dataData != null) {
        nums = dataData['nums'] as Map<String, dynamic>?;
        
        // 方式2: 如果不存在，尝试从 data.data 顶层获取
        if (nums == null || nums.isEmpty) {
          if (dataData.containsKey('Personnum') || dataData.containsKey('Personattendancenum')) {
            nums = dataData;
          }
        }
      }
      
      // 方式3: 如果还是不存在，尝试从 data 顶层获取（兼容 queryMeetInfo 返回格式）
      if (nums == null || nums.isEmpty) {
        if (data.containsKey('Personnum') || data.containsKey('Personattendancenum')) {
          nums = data;
        }
      }
      
      if (nums != null && nums.isNotEmpty) {
        // 出席统计数据
        final personnum = _nonNegativeInt(nums['Personnum'] ?? 0);
        final personattendancenum = _nonNegativeInt(nums['Personattendancenum'] ?? 0);
        final personleavenum = _nonNegativeInt(nums['Personleavenum'] ?? 0);
        final notyet = math.max(0, personnum - personattendancenum); // 未到

        // 创建新的 Map 以确保 setState 能检测到变化
        attendStats = {
          '应到': personnum,
          '实到': personattendancenum,
          '未到': notyet,
          '请假': personleavenum,
          '实缺': math.max(0, notyet - personleavenum),
        };

        // 列席统计数据
        final specialnum = _nonNegativeInt(nums['Specialnum'] ?? 0);
        final specialnattendancenum =
            _nonNegativeInt(nums['Specialnattendancenum'] ?? 0);
        final specialleavenum = _nonNegativeInt(nums['Specialleavenum'] ?? 0);
        final specialNotyet = math.max(0, specialnum - specialnattendancenum); // 列席未到

        // 创建新的 Map 以确保 setState 能检测到变化
        guestStats = {
          '应到': specialnum,
          '实到': specialnattendancenum,
          '未到': specialNotyet,
          '请假': specialleavenum,
          '实缺': math.max(0, specialNotyet - specialleavenum),
        };

        // 其他接口日志已关闭，仅保留标语接口日志
      }

      // 动态模板预览：仅在模板内容确实变化时更新，图片类标语会被冻结不更新
      _updateSloganPreviewIfNeeded();
    });
  }

  // 处理报到信息 (WS_CheckInInfo)
  void _handleCheckInInfo(Map<String, dynamic> data) {
    if (data['code'] != 200) return;

    final nodeID = data['data']?['NodeID'];
    final checkInStatus = data['data']?['CheckInSatus'];

    if (nodeID == null || checkInStatus == null) return;

    setState(() {
      // 更新客户端列表中对应节点的状态
      for (int i = 0; i < _clientList.length; i++) {
        if (_clientList[i]['NodeID'] == nodeID) {
          // 如果 ClientStatus 不是 4，则根据 CheckInSatus 更新
          if (_clientList[i]['ClientStatus'] != 4) {
            if (checkInStatus == 2) {
              _clientList[i]['ClientStatus'] = -3;
            } else if (checkInStatus == 1) {
              _clientList[i]['ClientStatus'] = -2;
            } else if (checkInStatus == 3) {
              _clientList[i]['ClientStatus'] = 3;
            } else if (checkInStatus == 4 || checkInStatus == 5) {
              _clientList[i]['ClientStatus'] = 5;
            }
          }
          break;
        }
      }
      
      // 更新设备列表
      _updateDevicesList();
    });
  }

  // 处理 WS_Client：完整设备列表与当前状态
  void _handleWsClient(Map<String, dynamic> data) {
    if (data['code'] != 200) return;
    final list = data['data'];
    if (list is! List) return;

    _logWsClientOrderDiffIfChanged(list);

    setState(() {
      _clientList = list.map<Map<String, dynamic>>((item) {
        final client = Map<String, dynamic>.from(item as Map);

        // 根据 ClientStatus 设置 disabled
        final status = client['ClientStatus'];
        client['disabled'] = (status == 0 || status == 4);

        _applyProcessTypeForClientList(client);

        return client;
      }).toList();

      _updateDevicesList();
      
      // 如果正在轮询检查状态，更新检查结果
      if (_dataCheckTimer != null && _dataCheckTimer!.isActive) {
        _updateDataCheckResults();
      }
    });
  }

  void _logWsClientOrderDiffIfChanged(List<dynamic> list) {
    if (!_kLogWsClientOrderDiff) {
      return;
    }
    final current = <String, int>{};
    for (final item in list) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final key = (map['IP']?.toString().trim().isNotEmpty ?? false)
          ? map['IP'].toString().trim()
          : (map['NodeID']?.toString().trim().isNotEmpty ?? false)
              ? map['NodeID'].toString().trim()
              : map['Name']?.toString().trim() ?? '';
      if (key.isEmpty) continue;
      current[key] = _parseInt(map['Order'] ?? 0);
    }

    if (_lastWsClientOrderByDevice.isNotEmpty) {
      final changed = <String>[];
      for (final entry in current.entries) {
        final old = _lastWsClientOrderByDevice[entry.key];
        if (old != null && old != entry.value) {
          changed.add('${entry.key}: $old -> ${entry.value}');
        }
      }
      if (changed.isNotEmpty) {
        AppLog.d('OrderChanged: ${changed.join(' ; ')}', tag: 'WS_Client');
      }
    }

    _lastWsClientOrderByDevice = current;
  }

  // 更新数据检查结果（从 _clientList 中提取）
  void _updateDataCheckResults() {
    final checkingDevices = _clientList.where((client) {
      final status = client['DataCheckStatus'];
      return status != null && status != 0;
    }).toList();
    
    setState(() {
      _dataCheckResults.clear();
      for (var device in checkingDevices) {
        final remark = device['Remark']?.toString() ?? '';
        if (remark.isNotEmpty) {
          try {
            final remarkData = jsonDecode(remark) as Map<String, dynamic>;
            remarkData['StationName'] = device['StationName'] ?? device['IP'] ?? '';
            _dataCheckResults.add(remarkData);
          } catch (e) {
            // 解析失败，跳过
          }
        }
      }
    });
    
    // 检查是否所有设备都已完成检查（DataCheckStatus !== 1）
    final allCompleted = checkingDevices.isEmpty || checkingDevices.every((device) {
      final status = device['DataCheckStatus'];
      return status != null && status != 1;
    });
    
    if (allCompleted && _dataCheckTimer != null && _dataCheckTimer!.isActive) {
      _dataCheckTimer?.cancel();
      _dataCheckTimer = null;
      _showDataCheckFinalResults();
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 处理 WS_StationNum：每个站点的出席/列席人数
  void _handleWsStationNum(Map<String, dynamic> data) {
    if (data['code'] != 200) return;
    final list = data['data'];
    if (list is! List) return;

    final Map<String, Map<String, int>> stats = {};
    for (final item in list) {
      if (item is! Map) continue;
      final station = item['Station']?.toString();
      if (station == null || station.isEmpty) continue;

      final attend = _parseInt(item['AttendNum'] ?? 0);
      final guest = _parseInt(item['SpecialNum'] ?? 0);
      stats[station] = {
        'attend': attend,
        'guest': guest,
      };
    }

    if (stats.isEmpty) return;

    if (_kLogStationNumAttend) {
      final keys = stats.keys.toList();
      final sample = list.take(5).map((e) => e.toString()).join(' | ');
      developer.log(
        'WS_StationNum entries=${list.length} statKeys=${keys.length} '
        'keys=${keys.take(12).join(",")}${keys.length > 12 ? "..." : ""} sample=$sample',
        name: 'StationNum',
      );
    }

    setState(() {
      _stationStats = stats;
      _updateDevicesList();
    });
  }

  // 更新设备列表
  void _updateDevicesList() {
    final nextDevices = _clientList.map((client) {
      final processType = client['ProcessType'] ?? 'Server';
      final clientStatus = client['ClientStatus'] ?? 0;
      final ip = client['IP']?.toString() ?? '';
      final facilityId = client['FacilityID'] ?? client['facilityId'];
      final stationName = client['StationName'] ?? '';
      final order = _parseInt(client['Order'] ?? 0);
      
      // 根据 ProcessType 和 ClientStatus 确定状态
      String status = _getStatusFromClientStatus(clientStatus, processType);
      
      // 出席/列席：WS_StationNum 的 Station 与 IP/站名/NodeID 多路匹配（见 station_stat_lookup）
      int attend = 0;
      int guest = 0;
      final stat = lookupStationStatRow(
        _stationStats,
        ip,
        stationName: stationName,
        nodeId: client['NodeID']?.toString(),
      );
      if (processType == 'rack' || processType == 'Server') {
        if (stat != null) {
          attend = stat['attend'] ?? 0;
          guest = stat['guest'] ?? 0;
        } else {
          attend = client['attend'] ?? 0;
          guest = client['guest'] ?? 0;
        }
      } else if (stat != null) {
        // 非「报到终端」类会标成 Client，但若站名与 WS_StationNum 的 Station 一致仍可显示人数
        attend = stat['attend'] ?? 0;
        guest = stat['guest'] ?? 0;
      }
      
      return {
        'name': stationName.isNotEmpty ? stationName : (client['Name'] ?? ''),
        'ProcessType': processType,
        'status': status,
        'attend': attend,
        'guest': guest,
        'NodeID': client['NodeID'],
        'FacilityID': facilityId,
        'IP': ip,
        'ClientStatus': clientStatus,
        'Order': order,
      };
    }).toList();

    // 关键：按后端下发的 Order 做主排序，保证设备顺序稳定
    // 若 Order 相同，再按名称/IP/NodeID 兜底
    int cmpStr(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());
    String nameKey(Map<String, dynamic> d) => (d['name']?.toString() ?? '').trim();
    String ipKey(Map<String, dynamic> d) => (d['IP']?.toString() ?? '').trim();
    String nodeKey(Map<String, dynamic> d) => (d['NodeID']?.toString() ?? '').trim();
    int orderKey(Map<String, dynamic> d) => _parseInt(d['Order'] ?? 0);

    nextDevices.sort((a, b) {
      final o1 = orderKey(a);
      final o2 = orderKey(b);
      if (o1 != o2) return o1.compareTo(o2);
      final c1 = cmpStr(nameKey(a), nameKey(b));
      if (c1 != 0) return c1;
      final c2 = cmpStr(ipKey(a), ipKey(b));
      if (c2 != 0) return c2;
      return cmpStr(nodeKey(a), nodeKey(b));
    });

    if (_kLogDeviceOrder) {
      final brief = nextDevices.map((d) {
        final n = nameKey(d);
        final ip = ipKey(d);
        final node = nodeKey(d);
        final st = (d['status']?.toString() ?? '').trim();
        return '$n|$ip|$node|$st';
      }).join(' , ');
      AppLog.d('Attend devices order: $brief', tag: 'AttendDevices');
    }

    if (_kLogStationNumAttend) {
      final statN = _stationStats.length;
      final keysBrief =
          _stationStats.keys.take(10).join(',') + (statN > 10 ? '...' : '');
      final lines = nextDevices
          .take(24)
          .map(
            (d) =>
                '${d['name']}|${d['ProcessType']}|ip=${d['IP']}|${d['attend']}/${d['guest']}',
          )
          .join(' ; ');
      developer.log(
        'devices attend snapshot: stationStatMaps=$statN keys=[$keysBrief] rows=$lines',
        name: 'StationNum',
      );
    }

    _devices = nextDevices;
  }

  // 根据 ClientStatus 获取状态文本
  String _getStatusFromClientStatus(int clientStatus, String processType) {
    // 对于报到终端/地垫终端，需要根据 CheckIn 状态实时展示
    if (processType == 'rack') {
      switch (clientStatus) {
        case 0:
          return '空闲';
        case 1:
          return '联机';
        case 2:
          return '工作';
        case 3:
          return '结束';
        case 4:
          return '脱机';
        case 5:
          return '错卡';
        case -2:
          return '重报';
        case -3:
          return '报到';
        default:
          return '联机';
      }
    }

    // 其他类型按照会议设备逻辑显示
    switch (clientStatus) {
      case 0:
        return '空闲';
      case 1:
        return '联机';
      case 2:
        return '工作';
      case 3:
        return '结束';
      case 4:
      return '脱机';
      case 5:
        return '错卡';
      case -2:
        return '重报';
      case -3:
        return '报到';
      default:
        return '空闲';
    }
  }

  // 解析整数
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  int _nonNegativeInt(dynamic value) {
    final parsed = _parseInt(value);
    return parsed < 0 ? 0 : parsed;
  }

  /// 设备 `IP` 字段可能是 `192.168.1.1:9090`；无端口时 hipc 默认 [defaultPort]。
  /// IPv6 带端口请使用 `[addr]:port`；裸 IPv6 无端口时走 `http://host:defaultPort/...`。
  Uri _deviceHipcInfoUri(String ipField, {int defaultPort = 8084}) {
    final raw = ipField.trim();
    if (raw.isEmpty) {
      return Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: defaultPort,
        path: '/hipc/info',
      );
    }
    if (raw.startsWith('[')) {
      return Uri.parse('http://$raw/hipc/info');
    }
    final colonCount = ':'.allMatches(raw).length;
    final lastColon = raw.lastIndexOf(':');
    if (lastColon > 0 && colonCount == 1) {
      final host = raw.substring(0, lastColon).trim();
      final tail = raw.substring(lastColon + 1);
      final p = int.tryParse(tail);
      if (host.isNotEmpty && p != null && p > 0 && p <= 65535) {
        return Uri(scheme: 'http', host: host, port: p, path: '/hipc/info');
      }
    }
    return Uri(scheme: 'http', host: raw, port: defaultPort, path: '/hipc/info');
  }

  Future<void> _onAttendDeviceTap(Map<dynamic, dynamic> device) async {
    final ip = device['IP']?.toString() ?? '';
    if (ip.isEmpty) return;

    final attend = _parseInt(device['attend']);
    final guest = _parseInt(device['guest']);
    final name = device['name']?.toString() ?? ip;
    final processType = device['ProcessType']?.toString() ?? '';
    final hipcUri = _deviceHipcInfoUri(ip);
    final hipcInfoUri = hipcUri.toString();

    if (_isSloganPreviewVisible && _sloganPreviewFreeze) {
      return;
    }
    setState(() {
      _notificationText = '正在获取设备信息...\nGET $hipcInfoUri';
    });
    AppLog.d('设备卡片点击: name=$name ip=$ip -> GET $hipcInfoUri', tag: 'HipcInfo');
    try {
      final hipc = await _fetchHipcInfo(ip);
      final text = _formatHipcInfoText(
        hipc,
        deviceName: name,
        attend: attend,
        guest: guest,
        processType: processType,
      );
      if (!mounted) return;
      setState(() {
        _notificationText = text;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notificationText =
            '获取设备信息失败: $e\n请求: GET $hipcInfoUri\n（日志里 errno 对应的 port 多为本机临时出站端口）';
      });
      AppLog.d('GET $hipcInfoUri 失败: $e', tag: 'HipcInfo');
      _showMessage('服务器连接出错', isError: true);
    }
  }

  Future<Map<String, dynamic>> _fetchHipcInfo(String ip) async {
    final httpClient = HttpClient();
    try {
      final uri = _deviceHipcInfoUri(ip);
      AppLog.d('HttpClient.getUrl -> $uri', tag: 'HipcInfo');
      final request = await httpClient.getUrl(uri);

      // 连接/读取超时（避免界面长时间卡住）
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final response = await request.close().timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final bodyBytes = await response.transform(utf8.decoder).toList();
      final bodyStr = bodyBytes.join();
      final decoded = jsonDecode(bodyStr);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }

      throw Exception('返回内容格式异常');
    } finally {
      httpClient.close(force: true);
    }
  }

  String _formatHipcInfoText(
    Map<String, dynamic> hipc,
    {
      required String deviceName,
      required int attend,
      required int guest,
      String processType = '',
    }
  ) {
    final data = hipc['data'];
    if (data is! Map) {
      return '设备: $deviceName\n响应: 数据格式错误';
    }
    final dataMap = data.cast<String, dynamic>();

    final mode = dataMap['mode']?.toString() ?? '-';
    final modeLower = mode.toLowerCase();
    final modeDisplay = modeLower == 'master'
        ? '主机'
        : modeLower == 'backup'
            ? '备机'
            : mode;
    // hdinfo：示例里包含 hostname/kernel/os/arch/cpu/mem 等（不再展示 boot 系统启动时间）
    final hdinfoRaw = dataMap['hdinfo'];
    final hdinfoMap =
        hdinfoRaw is Map ? hdinfoRaw.cast<String, dynamic>() : <String, dynamic>{};

    String? _get(String key) =>
        hdinfoMap[key]?.toString() ?? dataMap[key]?.toString();

    final buf = StringBuffer();
    buf.writeln('设备: $deviceName');
    buf.writeln('运行模式: $modeDisplay');
    buf.writeln('系统信息:');
    buf.writeln('  主机名: ${_get('hostname') ?? '-'}');
    buf.writeln('  内核: ${_get('kernel') ?? '-'}');
    buf.writeln('  操作系统: ${_get('os') ?? '-'}');
    buf.writeln('  架构: ${_get('arch') ?? '-'}');
    buf.writeln('  CPU: ${_get('cpu') ?? ''}');
    buf.writeln('  内存: ${_get('mem') ?? '-'}');

    return buf.toString();
  }

  // 开始会议
  Future<void> _handleStartMeeting() async {
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID不能为空', isError: true);
      return;
    }

    if (_isLoading) return;

    final int actionSeq = ++_meetingActionSeq;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SccClientWrapper.startMeet(widget.meetId!);
      if (!mounted || actionSeq != _meetingActionSeq) return;
      if (result.isSuccess) {
        setState(() {
          _meetStatus = 1;
          _isMeetingStarted = true;
          _meetingTitle = '会议正在进行';
        });
        _showMessage('会议开始成功');
      } else {
        _showMessage(result.msg.isNotEmpty ? result.msg : '会议开始失败', isError: true);
      }
    } catch (e) {
      if (!mounted || actionSeq != _meetingActionSeq) return;
      _showMessage('操作失败: $e', isError: true);
    } finally {
      if (!mounted || actionSeq != _meetingActionSeq) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 结束会议
  Future<void> _handleEndMeeting() async {
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID不能为空', isError: true);
      return;
    }

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认结束会议', style: TextStyle(fontFamily: 'Microsoft YaHei')),
          content: Text('确定要结束当前会议吗？', style: TextStyle(fontFamily: 'Microsoft YaHei')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('取消', style: TextStyle(fontFamily: 'Microsoft YaHei')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('确定', style: TextStyle(fontFamily: 'Microsoft YaHei', color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (_isLoading) return;

    final int actionSeq = ++_meetingActionSeq;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SccClientWrapper.endMeet(widget.meetId!);
      if (!mounted || actionSeq != _meetingActionSeq) return;
      if (result.isSuccess) {
        setState(() {
          _meetStatus = 2;
          _isMeetingStarted = false;
          _meetingTitle = '会议已经结束';
        });
        _showMessage('会议结束成功');
      } else {
        _showMessage(result.msg.isNotEmpty ? result.msg : '会议结束失败', isError: true);
      }
    } catch (e) {
      if (!mounted || actionSeq != _meetingActionSeq) return;
      _showMessage('操作失败: $e', isError: true);
    } finally {
      if (!mounted || actionSeq != _meetingActionSeq) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 数据上报
  Future<void> _handleDataReport() async {
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID不能为空', isError: true);
      return;
    }

    // 获取站点列表（从客户端列表），仅包含 8084 端口的设备。
    // 界面展示报到设备名称，提交仍使用 IP 列表。
    final Map<String, Map<String, String>> stationByIp = {};
    for (final client in _clientList) {
      final ip = client['IP']?.toString() ?? '';
      if (ip.isEmpty) continue;
      if (!(ip.contains(':8084') || ip.endsWith('8084'))) continue;
      final name = (client['StationName'] ??
              client['Name'] ??
              client['FacilityTypeName'] ??
              ip)
          .toString();
      stationByIp[ip] = {'ip': ip, 'name': name};
    }
    final stations = stationByIp.values.toList();

    if (stations.isEmpty) {
      _showMessage('没有可用的站点', isError: true);
      return;
    }

    final selectedStations = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return _StationSelectionDialog(
          stations: stations,
          title: '选择要上报的报到终端',
        );
      },
    );

    if (selectedStations == null || selectedStations.isEmpty) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final stationsStr = selectedStations.join(',');
      final result = await SccClientWrapper.reportCheckInFailed(
        meetID: widget.meetId!,
        stations: stationsStr,
      );
      if (result.isSuccess) {
        _showMessage('数据上报成功');
      } else {
        _showMessage(result.msg.isNotEmpty ? result.msg : '数据上报失败', isError: true);
      }
    } catch (e) {
      _showMessage('操作失败: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 数据检查
  Future<void> _handleDataCheck() async {
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID不能为空', isError: true);
      return;
    }

    // 获取站点列表（从客户端列表），仅包含 8084 端口的设备。
    // UI 展示用“报到设备名称”，提交仍然使用 IP 列表（与后端协议一致）。
    final Map<String, Map<String, String>> stationByIp = {};
    for (final client in _clientList) {
      final ip = client['IP']?.toString() ?? '';
      if (ip.isEmpty) continue;
      // 仅保留端口为 8084 的设备（形如 192.168.0.10:8084 或结尾是 8084）
      if (!(ip.contains(':8084') || ip.endsWith('8084'))) continue;
      final name = (client['StationName'] ??
              client['Name'] ??
              client['FacilityTypeName'] ??
              ip)
          .toString();
      stationByIp[ip] = {'ip': ip, 'name': name};
    }
    final stations = stationByIp.values.toList();

    if (stations.isEmpty) {
      _showMessage('没有可用的站点', isError: true);
      return;
    }

    // 显示数据检查对话框（包含设备选择和表选择）
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return _DataCheckDialog(
          stations: stations,
        );
      },
    );

    if (result == null) return;

    final selectedStations = result['stations'] as List<String>? ?? [];
    final selectedTables = result['tables'] as List<String>? ?? [];

    if (selectedStations.isEmpty) {
      _showMessage('请至少选择一个设备', isError: true);
      return;
    }

    if (selectedTables.isEmpty) {
      _showMessage('请至少选择一个表', isError: true);
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _dataCheckResults = []; // 清空之前的结果
      _selectedDataCheckTables = List<String>.from(selectedTables);
    });

    try {
      // 1. 先结束之前的检查
      await SccClientWrapper.endDatabaseCheck();
      // 2. 显示开始检查的消息
      _showMessage('开始校验', isError: false);
      
      // 3. 开始新的检查
      final stationsStr = selectedStations.join(',');
      final tablesStr = selectedTables.join(',');
      final checkResult = await SccClientWrapper.databaseCheck(
        meetID: widget.meetId!,
        stations: stationsStr,
        tables: tablesStr,
      );
      
      if (checkResult.isSuccess) {
        // 4. 开始轮询检查状态
        _startDataCheckPolling();
      } else {
        _showMessage(checkResult.msg.isNotEmpty ? checkResult.msg : '数据检查失败', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showMessage('操作失败: $e', isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 开始轮询数据检查状态
  void _startDataCheckPolling() {
    // 先清除之前的定时器
    _dataCheckTimer?.cancel();
    
    _dataCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // 过滤出正在检查或已完成的设备（DataCheckStatus != 0）
      final checkingDevices = _clientList.where((client) {
        final status = client['DataCheckStatus'];
        return status != null && status != 0;
      }).toList();
      
      if (checkingDevices.isEmpty) {
        // 没有检查中的设备，停止轮询
        timer.cancel();
        _dataCheckTimer = null;
        
        // 显示检查结果
        _showDataCheckFinalResults();
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // 处理检查结果
      setState(() {
        _dataCheckResults.clear();
        for (var device in checkingDevices) {
          final remark = device['Remark']?.toString() ?? '';
          if (remark.isNotEmpty) {
            try {
              final remarkData = jsonDecode(remark) as Map<String, dynamic>;
              remarkData['StationName'] = device['StationName'] ?? device['IP'] ?? '';
              _dataCheckResults.add(remarkData);
            } catch (e) {
              // 解析失败，跳过
            }
          }
        }
      });
      
      // 检查是否所有设备都已完成检查（DataCheckStatus !== 1）
      final allCompleted = checkingDevices.every((device) {
        final status = device['DataCheckStatus'];
        return status != null && status != 1;
      });
      
      if (allCompleted) {
        // 所有设备检查完成，停止轮询
        timer.cancel();
        _dataCheckTimer = null;
        
        // 显示检查结果
        _showDataCheckFinalResults();
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // 显示数据检查最终结果
  void _showDataCheckFinalResults() {
    if (_dataCheckResults.isEmpty) {
      _showDataCheckResult(
        title: '数据检查完成',
        result: '检查完成，但未返回详细数据',
        isSuccess: true,
      );
      return;
    }

    _showDataCheckResultList(
      title: '数据检查完成',
      results: _dataCheckResults,
      selectedTables: _selectedDataCheckTables,
      isSuccess: true,
    );
  }

  int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  void _showDataCheckResultList({
    required String title,
    required List<Map<String, dynamic>> results,
    required List<String> selectedTables,
    required bool isSuccess,
  }) {
    final allColumns = <Map<String, String>>[
      {'id': 'meet', 'title': '会议表', 'field': 'Meet'},
      {'id': 'personinformationphoto', 'title': '人员表', 'field': 'PersonInformationPhoto'},
      {'id': 'delegateregister', 'title': '代表表', 'field': 'DelegateRegister'},
      {'id': 'personinformation', 'title': '人员基础表', 'field': 'PersonInformation'},
    ];
    final selectedSet =
        selectedTables.map((e) => e.toLowerCase().trim()).toSet();
    final visibleColumns = selectedSet.isEmpty
        ? allColumns
        : allColumns.where((c) => selectedSet.contains(c['id'])).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              if (isSuccess)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                )
              else
                Text(
                  '×',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    color: Colors.red,
                  ),
                ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Microsoft YaHei',
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 420),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '名称',
                          style: TextStyle(
                            fontFamily: 'Microsoft YaHei',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...visibleColumns.map(
                        (column) => Expanded(
                          child: Text(
                            column['title'] ?? '',
                            style: TextStyle(
                              fontFamily: 'Microsoft YaHei',
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = results[index];
                      final stationName =
                          r['StationName']?.toString() ?? '未知站点';

                      Widget statusMark(bool ok) => Text(
                            ok ? '✓' : '×',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ok ? Colors.green : Colors.amber.shade700,
                              fontFamily: 'Microsoft YaHei',
                            ),
                          );

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                stationName,
                                style: TextStyle(
                                  fontFamily: '宋体',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ...visibleColumns.map((column) {
                              final field = column['field'] ?? '';
                              final ok = _safeInt(r[field]) == 1;
                              return Expanded(
                                child: Center(child: statusMark(ok)),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('确定',
                  style: TextStyle(fontFamily: 'Microsoft YaHei')),
            ),
          ],
        );
      },
    );
  }

  // 文件选取
  Future<void> _handleFilePick() async {
    if (_isFileImporting) return;

    try {
      final filePath = await _pickSingleFilePath();
      if (filePath != null && filePath.isNotEmpty) {
        await _importFileFromPath(filePath);
      }
    } catch (e) {
      _showMessage('文件选择失败: $e', isError: true);
    }
  }

  Future<String?> _pickSingleFilePath() async {
    final file = await openFile();
    return file?.path;
  }

  Future<bool> _importFileFromPath(String filePath) async {
    if (_isFileImporting) {
      return false;
    }
    final file = File(filePath);
    if (!await file.exists()) {
      _showMessage('文件不存在', isError: true);
      return false;
    }
    _isFileImporting = true;

    try {
      final importResult = await SccClientWrapper.importRecord(filePath);
      if (importResult.isSuccess) {
        _showMessage('文件导入成功: ${importResult.data ?? ""}');
        _lastUsbAutoImportError = null;
        return true;
      }
      _showMessage(importResult.msg.isNotEmpty ? importResult.msg : '文件导入失败',
          isError: true);
      AppLog.d(
        'importRecord failed for $filePath: ${importResult.msg}',
        tag: 'USB Auto Import',
      );
      return false;
    } catch (e) {
      _showMessage('导入失败: $e', isError: true);
      AppLog.d(
        'importRecord exception for $filePath: $e',
        tag: 'USB Auto Import',
      );
      return false;
    } finally {
      _isFileImporting = false;
    }
  }

  // 显示消息
  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    // 避免多次操作导致 SnackBar 排队，从而出现“状态已结束但提示是开始成功”
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'Microsoft YaHei'),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 显示数据检查结果
  void _showDataCheckResult({
    required String title,
    required String result,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              if (isSuccess)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                )
              else
                Text(
                  '×',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    color: Colors.red,
                  ),
                ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Microsoft YaHei',
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (result.isNotEmpty) ...[
                    Text(
                      '检查结果：',
                      style: TextStyle(
                        fontFamily: 'Microsoft YaHei',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SelectableText(
                        result,
                        style: TextStyle(
                          fontFamily: 'Microsoft YaHei',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '检查完成',
                      style: TextStyle(
                        fontFamily: 'Microsoft YaHei',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('确定', style: TextStyle(fontFamily: 'Microsoft YaHei')),
            ),
          ],
        );
      },
    );
  }

  void _handleDeviceRouteData(Map<String, dynamic> data) {
    final payload =
        data['data'] is Map ? data['data'] as Map<String, dynamic> : data;
    try {
      // 仅输出字段名，避免大数据刷屏
      _debugPrintPayloadKeys(payload);
      final routeMap = FacilityRouteMap.fromPayload(payload);
      // 如果内容与当前一致，直接返回，避免闪烁
      final currentRouteMap = _routeMapNotifier.value;
      if (currentRouteMap != null &&
          _isSameRouteMap(routeMap, currentRouteMap)) {
        AppLog.d('skip refresh: identical to current', tag: 'DeviceRouteMap');
        return;
      }

      // 计算签名，仅包含影响渲染的关键信息，避免相同数据反复刷新
      final newSig = _computeRouteMapSignature(routeMap);
      if (newSig != null && newSig == _lastRouteMapSignature) {
        AppLog.d('skip refresh: same signature', tag: 'DeviceRouteMap');
        return;
      }

      AppLog.d(
        'parsed routeId=${routeMap.routeId} meetId=${routeMap.meetId} facilities=${routeMap.settings.facilities.length}',
        tag: 'DeviceRouteMap',
      );
      _routeMapNotifier.value = routeMap;
      _lastRouteMapSignature = newSig;
    } catch (e) {
      // 解析失败时忽略
    }
  }

  void _logPayloadKeysBrief(
    String tag,
    String channel,
    String remark,
    Map<String, dynamic> data,
  ) {
    try {
      final topKeys = data.keys.join(', ');
      String nestedKeys = '';
      final nested = data['data'];
      if (nested is Map) {
        nestedKeys = nested.keys.join(', ');
      }
      AppLog.d(
        'channel=$channel remark=$remark keys=[$topKeys] data.keys=[$nestedKeys]',
        tag: tag,
      );
    } catch (_) {
      // ignore
    }
  }

  void _logGrpcPushPayload({
    required String channel,
    required String remark,
    required Map<String, dynamic> data,
  }) {
    try {
      final lowerChannel = channel.toLowerCase();
      final lowerRemark = remark.toLowerCase();
      // 关闭图片/点位图通道日志，避免大 payload 刷屏
      if (lowerChannel == 'deviceroutemap' ||
          lowerRemark.contains('deviceroute') ||
          lowerRemark.contains('routemap')) {
        return;
      }
      // 关闭设备全量列表通道日志（WS_Client / WS_ClientChild），避免持续刷屏
      if (lowerChannel == 'ws_client' ||
          lowerChannel == 'ws_clientchild' ||
          lowerRemark.contains('ws_client')) {
        return;
      }

      final ch = channel.isEmpty ? '(empty)' : channel;
      final rm = remark.isEmpty ? '-' : remark;
      String body;
      try {
        body = jsonEncode(data);
      } catch (_) {
        body = data.toString();
      }
      AppLog.d('channel=$ch remark=$rm payload=$body', tag: 'gRPC-PUSH');
    } catch (e) {
      AppLog.d('log error: $e', tag: 'gRPC-PUSH');
    }
  }

  void _debugPrintPayloadKeys(Map<String, dynamic> payload) {
    try {
      AppLog.d('payload keys: ${payload.keys.join(', ')}', tag: 'DeviceRouteMap');
      final settingsList = payload['RouteMapSettings'];
      if (settingsList is List && settingsList.isNotEmpty && settingsList.first is Map) {
        final first = settingsList.first as Map;
        AppLog.d(
          'RouteMapSettings[0] keys: ${(first.keys).join(', ')}',
          tag: 'DeviceRouteMap',
        );
      }
      final nestedData = payload['data'];
      if (nestedData is Map) {
        AppLog.d('data keys: ${nestedData.keys.join(', ')}', tag: 'DeviceRouteMap');
      }
    } catch (_) {
      // 忽略调试打印异常
    }
  }

  String? _computeRouteMapSignature(FacilityRouteMap map) {
    try {
      final facilitiesSig = _sortedFacilities(map.settings.facilities);
      final sigObj = {
        'routeId': map.routeId,
        'bgPath': map.settings.bgPath.trim(),
        'bgLen': map.settings.bgBytes?.length ?? 0,
        'canvas': [
          _round6(map.settings.canvasSize.width),
          _round6(map.settings.canvasSize.height),
        ],
        'fac': facilitiesSig,
      };
      return jsonEncode(sigObj);
    } catch (_) {
      return null;
    }
  }

  double _round6(double value) =>
      double.parse(value.toStringAsFixed(6));

  List<Map<String, dynamic>> _sortedFacilities(List<FacilityPoint> list) {
    return list
        .map((f) => {
              'id': f.facilityId,
              't': f.facilityType.name,
              'x': _round6(f.x),
              'y': _round6(f.y),
              'ip': f.ip,
              'cam': f.cameraUri,
            })
        .toList()
      ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  }

  bool _isSameRouteMap(FacilityRouteMap a, FacilityRouteMap b) {
    try {
      if (a.routeId != b.routeId) {
        AppLog.d('diff: routeId', tag: 'DeviceRouteMap');
        return false;
      }
      if (a.settings.bgPath.trim() != b.settings.bgPath.trim()) {
        AppLog.d('diff: bgPath', tag: 'DeviceRouteMap');
        return false;
      }
      if ((a.settings.bgBytes?.length ?? 0) !=
          (b.settings.bgBytes?.length ?? 0)) {
        AppLog.d('diff: bgBytes len', tag: 'DeviceRouteMap');
        return false;
      }
      if (_round6(a.settings.canvasSize.width) !=
          _round6(b.settings.canvasSize.width)) {
        AppLog.d('diff: canvas width', tag: 'DeviceRouteMap');
        return false;
      }
      if (_round6(a.settings.canvasSize.height) !=
          _round6(b.settings.canvasSize.height)) {
        AppLog.d('diff: canvas height', tag: 'DeviceRouteMap');
        return false;
      }
      final facA = _sortedFacilities(a.settings.facilities);
      final facB = _sortedFacilities(b.settings.facilities);
      if (facA.length != facB.length) {
        AppLog.d('diff: facilities length', tag: 'DeviceRouteMap');
        return false;
      }
      for (var i = 0; i < facA.length; i++) {
        if (!_shallowMapEquals(facA[i], facB[i])) {
          AppLog.d(
            'diff: facility ${facA[i]} vs ${facB[i]}',
            tag: 'DeviceRouteMap',
          );
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _shallowMapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  // 完全按照图片样式重新设计统计卡片
  Widget _buildStatCard(String title, Map<String, int> stats) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分 - 左侧
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 60),
            child: MixedFontText(
              '$title:',
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'FZXBYS',
                fontWeight: FontWeight.bold,
                color: HexColor('#FFFF00'),
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 12),

          // 统计卡片区域 - 右侧
          Expanded(
            child: Row(
              children: stats.entries.map((entry) {
                final String label = entry.key;
                final int value = entry.value;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 左侧：标签
                        MixedFontText(
                          '$label:',
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'FZXBYS',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        // 右侧：数字
                        MixedFontText(
                          value.toString(),
                          style: TextStyle(
                            fontFamily: 'FZXBYS',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: HexColor('#A30014'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 其他方法保持不变...
  Widget _buildDeviceGrid() {
    // 创建设备状态映射：facilityId -> status
    // 通过设备名称/NodeID/FacilityID/IP 匹配
    final Map<String, String> deviceStatusMap = {};
    final Map<String, bool> port1030Map = {};
    final Map<String, bool> port8084Map = {};
    final Map<String, String> facilityNameMap = {};
    for (var device in _devices) {
      final deviceName = device['name']?.toString() ?? '';
      final deviceStatus = device['status']?.toString() ?? '';
      final nodeId = device['NodeID'];
      final facilityId = device['FacilityID'];
      final ip = device['IP']?.toString();

      final bool isPort1030 = ip != null && ip.trim().endsWith(':1030');
      final bool isPort8084 = ip != null && ip.trim().endsWith(':8084');

      if (deviceName.isNotEmpty) {
        facilityNameMap[deviceName] = deviceName;
      }
      if (nodeId != null && deviceName.isNotEmpty) {
        facilityNameMap[nodeId.toString()] = deviceName;
      }
      if (facilityId != null && deviceName.isNotEmpty) {
        facilityNameMap[facilityId.toString()] = deviceName;
      }
      if (ip != null && ip.isNotEmpty && deviceName.isNotEmpty) {
        facilityNameMap[ip] = deviceName;
      }

      if (deviceName.isNotEmpty && deviceStatus.isNotEmpty) {
        deviceStatusMap[deviceName] = deviceStatus;
        if (isPort1030) port1030Map[deviceName] = true;
        if (isPort8084) port8084Map[deviceName] = true;
      }
      if (nodeId != null && deviceStatus.isNotEmpty) {
        deviceStatusMap[nodeId.toString()] = deviceStatus;
        if (isPort1030) port1030Map[nodeId.toString()] = true;
        if (isPort8084) port8084Map[nodeId.toString()] = true;
      }
      if (facilityId != null && deviceStatus.isNotEmpty) {
        deviceStatusMap[facilityId.toString()] = deviceStatus;
        if (isPort1030) port1030Map[facilityId.toString()] = true;
        if (isPort8084) port8084Map[facilityId.toString()] = true;
      }
      if (ip != null && ip.isNotEmpty && deviceStatus.isNotEmpty) {
        deviceStatusMap[ip] = deviceStatus;
        if (isPort1030) port1030Map[ip] = true;
        if (isPort8084) port8084Map[ip] = true;
      }
    }
    
    return ValueListenableBuilder<FacilityRouteMap?>(
      valueListenable: _routeMapNotifier,
      builder: (context, map, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _selectedFacilityIdNotifier,
          builder: (context, selectedId, __) {
            return DeviceMapWidget(
              routeMap: map,
              selectedGateName: selectedId,
              deviceStatusMap: deviceStatusMap,
              port8084Map: port8084Map,
              port1030Map: port1030Map,
              facilityNameMap: facilityNameMap,
              stationStats: _stationStats,
              onCabinetTap: (facilityId) {
                _selectedFacilityIdNotifier.value = facilityId;
              },
            );
          },
        );
      },
    );
  }

  //设备列表
  //设备列表
  Widget _buildAttendList() {
    // 使用真实的设备数据
    final devices = _devices.isEmpty ? [
      {
        'name': '01-北京厅',
        'ProcessType': 'rack',
        'status': '空闲',
        'attend': 8,
        'guest': 0,
        'color': Colors.black54,
      },
      {
        'name': '02-上海厅',
        'ProcessType': 'rack',
        'status': '结束',
        'attend': 8,
        'guest': 0,
        'color': Colors.orange,
      },
      {
        'name': '01-北京厅',
        'ProcessType': 'rack',
        'status': '工作',
        'attend': 8,
        'guest': 0,
        'color': Colors.blue,
      },
      {
        'name': '02-上海厅',
        'ProcessType': 'rack',
        'status': '结束',
        'attend': 8,
        'guest': 0,
        'color': Colors.orange,
      },
      {
        'name': '01-北京厅',
        'ProcessType': 'rack',
        'status': '工作',
        'attend': 8,
        'guest': 0,
        'color': Colors.blue,
      },
      {
        'name': '02-上海厅',
        'ProcessType': 'rack',
        'status': '结束',
        'attend': 8,
        'guest': 0,
        'color': Colors.orange,
      },
      {
        'name': '01-北京厅',
        'ProcessType': 'rack',
        'status': '空闲',
        'attend': 8,
        'guest': 0,
        'color': Colors.black54,
      },
      {
        'name': '02-上海厅',
        'ProcessType': 'rack',
        'status': '结束',
        'attend': 8,
        'guest': 0,
        'color': Colors.orange,
      },
      {
        'name': '01-北京厅',
        'ProcessType': 'rack',
        'status': '工作',
        'attend': 8,
        'guest': 0,
        'color': Colors.blue,
      },
      {
        'name': '02-上海厅',
        'ProcessType': 'rack',
        'status': '结束',
        'attend': 8,
        'guest': 0,
        'color': Colors.orange,
      },
      {
        'name': '01-北京厅',
        'ProcessType': 'rack',
        'status': '空闲',
        'attend': 8,
        'guest': 0,
        'color': Colors.black54,
      },
      {
        'name': '02-上海厅',
        'ProcessType': 'rack',
        'status': '结束',
        'attend': 8,
        'guest': 0,
        'color': Colors.orange,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '工作',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '联机',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '脱机',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '工作',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '工作',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '地垫式报到设备',
        'ProcessType': 'didian',
        'status': '工作',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
    ] : _devices;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        // 字号增大后需要更高的单元格，避免底部溢出
        childAspectRatio: 0.74,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final String processType = device['ProcessType'] as String;
        final bool isRack = processType == 'rack';
        final String status = device['status'] as String; // 先定义status变量
        final String deviceIp = device['IP']?.toString() ?? '';
        final bool isDidianLike = processType == 'didian' ||
            deviceIp.contains(':1030') ||
            deviceIp.endsWith('1030');
        // 地垫（1030）：不提供 hipc 详情点击
        final bool isTapDisabled =
            status == '空闲' || status == '脱机' || isDidianLike;
        // 状态背景色不同，因此文字也要随之调整可读性
        // 其中“报到/重报”要求背景色与黑色文字
        final Color textColor = status == '工作' || status == '报到' || status == '重报'
            ? Colors.black
            : Colors.white; // 然后使用它
        return InkWell(
          onTap: isTapDisabled ? null : () => _onAttendDeviceTap(device),
          child: Container(
            decoration: BoxDecoration(
              color: isRack ? Colors.grey[200] : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 状态指示器 - 使用图片展示
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_getDeviceImage(processType)),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Transform.translate(
                    // 根据设备类型调整矩形框位置
                    offset: _getStatusOffset(processType),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(
                          device['status'] as String,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: _getStatusPadding(processType),
                      child: Text(
                        _getStatusDisplayText(
                          device['status'] as String,
                          processType, // 传入设备类型决定是否换行
                        ),
                        style: TextStyle(
                          fontSize: _getStatusFontSize(processType),
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFamily: 'Microsoft YaHei',
                          shadows: [
                            Shadow(color: Colors.black, offset: Offset(1, 1)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // 设备名称
              Padding(
                padding: EdgeInsets.all(3),
                child: Text(
                  device['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Microsoft YaHei',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 人数信息（仅显示会议厅）
              Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    MixedFontText(
                      '出席: ${device['attend']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'FZXBYS',
                      ),
                    ),
                    SizedBox(height: 2),
                    MixedFontText(
                      '列席: ${device['guest']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontFamily: 'FZXBYS',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }

  String _getDeviceImage(String processType) {
    switch (processType) {
      case 'rack':
        return 'assets/images/device.png'; // 机架设备
      case 'Client':
        return 'assets/images/jsj.png'; // 计算机设备
      case 'didian':
        return 'assets/images/didian.png'; // 地垫设备
      default:
        return 'assets/images/device.png'; // 默认图片
    }
  }

  // 根据设备类型获取状态框偏移量
  Offset _getStatusOffset(String processType) {
    switch (processType) {
      case 'rack': // 会议厅设备
        return Offset(-1, -15);
      case 'Client': // 报到显示终端
        return Offset(2, -13);
      case 'didian': // 地垫式报到设备
        return Offset(-1, 38);
      default:
        return Offset(-1, -15);
    }
  }

  // 根据设备类型获取状态框内边距
  EdgeInsets _getStatusPadding(String processType) {
    switch (processType) {
      case 'rack': // 会议厅设备
        return EdgeInsets.symmetric(horizontal: 6, vertical: 12);
      case 'Client': // 报到显示终端
        return EdgeInsets.symmetric(horizontal: 26, vertical: 9);
      case 'didian': // 地垫式报到设备
        return EdgeInsets.symmetric(horizontal: 44, vertical: 9);
      default:
        return EdgeInsets.symmetric(horizontal: 6, vertical: 12);
    }
  }

  // 根据设备类型获取状态文字大小
  double _getStatusFontSize(String processType) {
    switch (processType) {
      case 'rack': // 会议厅设备
        return 16;
      case 'Client': // 报到显示终端
        return 14;
      case 'didian': // 地垫式报到设备
        return 12;
      default:
        return 16;
    }
  }

  // 根据状态获取背景颜色
  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case '工作':
        return HexColor('#FFFFFF'); // 半透明白色
      case '结束':
        return HexColor('#FF6600'); // 半透明橙色
      case '空闲':
        return HexColor('#000000'); // 半透明黑色
      case '联机':
        return Colors.blue;
      case '脱机':
        return Colors.green; // 半透明绿色
      case '设备':
        return Colors.purple.withOpacity(0.8); // 半透明紫色
      case '重报':
        return HexColor('#00F7DE'); // 半透明青色
      case '报到':
        // 报到要求：黄色背景 + 黑色文字（与 Vue: #ffff00 一致）
        return HexColor('#FFFF00');
      case '错卡':
        return HexColor('#ffa500'); // 半透明橙色
      default:
        return Colors.black.withOpacity(0.6); // 默认半透明黑色
    }
  }

  // 修改状态显示文本，只有rack设备需要换行
  String _getStatusDisplayText(String status, String processType) {
    // 只有rack设备需要换行
    if (processType == 'rack') {
      switch (status) {
        case '空闲':
          return '空\n闲';
        case '联机':
          return '联\n机';
        case '工作':
          return '工\n作';
        case '结束':
          return '结\n束';
        case '脱机':
          return '脱\n机';
        case '错卡':
          return '错\n卡';
        case '报到':
          return '报\n到';
        case '重报':
          return '重\n报';
        default:
          return status.length > 2
              ? '${status.substring(0, 2)}\n${status.substring(2)}'
              : status;
      }
    } else {
      // 其他设备类型不换行
      return status;
    }
  }

  // 显示管理内容
  Widget _buildDisplayManagementContent() {
    final hasBanner = _sloganBannerItems.isNotEmpty;
    final hasCheckIn = _sloganCheckInItems.isNotEmpty;
    final hasSlogan = _sloganTableData.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildDisplayTypeButton(
                label: '会标',
                enabled: hasBanner && !_isDisplayLoading,
                selected: _displayManagementType == '会标',
                onTap: hasBanner
                    ? () {
                        setState(() {
                          _displayManagementType = '会标';
                          _showSloganTable = false;
                        });
                        _previewQuickDisplayType(
                          item: _sloganBannerItems.first,
                          type: '会标',
                        );
                      }
                    : null,
              ),
              const SizedBox(width: 10),
              _buildDisplayTypeButton(
                label: '报到情况',
                enabled: hasCheckIn && !_isDisplayLoading,
                selected: _displayManagementType == '报到情况',
                onTap: hasCheckIn
                    ? () {
                        setState(() {
                          _displayManagementType = '报到情况';
                          _showSloganTable = false;
                        });
                        _previewQuickDisplayType(
                          item: _sloganCheckInItems.first,
                          type: '报到情况',
                        );
                      }
                    : null,
              ),
              const SizedBox(width: 10),
              _buildDisplayTypeButton(
                label: '标语',
                enabled: hasSlogan && !_isDisplayLoading,
                selected: _displayManagementType == '标语',
                onTap: hasSlogan
                    ? () {
                        setState(() {
                          _displayManagementType = '标语';
                          _showSloganTable = true;
                          _pendingQuickDisplayItem = null;
                          _pendingQuickDisplayType = '';
                        });
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_pendingQuickDisplayItem != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Text(
                    '$_pendingQuickDisplayType 预览',
                    style: const TextStyle(
                      fontFamily: 'Microsoft YaHei',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: (_isSendingSlogan ||
                              !_sloganPreviewedRowIndices.contains(-1))
                          ? null
                          : _confirmQuickDisplayType,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor('#A30014'),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        '确认显示',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Microsoft YaHei',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (_showSloganTable)
            SizedBox(
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              '序号',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'Microsoft YaHei',
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 3,
                            child: Text(
                              '标语名称',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'Microsoft YaHei',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '操作',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontFamily: 'Microsoft YaHei',
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: _isDisplayLoading
                                          ? null
                                          : () async {
                                              await _loadDisplayManagementData();
                                              if (!mounted) return;
                                              setState(() {
                                                _showSloganTable = true;
                                              });
                                            },
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(11),
                                          border: Border.all(color: Colors.grey.shade400),
                                        ),
                                        alignment: Alignment.center,
                                        child: _isDisplayLoading
                                            ? const SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : const Icon(Icons.refresh, size: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _showSloganTable = false;
                                        });
                                      },
                                      child: const Icon(Icons.close, size: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isDisplayLoading
                          ? const Center(child: CircularProgressIndicator())
                          : (_sloganTableData.isEmpty
                              ? Center(
                                  child: Text(
                                    '空',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontFamily: 'Microsoft YaHei',
                                    ),
                                  ),
                                )
                              : Scrollbar(
                                  controller: _sloganTableScrollController,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _sloganTableScrollController,
                                    child: Column(
                                      children: _sloganTableData
                                          .asMap()
                                          .entries
                                          .map((e) => _buildSloganRow(e.key, e.value))
                                          .toList(),
                                    ),
                                  ),
                                )),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 会议管理内容（原有的功能按钮区域）
  Widget _buildMeetingManagementContent() {
    final String meetingActionText;
    final IconData meetingActionIcon;
    final VoidCallback? meetingActionTap;
    if (_meetStatus == 2) {
      meetingActionText = '已结束';
      meetingActionIcon = Icons.stop_circle_outlined;
      meetingActionTap = _handleStartMeeting;
    } else if (_isMeetingStarted || _meetStatus == 1) {
      meetingActionText = '结束';
      meetingActionIcon = Icons.power_settings_new;
      meetingActionTap = _handleEndMeeting;
    } else {
      meetingActionText = '开始';
      meetingActionIcon = Icons.play_arrow;
      meetingActionTap = _handleStartMeeting;
    }

    return Container(
      height: 230, // 适当的高度，容纳两行按钮
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 第一行：开始/结束、业务流程、数据上报
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 根据会议状态显示"开始"或"结束"按钮
              _buildFunctionButton(
                meetingActionText,
                meetingActionIcon,
                color: Colors.white,
                onTap: meetingActionTap,
              ),
              _buildFunctionButton(
                '业务流程',
                Icons.compare_arrows,
                color: Colors.white,
                onTap: _showStepProgressDialog,
              ),
              _buildFunctionButton(
                '数据上报',
                Icons.cloud_upload,
                color: Colors.white,
                onTap: _handleDataReport,
              ),
            ],
          ),
          // 第二行：数据检查、文件选取、退出（右下角）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFunctionButton(
                '数据检查',
                Icons.search,
                color: Colors.white,
                onTap: _handleDataCheck,
              ),
              _buildFunctionButton(
                '文件选取',
                Icons.folder,
                color: Colors.white,
                onTap: _handleFilePick,
              ),
              _buildFunctionButton(
                '退出',
                Icons.exit_to_app,
                color: Colors.white,
                onTap: () async {
                  if (!await showExitConfirmDialog(context)) return;
                  await LocalExitApi.callExit();
                  exit(0);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStepProgressDialog() {
    final steps = _effectiveProgressSteps();
    int tempIndex = steps.isEmpty
        ? 0
        : _completedStepIndex.clamp(0, steps.length - 1);
    bool isModalUpdating = false;
    String? modalError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> updateIndex(int newIndex) async {
              final safeIndex = steps.isEmpty
                  ? 0
                  : newIndex.clamp(0, steps.length - 1);
              if (safeIndex == tempIndex || isModalUpdating) {
                return;
              }
              setModalState(() {
                isModalUpdating = true;
                modalError = null;
              });
              final success = await _updateProgressStep(safeIndex);
              if (!mounted) return;
              setModalState(() {
                isModalUpdating = false;
                if (success) {
                  tempIndex = safeIndex;
                } else {
                  modalError = '同步失败，请稍后重试';
                }
              });
            }

            return AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 260, vertical: 140),
              title: const Text(
                '业务流程',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepProgressBar(tempIndex),
                    if (isModalUpdating) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(minHeight: 2),
                    ],
                    if (modalError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        modalError!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              actions: [
                TextButton(
                  onPressed: (!isModalUpdating && tempIndex > 0)
                      ? () => updateIndex(tempIndex - 1)
                      : null,
                  child: const Text('← 上一步'),
                ),
                ElevatedButton(
                  onPressed: (!isModalUpdating &&
                          steps.isNotEmpty &&
                          tempIndex < steps.length - 1)
                      ? () => updateIndex(tempIndex + 1)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    backgroundColor: const Color(0xFF1E88E5),
                  ),
                  child: const Text('下一步 →'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('关闭'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<_ProgressStepInfo> _cloneDefaultProgressSteps() {
    return _kDefaultProgressSteps.map((step) => step).toList();
  }

  List<_ProgressStepInfo> _parseProgressSteps(dynamic payload) {
    dynamic normalized = payload;
    if (normalized is String) {
      final trimmed = normalized.trim();
      try {
        normalized = jsonDecode(trimmed);
      } catch (_) {}
    }

    List<_ProgressStepInfo> extracted =
        _extractProgressStepsFromSource(normalized);
    if (extracted.isEmpty && normalized is Map<String, dynamic>) {
      for (final key in ['data', 'steps', 'list', 'items', 'diagram']) {
        if (normalized.containsKey(key)) {
          extracted = _extractProgressStepsFromSource(normalized[key]);
        }
        if (extracted.isNotEmpty) break;
      }
    }

    extracted.sort((a, b) => a.step.compareTo(b.step));
    return extracted;
  }

  List<_ProgressStepInfo> _extractProgressStepsFromSource(dynamic source) {
    if (source is String) {
      try {
        final decoded = jsonDecode(source);
        return _extractProgressStepsFromSource(decoded);
      } catch (_) {
        return [];
      }
    }
    if (source is List) {
      return source
          .whereType<Map>()
          .map(_progressStepFromMap)
          .whereType<_ProgressStepInfo>()
          .toList();
    }
    if (source is Map) {
      final info = _progressStepFromMap(source);
      if (info != null) {
        return [info];
      }
    }
    return [];
  }

  _ProgressStepInfo? _progressStepFromMap(Map rawMap) {
    final map = rawMap.map<String, dynamic>(
      (key, value) => MapEntry(key.toString(), value),
    );
    final titleValue =
        map['title'] ?? map['Title'] ?? map['name'] ?? map['Name'];
    final String title =
        (titleValue?.toString().isNotEmpty ?? false) ? titleValue.toString() : '';

    final int stepValue = _parseInt(
      map['step'] ?? map['Step'] ?? map['index'] ?? map['Index'],
    );
    if (title.isEmpty && stepValue <= 0) {
      return null;
    }

    final step = stepValue <= 0 ? 1 : stepValue;
    final executed = _parseBool(
      map['executed'] ??
          map['Executed'] ??
          map['finished'] ??
          map['Finished'] ??
          map['status'],
    );

    return _ProgressStepInfo(
      title: title.isNotEmpty ? title : '步骤$step',
      step: step,
      executed: executed,
    );
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' ||
          lower == '1' ||
          lower == 'yes' ||
          lower == 'y' ||
          lower == '完成' ||
          lower == '已完成';
    }
    return false;
  }

  List<_ProgressStepInfo> _effectiveProgressSteps() {
    return _progressSteps.isNotEmpty
        ? _progressSteps
        : _cloneDefaultProgressSteps();
  }

  Widget _buildStepProgressBar(int completedIndex) {
    final steps = _effectiveProgressSteps();
    if (steps.isEmpty) return const SizedBox.shrink();

    final safeCompleted =
        completedIndex.clamp(0, steps.length - 1);
    final lastExecutedIndex = steps.lastIndexWhere((s) => s.executed);
    final activeIndex = lastExecutedIndex >= 0
        ? lastExecutedIndex.clamp(0, steps.length - 1)
        : safeCompleted;
    final bool isCrowded = steps.length > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部：节点 + 只在节点之间的线条（首尾线条隐藏但保留占位，保证文字与圆圈垂直对齐）
        Row(
          children: List.generate(steps.length, (index) {
            final bool showLeft = index > 0;
            final bool showRight = index < steps.length - 1;
            final bool isLeftSegmentCompleted = showLeft &&
                steps[index - 1].executed &&
                steps[index].executed;
            final bool isRightSegmentCompleted = showRight &&
                steps[index].executed &&
                steps[index + 1].executed;

            return Expanded(
              child: Row(
                children: [
                  // 左侧线段（第一个节点使用透明颜色保留占位）
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(right: 6),
                      color: showLeft
                          ? (isLeftSegmentCompleted
                              ? const Color(0xFF2BB56F)
                              : const Color(0xFFE0E0E0))
                          : Colors.transparent,
                    ),
                  ),
                  // 节点
                  _buildStepNode(index, activeIndex, steps),
                  // 右侧线段（最后一个节点使用透明颜色保留占位）
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(left: 6),
                      color: showRight
                          ? (isRightSegmentCompleted
                              ? const Color(0xFF2BB56F)
                              : const Color(0xFFE0E0E0))
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        // 下方：每个步骤的文字标签
        Row(
          children: List.generate(steps.length, (index) {
            final bool isCompleted = steps[index].executed;
            final bool isActive = index == activeIndex;
            final Color textColor = isCompleted
                ? Colors.black87
                : (isActive ? const Color(0xFF1E88E5) : Colors.black54);

            return Expanded(
              child: Text(
                steps[index].title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCrowded ? 12 : 14,
                  fontWeight:
                      isCompleted ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepNode(
    int index,
    int activeIndex,
    List<_ProgressStepInfo> steps,
  ) {
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }
    final safeIndex = index.clamp(0, steps.length - 1);
    final bool isCrowded = steps.length > 5;
    final step = steps[safeIndex];
    final bool isCompleted = step.executed;
    final bool isActive = safeIndex == activeIndex;
    final Color borderColor = isCompleted
        ? const Color(0xFF2BB56F)
        : (isActive ? const Color(0xFF1E88E5) : const Color(0xFFB0BEC5));
    final Color fillColor = isCompleted ? borderColor : Colors.white;
    final Color textColor = isCompleted ? Colors.white : borderColor;

    final double size = isCrowded ? 30 : 38;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  // 修改函数签名，添加onTap参数
  Widget _buildFunctionButton(
    String title,
    IconData icon, {
    Color? color,
    VoidCallback? onTap,
  }) {
    // 统一按钮字号，避免“开始/退出”明显偏大
    const double fontSize = 20;
    final isDisabled = _isLoading || onTap == null;

    return SizedBox(
      width: 140,
      height: 90,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap, // 使用传入的onTap回调
          child: Container(
            decoration: BoxDecoration(
              color: color ?? Colors.red,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: HexColor('#A30014')), // 图标颜色保持红色
                  SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'Microsoft YaHei',
                      fontWeight: FontWeight.bold,
                      color: HexColor('#A30014'), // 文字颜色保持红色
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadDisplayManagementData() async {
    if (_isDisplayLoading) return;
    setState(() {
      _isDisplayLoading = true;
    });

    try {
      final result = await SccClientWrapper.querySlogan();
      if (!result.isSuccess) {
        _showMessage(result.msg, isError: true);
        setState(() {
          _sloganTableData = [];
          _sloganBannerItems = [];
          _sloganCheckInItems = [];
          _showSloganTable = false;
          _pendingQuickDisplayItem = null;
          _pendingQuickDisplayType = '';
          _sloganPreviewedRowIndices.clear();
        });
        return;
      }

      final data = result.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        final maybe = data['data'] ?? data['list'] ?? data['items'];
        if (maybe is List) {
          list = maybe;
        }
      }
      final normalized = list.map((e) {
        if (e is Map<String, dynamic>) {
          return {
            ...e,
            'state': true,
            'rowValue': e,
          };
        }
        return {
          'value': e,
          'rowValue': e,
          'state': true,
        };
      }).toList();

      final bannerItems = <dynamic>[];
      final checkInItems = <dynamic>[];
      final sloganItems = <dynamic>[];
      for (final item in normalized) {
        final sloganName = _extractSloganName(item);
        if (sloganName == '会标') {
          bannerItems.add(item);
        } else if (sloganName == '报到情况') {
          checkInItems.add(item);
        } else {
          sloganItems.add(item);
        }
      }

      setState(() {
        _sloganBannerItems = bannerItems;
        _sloganCheckInItems = checkInItems;
        _sloganTableData = sloganItems;
        _showSloganTable = false;
        _pendingQuickDisplayItem = null;
        _pendingQuickDisplayType = '';
        _sloganPreviewedRowIndices.clear();
      });
    } catch (e) {
      _showMessage('标语查询失败: $e', isError: true);
      setState(() {
        _sloganTableData = [];
        _pendingQuickDisplayItem = null;
        _pendingQuickDisplayType = '';
        _sloganPreviewedRowIndices.clear();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDisplayLoading = false;
        });
      }
    }
  }

  String _extractSloganName(dynamic item) {
    if (item is Map) {
      final map = item.cast<String, dynamic>();
      // 标语列表名称只展示后端返回的 SloganName 字段
      return (map['SloganName'] ?? '')
          .toString()
          .trim();
    }
    return '';
  }

  dynamic _extractSloganRowValue(dynamic item) {
    if (item is Map<String, dynamic>) {
      if (item['rowValue'] != null) return item['rowValue'];
      if (item['value'] != null) return item['value'];
    }
    return item;
  }

  Widget _buildDisplayTypeButton({
    required String label,
    required bool enabled,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 34,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? HexColor('#A30014') : Colors.red[400],
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Microsoft YaHei',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _previewQuickDisplayType({
    required dynamic item,
    required String type,
  }) async {
    if (_isDisplayLoading) return;
    await _previewSlogan(item, -1);
    if (!mounted) return;
    setState(() {
      _pendingQuickDisplayItem = item;
      _pendingQuickDisplayType = type;
    });
  }

  Future<void> _confirmQuickDisplayType() async {
    if (_isSendingSlogan || _pendingQuickDisplayItem == null) return;
    if (!_sloganPreviewedRowIndices.contains(-1)) return;
    final value = _extractSloganRowValue(_pendingQuickDisplayItem);
    final jsonData = JsonEncoder().convert(value);
    setState(() {
      _isSendingSlogan = true;
    });
    try {
      final result = await SccClientWrapper.sendSlogan(data: jsonData);
      if (result.isSuccess && result.data == true) {
        _showMessage('发送成功');
      } else {
        _showMessage(result.msg.isNotEmpty ? result.msg : '发送失败', isError: true);
      }
    } catch (e) {
      _showMessage('发送失败: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isSendingSlogan = false;
      });
    }
  }

  Future<void> _previewSlogan(dynamic item, int rowIndex) async {
    // 取消上一次预览刷新（等同 clearInterval）
    _sloganPreviewTimer?.cancel();
    _sloganPreviewTimer = null;

    // 只取 Content/content 内的 HTML 模板
    final template = _extractSloganHtmlOnlyContent(item);
    if (!mounted) return;

    // 解析 Parameters（背景色/竖排）
    final params = _extractSloganParameters(item);
    final bgColorStr = params['Color']?.toString() ?? '';

    Color bg = Colors.white;
    if (bgColorStr.startsWith('#') && bgColorStr.length >= 4) {
      try {
        bg = HexColor(bgColorStr);
      } catch (_) {}
    }

    // 表格行高亮/状态（vue: this.tableData[rowindex].state=false）
    setState(() {
      for (int i = 0; i < _sloganTableData.length; i++) {
        final row = _sloganTableData[i];
        if (row is Map<String, dynamic>) {
          row['state'] = i != rowIndex;
        }
      }
      _sloganPreviewBackground = bg;
      _isSloganPreviewVisible = template.isNotEmpty;
      _sloganPreviewedRowIndices.add(rowIndex);
    });

    // 取消旧的定时刷新：频繁 setState 会导致 Html/<img> 反复重建而闪烁
    _sloganPreviewTimer?.cancel();
    _sloganPreviewTimer = null;

    final freeze = _shouldFreezeSloganPreview(template);
    final resolved = template.isNotEmpty ? _resolveSloganTemplate(template) : _sloganPreviewText;
    final frozenImageSrc = _extractFrozenPreviewImageSrc(resolved);

    if (!mounted) return;
    setState(() {
      _notificationText = ''; // 不再输出纯文本，避免重复展示
      _sloganPreviewTemplate = template;
      _sloganPreviewFreeze = freeze;
      // 兼容：如果模板为空，仍然显示解析出的静态文本
      _sloganPreviewText = template.isNotEmpty ? '' : _sloganPreviewText;
      _sloganPreviewResolvedHtml = resolved;
      _frozenSloganPreviewWidget = (freeze && frozenImageSrc != null)
          ? _buildFrozenImageWidget(frozenImageSrc, resolved)
          : null;
    });
  }

  bool _shouldFreezeSloganPreview(String template) {
    final t = template.toLowerCase();
    final hasImg = t.contains('<img') || t.contains('background-image') || t.contains('data:image');
    // 只要是图片类标语，一律冻结，不参与后续 WS 数据驱动的模板更新。
    return hasImg;
  }

  String _resolveSloganTemplate(String template) {
    if (template.trim().isEmpty) return '';

    // 会议标题拆分 oneLeve/twoLeve（vue: this.title.split("@")）
    final rawTitle = (_meetingTitle.isNotEmpty ? _meetingTitle : widget.meetingName);
    final parts = rawTitle.split('@');
    final oneLeve = parts.isNotEmpty ? parts[0] : '';
    final twoLeve = parts.length > 1 ? parts[1] : '';

    // 数字来源：用当前统计（应到/未到），并按 vue 逻辑计算 a=shouldarrive-notyet
    final shouldArrive = attendStats['应到'] ?? 0;
    final notYet = attendStats['未到'] ?? 0;
    final a = shouldArrive - notYet;

    final width = shouldArrive.toString().length;
    String padNum(int n) {
      final s = n.toString();
      if (s.length >= width) return s;
      return '\u2000' * (width - s.length) + s;
    }

    return template
        .replaceAll('{0}', oneLeve)
        .replaceAll('{1}', twoLeve)
        .replaceAll('{2}', padNum(shouldArrive))
        .replaceAll('{3}', padNum(a))
        .replaceAll('{4}', padNum(notYet));
  }

  void _updateSloganPreviewIfNeeded() {
    if (!_isSloganPreviewVisible) return;
    if (_sloganPreviewFreeze) return;
    final template = _sloganPreviewTemplate;
    if (template.trim().isEmpty) return;

    final next = _resolveSloganTemplate(template);
    if (next == _sloganPreviewResolvedHtml) return;
    _sloganPreviewResolvedHtml = next;
  }

  String? _extractSingleImageSrc(String html) {
    final match = RegExp(
      '<img[^>]*src\\s*=\\s*["\\\']([^"\\\']+)["\\\']',
      caseSensitive: false,
    ).firstMatch(html);
    final src = match?.group(1)?.trim() ?? '';
    return src.isEmpty ? null : src;
  }

  String? _extractBackgroundImageSrc(String html) {
    final match = RegExp(
      'background(?:-image)?\\s*:\\s*url\\((["\\\']?)([^"\\\')]+)\\1\\)',
      caseSensitive: false,
    ).firstMatch(html);
    final src = match?.group(2)?.trim() ?? '';
    return src.isEmpty ? null : src;
  }

  String? _extractFrozenPreviewImageSrc(String html) {
    return _extractSingleImageSrc(html) ?? _extractBackgroundImageSrc(html);
  }

  Widget _buildFrozenImageWidget(String imageSrc, String fallbackData) {
    return RepaintBoundary(
      child: SizedBox.expand(
        child: Image.network(
          imageSrc,
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) {
            return Html(
              data: fallbackData,
              style: {
                'html': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                'img': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  display: Display.block,
                ),
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSloganPreviewContent(String data) {
    final imageSrc = _extractFrozenPreviewImageSrc(data);
    if (_sloganPreviewFreeze && imageSrc != null) {
      _frozenSloganPreviewWidget ??= _buildFrozenImageWidget(imageSrc, data);
      return _frozenSloganPreviewWidget!;
    }

    return Html(
      data: data,
      style: {
        'html': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontStyle: FontStyle.normal,
        ),
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontStyle: FontStyle.normal,
        ),
        'i': Style(
          fontStyle: FontStyle.normal,
        ),
        'em': Style(
          fontStyle: FontStyle.normal,
        ),
        'img': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          display: Display.block,
        ),
      },
    );
  }

  String _extractSloganHtmlOnlyContent(dynamic item) {
    if (item == null) return '';
    if (item is! Map) return '';

    final map = item.cast<String, dynamic>();

    // content 可能为 Content / content / html 等大小写不同的字段
    dynamic c = map['content'] ?? map['Content'] ?? map['html'] ?? map['HTML'];
    final extracted = _normalizeHtmlValue(c);
    if (extracted.isNotEmpty) {
      final decoded = _decodeHtmlEntitiesIfNeeded(extracted);
      return _normalizeSloganFontStyle(_normalizeSloganFontFamily(decoded));
    }

    // 有些后端可能把整段对象放在 data/content 字段里为 JSON 字符串
    final dataCandidate = map['data'] ?? map['value'];
    if (dataCandidate is String) {
      final s = dataCandidate.trim();
      if (s.startsWith('{') && s.endsWith('}')) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is Map) {
            final inner = _normalizeHtmlValue(decoded['content']);
            if (inner.isNotEmpty) {
              final decoded = _decodeHtmlEntitiesIfNeeded(inner);
              return _normalizeSloganFontStyle(_normalizeSloganFontFamily(decoded));
            }
          }
        } catch (_) {
          // ignore
        }
      }
    }

    return '';
  }

  Map<String, dynamic> _extractSloganParameters(dynamic item) {
    if (item is! Map) return <String, dynamic>{};
    final map = item.cast<String, dynamic>();
    final raw = map['Parameters'] ?? map['parameters'] ?? map['PARAMETERS'];
    if (raw is Map) {
      return raw.cast<String, dynamic>();
    }
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.cast<String, dynamic>();
        }
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  String _normalizeHtmlValue(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is num) return v.toString();
    if (v is bool) return v.toString();
    if (v is List) return v.map((e) => _normalizeHtmlValue(e)).join('');
    if (v is Map) {
      final m = v.cast<String, dynamic>();
      final wanted = <String>{'content', 'html', 'value', 'text', 'data'};
      for (final entry in m.entries) {
        final keyLower = entry.key.toLowerCase();
        if (wanted.contains(keyLower)) {
          final inner = _normalizeHtmlValue(entry.value);
          if (inner.isNotEmpty) return inner;
        }
      }
      // 兜底不返回 map.toString()，避免把整行 JSON 当 HTML 渲染
      return '';
    }
    return v.toString();
  }

  String _decodeHtmlEntitiesIfNeeded(String s) {
    if (!s.contains('&lt;') && !s.contains('&gt;') && !s.contains('&amp;')) {
      return s;
    }
    // 只做常见实体解码，避免把后端内容误处理
    return s
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');
  }

  String _normalizeSloganFontFamily(String html) {
    if (html.isEmpty) return html;
    var result = html;
    const aliases = <String>[
      '⽅正⼩标宋_GBK',
      '方正小标宋_GBK',
      '方正小标宋',
      'FZ XiaoBiaoSong GBK',
      'FZXiaoBiaoSong_GBK',
    ];
    for (final alias in aliases) {
      result = result.replaceAll(alias, 'FZXBYS');
    }
    // 容错：把 face 属性里剩余的“小标宋”写法统一映射
    result = result.replaceAllMapped(
      RegExp("face\\s*=\\s*[\"']([^\"']*小标宋[^\"']*)[\"']", caseSensitive: false),
      (_) => 'face="FZXBYS"',
    );
    // 容错：style 内 font-family 的“小标宋”写法统一映射
    result = result.replaceAllMapped(
      RegExp("font-family\\s*:\\s*([^;\"]*小标宋[^;\"]*)", caseSensitive: false),
      (_) => 'font-family:FZXBYS',
    );
    return result;
  }

  String _normalizeSloganFontStyle(String html) {
    if (html.isEmpty) return html;
    return html
        .replaceAll(RegExp(r'</?\s*i\b[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</?\s*em\b[^>]*>', caseSensitive: false), '')
        .replaceAll(
          RegExp(r'font-style\s*:\s*italic', caseSensitive: false),
          'font-style: normal',
        )
        .replaceAll(
          RegExp(r'font-style\s*:\s*oblique', caseSensitive: false),
          'font-style: normal',
        );
  }

  Future<void> _confirmDisplaySlogan(dynamic item, int rowIndex) async {
    if (_isSendingSlogan ||
        _isDisplayLoading ||
        !_sloganPreviewedRowIndices.contains(rowIndex)) {
      return;
    }
    final value = _extractSloganRowValue(item);
    final jsonData = JsonEncoder().convert(value);

    if (mounted) {
      setState(() => _isSendingSlogan = true);
    }

    try {
      final result = await SccClientWrapper.sendSlogan(data: jsonData);
      if (result.isSuccess && result.data == true) {
        if (!mounted) return;
        _showMessage('发送成功');
      } else {
        if (!mounted) return;
        _showMessage(result.msg.isNotEmpty ? result.msg : '发送失败',
            isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('发送失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSendingSlogan = false);
      }
    }
  }

  Widget _buildSloganRow(int index, dynamic item) {
    final name = _extractSloganName(item);
    final displayText = name.isNotEmpty ? name : '—';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Microsoft YaHei', fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayText,
              style: TextStyle(fontFamily: 'Microsoft YaHei', fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _isSendingSlogan
                      ? null
                      : () => _previewSlogan(item, index),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    '预览',
                    style: TextStyle(
                      fontFamily: 'Microsoft YaHei',
                      fontSize: 12,
                      color: HexColor('#A30014'),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: (_isSendingSlogan ||
                          !_sloganPreviewedRowIndices.contains(index))
                      ? null
                      : () => _confirmDisplaySlogan(item, index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor('#A30014'),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 0,
                  ),
                  child: Text(
                    '确认显示',
                    style: TextStyle(
                      fontFamily: 'Microsoft YaHei',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
          // 顶部宽幅图片
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red[700],
              image: DecorationImage(
                image: AssetImage('assets/images/title.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 下半部分
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                image: DecorationImage(
                  image: AssetImage('assets/images/dise.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.white.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // 主标题
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Center(
                        child: Text(
                          _meetingTitleDisplay,
                          style: TextStyle(
                            fontFamily: 'FZXBYS',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 237, 252, 32),
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 0),

                    // 统计卡片区域 - 使用正确的样式
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('出席', attendStats)),
                        SizedBox(width: 12),
                        Expanded(child: _buildStatCard('列席', guestStats)),
                      ],
                    ),

                    SizedBox(height: 12),

                    // 主体内容区域
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 左侧内容区域
                          Expanded(
                            flex: 3,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: TabBar(
                                      controller: _tabController,
                                      labelColor: HexColor('#A30014'),
                                      unselectedLabelColor: Colors.grey,
                                      indicatorColor: HexColor('#A30014'),
                                      tabs: [
                                        Tab(
                                          child: Text(
                                            '报到情况',
                                            style: TextStyle(fontFamily: 'Microsoft YaHei'),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            '设备点位图',
                                            style: TextStyle(
                                              fontFamily: 'Microsoft YaHei',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(height: 1),
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildAttendList(),
                                        _buildDeviceGrid(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // 右侧控制面板
                          // 替换右侧控制面板的代码
                          // 替换原有的右侧控制面板代码
                          Container(
                            width: 600,
                            child: Column(
                              children: [
                                // 标签切换卡片
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      // 标签栏
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            // 会议管理标签（可点击）
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  _sloganPreviewTimer?.cancel();
                                                  _sloganPreviewTimer = null;
                                                  setState(() {
                                                    _isMeetingManagementSelected =
                                                        true;
                                                    // 切到会议管理时清空通知与预览
                                                    _notificationText = '';
                                                    _isSloganPreviewVisible = false;
                                                    _sloganPreviewText = '';
                                                    _frozenSloganPreviewWidget = null;
                                                    _showSloganTable = false;
                                                    _pendingQuickDisplayItem = null;
                                                    _pendingQuickDisplayType = '';
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color:
                                                            _isMeetingManagementSelected
                                                            ? HexColor(
                                                                '#A30014',
                                                              )
                                                            : HexColor(
                                                                '#A30014',
                                                              ),
                                                        width:
                                                            _isMeetingManagementSelected
                                                            ? 3
                                                            : 1,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    child: Text(
                                                      '会议管理',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Microsoft YaHei',
                                                        fontWeight:
                                                            _isMeetingManagementSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        color:
                                                            _isMeetingManagementSelected
                                                            ? Colors.red[700]
                                                            : Colors.grey[600],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // 显示管理标签（可点击）
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isMeetingManagementSelected =
                                                        false;
                                                  });
                                                  _loadDisplayManagementData();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color:
                                                            !_isMeetingManagementSelected
                                                            ? Colors.red[700]!
                                                            : Colors.grey[300]!,
                                                        width:
                                                            !_isMeetingManagementSelected
                                                            ? 3
                                                            : 1,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    child: Text(
                                                      '显示管理',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Microsoft YaHei',
                                                        fontWeight:
                                                            !_isMeetingManagementSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        color:
                                                            !_isMeetingManagementSelected
                                                            ? Colors.red[700]
                                                            : Colors.grey[600],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 动态内容区域
                                      _isMeetingManagementSelected
                                          ? _buildMeetingManagementContent()
                                          : _buildDisplayManagementContent(),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 3),

                                // 通知信息区域（保持不变）
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '通知信息',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Microsoft YaHei',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Expanded(
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: (_isSloganPreviewVisible &&
                                                      (_sloganPreviewFreeze ||
                                                          _notificationText
                                                              .trim()
                                                              .isEmpty))
                                                  // 仅预览时：直接贴顶显示，不走滚动容器，避免出现空白
                                                  ? Builder(
                                                      builder: (context) {
                                                        final sloganHtml =
                                                            _sloganPreviewResolvedHtml;
                                                        final data = sloganHtml
                                                                .isNotEmpty
                                                            ? sloganHtml
                                                            : '<div style="text-align:center; color:#A30014; font-weight:bold;">—</div>';
                                                        return SizedBox(
                                                      width: double.infinity,
                                                      child: AspectRatio(
                                                        aspectRatio: 4 / 3,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            border: Border.all(
                                                              color: HexColor(
                                                                  '#A30014'),
                                                            ),
                                                            color:
                                                                _sloganPreviewBackground,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          child:
                                                              _buildSloganPreviewContent(
                                                            data,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                      },
                                                    )
                                                  : SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          MixedFontText(
                                                            _notificationText
                                                                    .trim()
                                                                    .isNotEmpty
                                                                ? _notificationText
                                                                : _defaultMeetingStatusText,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Microsoft YaHei',
                                                            ),
                                                          ),
                                                          if (_isSloganPreviewVisible)
                                                            Builder(
                                                              builder:
                                                                  (context) {
                                                                final sloganHtml =
                                                                    _sloganPreviewResolvedHtml;
                                                                final data = sloganHtml
                                                                        .isNotEmpty
                                                                    ? sloganHtml
                                                                    : '<div style="text-align:center; color:#A30014; font-weight:bold;">—</div>';
                                                                return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 10),
                                                              child: SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    AspectRatio(
                                                                  aspectRatio:
                                                                      4 / 3,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: HexColor(
                                                                            '#A30014'),
                                                                      ),
                                                                      color:
                                                                          _sloganPreviewBackground,
                                                                    ),
                                                                    padding: const EdgeInsets
                                                                        .all(8),
                                                                    child:
                                                                        _buildSloganPreviewContent(
                                                                      data,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
            ],
          ),
          // 全局 loading：用于“数据检查/导入/发送”等需要等待的操作
          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: Center(
                    child: Card(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '正在处理...',
                              style: TextStyle(
                                fontFamily: 'Microsoft YaHei',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: HexColor('#A30014'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 站点选择对话框（列表展示设备名称，返回值仍为 IP 列表供接口使用）
class _StationSelectionDialog extends StatefulWidget {
  final List<Map<String, String>> stations;
  final String title;

  const _StationSelectionDialog({
    required this.stations,
    required this.title,
  });

  @override
  State<_StationSelectionDialog> createState() => _StationSelectionDialogState();
}

class _StationSelectionDialogState extends State<_StationSelectionDialog> {
  final Set<String> _selectedStations = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: TextStyle(fontFamily: 'Microsoft YaHei')),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 400),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.stations.length,
          itemBuilder: (context, index) {
            final station = widget.stations[index];
            final ip = station['ip'] ?? '';
            final name = station['name'] ?? ip;
            final isSelected = _selectedStations.contains(ip);
            return CheckboxListTile(
              title: Text(
                name,
                style: TextStyle(fontFamily: 'Microsoft YaHei'),
              ),
              subtitle: ip.isNotEmpty
                  ? Text(
                      ip,
                      style: TextStyle(
                        fontFamily: 'Microsoft YaHei',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    )
                  : null,
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    if (ip.isNotEmpty) _selectedStations.add(ip);
                  } else {
                    _selectedStations.remove(ip);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消', style: TextStyle(fontFamily: 'Microsoft YaHei')),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedStations.toList());
          },
          child: Text('确定', style: TextStyle(fontFamily: 'Microsoft YaHei', color: Colors.red)),
        ),
      ],
    );
  }
}

// 数据检查对话框（包含设备选择和表选择）
class _DataCheckDialog extends StatefulWidget {
  final List<Map<String, String>> stations;

  const _DataCheckDialog({
    required this.stations,
  });

  @override
  State<_DataCheckDialog> createState() => _DataCheckDialogState();
}

class _DataCheckDialogState extends State<_DataCheckDialog> {
  final Set<String> _selectedStations = {};
  
  // 表选项配置：label -> 显示名称
  final Map<String, String> _tableOptions = {
    'meet': '会议表',
    'delegateregister': '代表表',
    'personinformation': '人员基础信息表',
  };
  final Set<String> _selectedTables = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('数据检查', style: TextStyle(fontFamily: 'Microsoft YaHei')),
      content: Container(
        width: 600, // 设置固定宽度以便左右布局
        constraints: BoxConstraints(maxHeight: 400),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：设备选择部分
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '选择设备',
                        style: TextStyle(
                          fontFamily: 'Microsoft YaHei',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            final allIps = widget.stations
                                .map((e) => e['ip'] ?? '')
                                .where((ip) => ip.isNotEmpty)
                                .toSet();
                            if (_selectedStations.length == allIps.length &&
                                allIps.isNotEmpty) {
                              _selectedStations.clear();
                            } else {
                              _selectedStations
                                ..clear()
                                ..addAll(allIps);
                            }
                          });
                        },
                        child: Text(
                          _selectedStations.length ==
                                      widget.stations
                                          .map((e) => e['ip'] ?? '')
                                          .where((ip) => ip.isNotEmpty)
                                          .toSet()
                                          .length &&
                                  widget.stations.isNotEmpty
                              ? '取消全选'
                              : '全选',
                          style: TextStyle(
                            fontFamily: 'Microsoft YaHei',
                            color: HexColor('#A30014'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.stations.length,
                        itemBuilder: (context, index) {
                          final station = widget.stations[index];
                          final ip = station['ip'] ?? '';
                          final name = station['name'] ?? ip;
                          final isSelected = _selectedStations.contains(ip);
                          return CheckboxListTile(
                            title: Text(
                              name,
                              style: TextStyle(fontFamily: 'Microsoft YaHei'),
                            ),
                            subtitle: ip.isNotEmpty
                                ? Text(
                                    ip,
                                    style: TextStyle(
                                      fontFamily: 'Microsoft YaHei',
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : null,
                            value: isSelected,
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  if (ip.isNotEmpty) _selectedStations.add(ip);
                                } else {
                                  _selectedStations.remove(ip);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 中间分隔线
            Container(
              width: 1,
              margin: EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.shade300,
            ),
            // 右侧：表选择部分
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择表',
                    style: TextStyle(
                      fontFamily: 'Microsoft YaHei',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: _tableOptions.entries.map((entry) {
                          final label = entry.key;
                          final displayName = entry.value;
                          final isSelected = _selectedTables.contains(label);
                          return CheckboxListTile(
                            title: Text(displayName, style: TextStyle(fontFamily: 'Microsoft YaHei')),
                            value: isSelected,
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedTables.add(label);
                                } else {
                                  _selectedTables.remove(label);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消', style: TextStyle(fontFamily: 'Microsoft YaHei')),
        ),
        TextButton(
          onPressed: () {
            if (_selectedStations.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('请至少选择一个设备', style: TextStyle(fontFamily: 'Microsoft YaHei'))),
              );
              return;
            }
            if (_selectedTables.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('请至少选择一个表', style: TextStyle(fontFamily: 'Microsoft YaHei'))),
              );
              return;
            }
            Navigator.of(context).pop({
              'stations': _selectedStations.toList(),
              'tables': _selectedTables.toList(),
            });
          },
          child: Text('确定', style: TextStyle(fontFamily: 'Microsoft YaHei', color: Colors.red)),
        ),
      ],
    );
  }
}
