import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:file_picker/file_picker.dart';
import '../scc/scc_client.dart';

// 设备节点数据模型
class DeviceNode {
  final String id;
  final String stationName;
  final String? ip;
  final String? nodeID;
  final List<DeviceNode> children;
  final String? processType;
  final int? clientStatus;
  final String? facilityTypeName;
  int? attendNum;
  int? specialNum;

  DeviceNode({
    required this.id,
    required this.stationName,
    this.ip,
    this.nodeID,
    this.children = const [],
    this.processType,
    this.clientStatus,
    this.facilityTypeName,
    this.attendNum,
    this.specialNum,
  });

  factory DeviceNode.fromJson(Map<String, dynamic> json) {
    return DeviceNode(
      id: json['NodeID'] ?? json['id'] ?? '',
      stationName: json['StationName'] ?? json['stationName'] ?? '',
      ip: json['IP'] ?? json['ip'],
      nodeID: json['NodeID'] ?? json['nodeID'],
      processType: json['ProcessType'] ?? json['processType'],
      clientStatus: json['ClientStatus'] ?? json['clientStatus'],
      facilityTypeName: json['FacilityTypeName'] ?? json['facilityTypeName'],
      attendNum: json['AttendNum'] ?? json['attendNum'],
      specialNum: json['SpecialNum'] ?? json['specialNum'],
    );
  }
}

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

  // 会议信息
  String _meetingTitle = '';
  int _meetStatus = 0; // 0: 未开始, 1: 进行中, 2: 已结束
  bool _canStart = true; // 是否可以开始会议

  // 统计数据
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

  // 设备列表
  List<DeviceNode> _deviceTree = [];
  List<DeviceNode> _clientList = [];
  List<Map<String, dynamic>> _stationNums = []; // 站点人数统计
  Set<String> _selectedDeviceIds = {}; // 选中的设备ID

  // 通知信息
  String _notificationMessage = '';

  // 定时器用于轮询数据
  Timer? _meetInfoTimer;
  Timer? _clientTimer;
  Timer? _stationNumTimer;

  // 数据检查相关
  List<String> _checkList = []; // 选中的表
  List<Map<String, dynamic>> _checkResultList = []; // 检查结果
  bool _isChecking = false;
  Timer? _checkTimer;

  // 标语相关
  List<Map<String, dynamic>> _sloganList = [];
  int _selectedSloganIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _meetingTitle = widget.meetingName;
    _loadMeetingInfo();
    _loadClientList();
    _startPolling();
    // U盘检测改为按需检测，只在点击文件选取按钮时才检测
  }

  @override
  void dispose() {
    _tabController.dispose();
    _meetInfoTimer?.cancel();
    _clientTimer?.cancel();
    _stationNumTimer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  // 加载会议信息
  Future<void> _loadMeetingInfo() async {
    if (widget.meetId == null || widget.meetId!.isEmpty) return;
    
    final result = await SccClientWrapper.queryMeetInfo(widget.meetId!);
    if (result.isSuccess && result.data != null) {
      final data = result.data!;
      setState(() {
        // 解析会议标题
        if (data['onMeet'] != null && data['onMeet']['Content'] != null) {
          _meetingTitle = data['onMeet']['Content'].toString().replaceAll('@', '-');
        }
        
        // 解析会议状态
        if (data['serverStatus'] != null && data['serverStatus']['Meetstatus'] != null) {
          _meetStatus = data['serverStatus']['Meetstatus'] as int;
          _canStart = _meetStatus != 1; // 会议未开始时可以开始
        }
        
        // 解析统计数据
        if (data['nums'] != null) {
          final nums = data['nums'] as Map<String, dynamic>;
          _updateStats(nums);
        }
      });
    }
  }

  // 加载客户端列表
  Future<void> _loadClientList() async {
    final result = await SccClientWrapper.queryClient();
    
    if (result.isSuccess && result.data != null) {
      final clientData = result.data as List<dynamic>;
      
      final List<DeviceNode> clients = [];
      
      for (var item in clientData) {
        final jsonItem = item as Map<String, dynamic>;
        final node = DeviceNode.fromJson(jsonItem);
        
        // 从返回的数据中提取人数信息（如果存在）
        if (jsonItem['AttendNum'] != null || jsonItem['SpecialNum'] != null) {
          final stationInfo = {
            'Station': node.ip,
            'AttendNum': jsonItem['AttendNum'] ?? 0,
            'SpecialNum': jsonItem['SpecialNum'] ?? 0,
          };
          // 更新站点人数列表
          final existingIndex = _stationNums.indexWhere((s) => s['Station'] == node.ip);
          if (existingIndex >= 0) {
            _stationNums[existingIndex] = stationInfo;
          } else {
            _stationNums.add(stationInfo);
          }
        }
        
        clients.add(node);
      }
      
      setState(() {
        _clientList = clients;
        _updateDeviceTree();
      });
    }
  }

  // 开始轮询数据
  void _startPolling() {
    // 轮询会议信息（每2秒）
    _meetInfoTimer?.cancel();
    _meetInfoTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (widget.meetId != null && widget.meetId!.isNotEmpty) {
        _loadMeetingInfo();
      }
    });
    
    // 轮询客户端列表（每3秒）
    _clientTimer?.cancel();
    _clientTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _loadClientList();
    });
    
    // 轮询站点人数（每2秒）
    _stationNumTimer?.cancel();
    _stationNumTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _loadStationNums();
    });
  }

  // 加载站点人数（如果需要单独的接口）
  Future<void> _loadStationNums() async {
    // 站点人数信息通常已经包含在 queryClient 或 queryMeetInfo 的返回数据中
    // 如果需要单独的接口来获取站点人数，可以在这里实现
    // 目前人数信息已经在 _loadClientList 中处理
  }


  // 获取可移动驱动器列表（跨平台：Windows/Linux/macOS）
  Future<List<String>> _getRemovableDrives() async {
    final removableDrives = <String>[];
    
    try {
      if (Platform.isWindows) {
        // Windows系统：从E:到Z:检测可移动驱动器（跳过C:和D:）
        for (var letter in 'EFGHIJKLMNOPQRSTUVWXYZ'.codeUnits) {
          final drive = '${String.fromCharCode(letter)}:\\';
          final driveDir = Directory(drive);
          
          if (await driveDir.exists()) {
            try {
              // 尝试读取目录，如果成功，可能是可移动驱动器
              await driveDir.list().first.timeout(Duration(milliseconds: 100));
              removableDrives.add(drive);
            } catch (e) {
              // 如果无法访问，跳过
              continue;
            }
          }
        }
      } else if (Platform.isLinux) {
        // Linux系统：检测常见的U盘挂载点
        final mountPaths = [
          '/media/${Platform.environment['USER'] ?? 'user'}',
          '/run/media/${Platform.environment['USER'] ?? 'user'}',
          '/mnt',
        ];
        
        for (var mountPath in mountPaths) {
          final mountDir = Directory(mountPath);
          if (await mountDir.exists()) {
            try {
              // 列出挂载目录下的所有子目录
              await for (var entity in mountDir.list()) {
                if (entity is Directory) {
                  try {
                    // 尝试访问，如果能访问且不是系统目录，可能是U盘
                    await entity.list().first.timeout(Duration(milliseconds: 100));
                    final path = entity.path;
                    // 排除隐藏目录和系统目录
                    if (!path.split('/').last.startsWith('.')) {
                      removableDrives.add(path);
                    }
                  } catch (e) {
                    // 无法访问，跳过
                    continue;
                  }
                }
              }
            } catch (e) {
              // 目录读取失败，跳过
              continue;
            }
          }
        }
        
        // 如果没有找到，也尝试直接检测 /media 下的所有用户目录
        final mediaDir = Directory('/media');
        if (await mediaDir.exists()) {
          try {
            await for (var userDir in mediaDir.list()) {
              if (userDir is Directory) {
                try {
                  await for (var device in userDir.list()) {
                    if (device is Directory) {
                      try {
                        await device.list().first.timeout(Duration(milliseconds: 100));
                        removableDrives.add(device.path);
                      } catch (e) {
                        continue;
                      }
                    }
                  }
                } catch (e) {
                  continue;
                }
              }
            }
          } catch (e) {
            // 忽略错误
          }
        }
      } else if (Platform.isMacOS) {
        // macOS系统：检测 /Volumes 目录下的挂载点
        final volumesDir = Directory('/Volumes');
        if (await volumesDir.exists()) {
          try {
            await for (var entity in volumesDir.list()) {
              if (entity is Directory) {
                try {
                  // 排除系统卷（通常是 macOS、Macintosh HD 等）
                  final name = entity.path.split('/').last;
                  if (name != 'Macintosh HD' && !name.startsWith('.')) {
                    await entity.list().first.timeout(Duration(milliseconds: 100));
                    removableDrives.add(entity.path);
                  }
                } catch (e) {
                  continue;
                }
              }
            }
          } catch (e) {
            // 忽略错误
          }
        }
      }
      
      // 去重
      return removableDrives.toSet().toList();
    } catch (e) {
      return removableDrives;
    }
  }

  // 查找并上传第一个txt文件
  Future<File?> _findFirstTxtFile(Directory dir) async {
    try {
      final files = dir.listSync(recursive: false);
      
      for (var entity in files) {
        if (entity is File) {
          final fileName = entity.path.split(Platform.pathSeparator).last.toLowerCase();
          
          // 检查是否是txt文件
          if (fileName.endsWith('.txt')) {
            return entity;
          }
        }
      }
    } catch (e) {
    }
    return null;
  }

  // 上传文件
  Future<void> _uploadFile(File file) async {
    try {
      final fileData = await file.readAsBytes();
      final fileName = file.path.split(Platform.pathSeparator).last;
      
      final uploadResult = await SccClientWrapper.importRecord(fileData);
      if (uploadResult.isSuccess) {
        setState(() {
          _notificationMessage = '文件上传成功: $fileName - ${DateTime.now().toString().substring(0, 19)}';
        });
        _showMessage('文件上传成功: $fileName');
      } else {
        setState(() {
          _notificationMessage = '文件上传失败: $fileName - ${uploadResult.msg}';
        });
        _showMessage('文件上传失败: ${uploadResult.msg}', isError: true);
      }
    } catch (e) {
      _showMessage('读取文件失败: $e', isError: true);
    }
  }

  // 更新设备树
  void _updateDeviceTree() {
    final List<DeviceNode> frontEndDevices = [];
    final List<DeviceNode> centerDevices = [];
    
    for (var node in _clientList) {
      if (node.facilityTypeName == '报到终端') {
        if (node.ip != null && node.ip!.contains('1030')) {
          // 地垫设备
          final didianNode = DeviceNode(
            id: node.id,
            stationName: node.stationName,
            ip: node.ip,
            nodeID: node.nodeID,
            processType: 'didian',
            clientStatus: node.clientStatus,
            facilityTypeName: node.facilityTypeName,
            attendNum: _getAttendNum(node.ip),
            specialNum: _getSpecialNum(node.ip),
          );
          frontEndDevices.add(didianNode);
        } else {
          // 客户端设备
          final clientNode = DeviceNode(
            id: node.id,
            stationName: node.stationName,
            ip: node.ip,
            nodeID: node.nodeID,
            processType: 'Client',
            clientStatus: node.clientStatus,
            facilityTypeName: node.facilityTypeName,
            attendNum: _getAttendNum(node.ip),
            specialNum: _getSpecialNum(node.ip),
          );
          frontEndDevices.add(clientNode);
        }
      } else if (node.facilityTypeName != null) {
        // 服务器设备或其他类型（可能是机架设备）
        // 判断是否是机架设备：根据 facilityTypeName 或其他特征
        String processType = 'Server';
        if (node.facilityTypeName!.contains('机架') || 
            node.facilityTypeName!.contains('会议厅') ||
            node.stationName.contains('厅')) {
          processType = 'rack';
        }
        
        final serverNode = DeviceNode(
          id: node.id,
          stationName: node.stationName,
          ip: node.ip,
          nodeID: node.nodeID,
          processType: processType,
          clientStatus: node.clientStatus,
          facilityTypeName: node.facilityTypeName,
          attendNum: _getAttendNum(node.ip),
          specialNum: _getSpecialNum(node.ip),
        );
        
        if (processType == 'rack') {
          frontEndDevices.add(serverNode);
        } else {
          centerDevices.add(serverNode);
        }
      } else {
        // 默认作为服务器设备
        final serverNode = DeviceNode(
          id: node.id,
          stationName: node.stationName,
          ip: node.ip,
          nodeID: node.nodeID,
          processType: 'Server',
          clientStatus: node.clientStatus,
          facilityTypeName: node.facilityTypeName,
          attendNum: _getAttendNum(node.ip),
          specialNum: _getSpecialNum(node.ip),
        );
        centerDevices.add(serverNode);
      }
    }
    
    _deviceTree = [
      DeviceNode(
        id: '1',
        stationName: '前端设备',
        children: frontEndDevices,
      ),
      DeviceNode(
        id: '2',
        stationName: '中心管理端',
        children: centerDevices,
      ),
    ];
  }

  // 获取出席人数
  int _getAttendNum(String? ip) {
    if (ip == null) return 0;
    for (var station in _stationNums) {
      if (station['Station'] == ip) {
        return station['AttendNum'] ?? 0;
      }
    }
    return 0;
  }

  // 获取列席人数
  int _getSpecialNum(String? ip) {
    if (ip == null) return 0;
    for (var station in _stationNums) {
      if (station['Station'] == ip) {
        return station['SpecialNum'] ?? 0;
      }
    }
    return 0;
  }

  // 更新客户端状态
  void _updateClientStatus(String nodeID, int newStatus) {
    _clientList = _clientList.map((node) {
      if (node.nodeID == nodeID) {
        return DeviceNode(
          id: node.id,
          stationName: node.stationName,
          ip: node.ip,
          nodeID: node.nodeID,
          processType: node.processType,
          clientStatus: newStatus,
          facilityTypeName: node.facilityTypeName,
        );
      }
      return node;
    }).toList();
  }

  // 更新统计数据
  void _updateStats(Map<String, dynamic> nums) {
    final personNum = nums['Personnum'] ?? 0;
    final personAttendanceNum = nums['Personattendancenum'] ?? 0;
    final personLeaveNum = nums['Personleavenum'] ?? 0;
    final notYet = personNum - personAttendanceNum;
    final realDeficit = personNum - personAttendanceNum - personLeaveNum;
    
    attendStats = {
      '应到': personNum,
      '实到': personAttendanceNum,
      '未到': notYet,
      '请假': personLeaveNum,
      '实缺': realDeficit,
    };
    
    final specialNum = nums['Specialnum'] ?? 0;
    final specialAttendanceNum = nums['Specialnattendancenum'] ?? 0;
    final specialLeaveNum = nums['Specialleavenum'] ?? 0;
    final specialNotYet = specialNum - specialAttendanceNum;
    final specialRealDeficit = specialNum - specialAttendanceNum - specialLeaveNum;
    
    guestStats = {
      '应到': specialNum,
      '实到': specialAttendanceNum,
      '未到': specialNotYet,
      '请假': specialLeaveNum,
      '实缺': specialRealDeficit,
    };
  }


  // 开始会议
  Future<void> _startMeeting() async {
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID为空', isError: true);
      return;
    }
    
    final result = await SccClientWrapper.startMeet(widget.meetId!);
    if (result.isSuccess) {
      setState(() {
        _canStart = false;
        _meetStatus = 1;
      });
      _showMessage('$_meetingTitle 会议即将开始');
    } else {
      _showMessage(result.msg, isError: true);
    }
  }

  // 结束会议
  Future<void> _endMeeting() async {
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID为空', isError: true);
      return;
    }
    
    final result = await SccClientWrapper.endMeet(widget.meetId!);
    if (result.isSuccess) {
      setState(() {
        _canStart = true;
        _meetStatus = 2;
      });
      _showMessage('$_meetingTitle 会议即将结束', isError: true);
    } else {
      _showMessage(result.msg, isError: true);
    }
  }

  // 数据上报（不再显示选择对话框，因为已经在外部选择了）
  Future<void> _reportData() async {
    if (_selectedDeviceIds.isEmpty) {
      _showMessage('请选择客户端', isError: true);
      return;
    }
    
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID为空', isError: true);
      return;
    }
    
    // 获取选中设备的IP
    final List<String> selectedIPs = [];
    for (var node in _clientList) {
      if (_selectedDeviceIds.contains(node.nodeID) && node.ip != null) {
        selectedIPs.add(node.ip!);
      }
    }
    
    if (selectedIPs.isEmpty) {
      _showMessage('所选设备没有IP地址', isError: true);
      return;
    }
    
    final stations = selectedIPs.join(',');
    final result = await SccClientWrapper.reportCheckInFailed(
      meetID: widget.meetId!,
      stations: stations,
    );
    
    if (result.isSuccess) {
      _showMessage('上报成功');
      setState(() {
        _notificationMessage = '数据上报成功: ${DateTime.now().toString().substring(0, 19)}';
      });
    } else {
      _showMessage(result.msg, isError: true);
    }
  }

  // 数据检查（自动检查端口号是8084的前端设备）
  Future<void> _showDataCheckDialog() async {
    // 检查是否有端口号是8084的前端设备
    final List<DeviceNode> frontEndDevices = [];
    for (var root in _deviceTree) {
      if (root.stationName == '前端设备') {
        frontEndDevices.addAll(root.children);
      }
    }
    
    final List<String> devicesWithPort8084 = [];
    for (var node in frontEndDevices) {
      if (node.ip != null && node.ip!.contains(':8084')) {
        devicesWithPort8084.add(node.stationName);
      }
    }
    
    if (devicesWithPort8084.isEmpty) {
      _showMessage('未找到端口号为8084的前端设备', isError: true);
      return;
    }
    
    final checkList = <String>[];
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('请选择需要校验的数据库表'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: Text('会议表'),
                  value: checkList.contains('meet'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        checkList.add('meet');
                      } else {
                        checkList.remove('meet');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('代表表'),
                  value: checkList.contains('delegateregister'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        checkList.add('delegateregister');
                      } else {
                        checkList.remove('delegateregister');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('人员基础信息表'),
                  value: checkList.contains('personinformation'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        checkList.add('personinformation');
                      } else {
                        checkList.remove('personinformation');
                      }
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('确定'),
          ),
        ],
      ),
    );
    
    if (result == true && checkList.isNotEmpty) {
      _performDataCheck(checkList);
    }
  }

  // 执行数据检查（只检查端口号是8084的前端设备）
  Future<void> _performDataCheck(List<String> tables) async {
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID为空', isError: true);
      return;
    }
    
    // 获取前端设备（只检查前端设备，不检查中心管理端）
    final List<DeviceNode> frontEndDevices = [];
    for (var root in _deviceTree) {
      if (root.stationName == '前端设备') {
        frontEndDevices.addAll(root.children);
      }
    }
    
    // 过滤出端口号是8084的前端设备
    final List<String> selectedIPs = [];
    for (var node in frontEndDevices) {
      if (node.ip != null) {
        // 检查IP地址格式，可能是 "ip:port" 或只有IP
        final ip = node.ip!;
        
        // 如果包含端口号
        if (ip.contains(':')) {
          final parts = ip.split(':');
          if (parts.length >= 2) {
            final port = parts.last;
            // 只选择端口号是8084的设备
            if (port == '8084') {
              selectedIPs.add(ip);
            }
          }
        } else {
          // 如果没有端口号，可能需要根据其他条件判断
          // 这里先不处理，只处理有端口号的情况
        }
      }
    }
    
    if (selectedIPs.isEmpty) {
      _showMessage('未找到端口号为8084的前端设备', isError: true);
      return;
    }
    
    final stations = selectedIPs.join(',');
    final tablesStr = tables.join(',');
    
    // 先结束之前的检查
    await SccClientWrapper.endDatabaseCheck();
    
    final result = await SccClientWrapper.databaseCheck(
      meetID: widget.meetId!,
      stations: stations,
      tables: tablesStr,
    );
    
    print('数据检查返回: code=${result.code}, msg=${result.msg}, data=${result.data}');
    
    if (result.isSuccess) {
      _showMessage('开始校验');
      setState(() {
        _isChecking = true;
        _checkResultList = [];
      });
      
      // 定时检查结果
      _checkTimer?.cancel();
      _checkTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        _pollCheckResult();
      });
    } else {
      _showMessage(result.msg, isError: true);
    }
  }

  // 轮询检查结果（只检查端口号是8084的前端设备）
  void _pollCheckResult() {
    // 获取前端设备中端口号是8084的设备
    final List<DeviceNode> frontEndDevices = [];
    for (var root in _deviceTree) {
      if (root.stationName == '前端设备') {
        frontEndDevices.addAll(root.children);
      }
    }
    
    final checkData = frontEndDevices.where((node) {
      if (node.ip == null) return false;
      // 只检查端口号是8084的设备
      return node.ip!.contains(':8084') && node.clientStatus != 0;
    }).toList();
    
    setState(() {
      _checkResultList = [];
      for (var node in checkData) {
        // 这里需要从节点的 Remark 字段解析检查结果
        // 暂时使用模拟数据
        _checkResultList.add({
          'StationName': node.stationName,
          'Meet': 1,
          'DelegateRegister': 1,
          'PersonInformation': 1,
          'PersonInformationPhoto': 1,
        });
      }
      
      // 如果所有检查完成
      if (checkData.every((node) => node.clientStatus != 1)) {
        _checkTimer?.cancel();
        _isChecking = false;
      }
    });
  }

  // 文件选取：先检测U盘，有U盘自动读取txt，没有则打开文件选择器
  Future<void> _pickAndUploadFile() async {
    try {
      // 先检测是否有U盘
      final drives = await _getRemovableDrives();
      
      if (drives.isNotEmpty) {
        // 检测到U盘，查找第一个txt文件
        final usbPath = drives.first;
        final driveDir = Directory(usbPath);
        
        if (await driveDir.exists()) {
          final txtFile = await _findFirstTxtFile(driveDir);
          
          if (txtFile != null) {
            // 找到txt文件，自动上传
            _showMessage('检测到U盘，正在自动上传文件: ${txtFile.path.split(Platform.pathSeparator).last}');
            await _uploadFile(txtFile);
            return;
          } else {
            // U盘存在但没有txt文件
            _showMessage('U盘中未找到txt文件，请选择文件', isError: true);
            // 继续执行文件选择器
          }
        }
      }
      
      // 没有检测到U盘，或者U盘中没有txt文件，打开文件选择器
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _uploadFile(file);
      }
    } catch (e) {
      _showMessage('文件选择失败: $e', isError: true);
    }
  }

  // 显示消息
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
            child: Text(
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
                        Text(
                          '$label:',
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'FZXBYS',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        // 右侧：数字
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontFamily: 'TimesNewRoman',
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/device_map.png"), // 设备点位图底图
          fit: BoxFit.contain, // 保持比例并完整显示
        ),
        color: Colors.grey[100], // 背景色
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      // child: Center(
      //   child: Text(
      //     '设备点位图',
      //     style: TextStyle(
      //       fontFamily: 'FZXBYS',
      //       fontSize: 24,
      //       color: Colors.black54,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
    );
  }


  //设备列表 - 按设备类型分组，每种类型一个大底图
  Widget _buildAttendList() {
    // 从 _clientList 和 _deviceTree 中获取所有设备
    final List<DeviceNode> allDevices = [];
    for (var root in _deviceTree) {
      allDevices.addAll(root.children);
    }
    
    // 按设备类型分组
    final rackDevices = allDevices.where((d) => d.processType == 'rack').toList();
    final clientDevices = allDevices.where((d) => d.processType == 'Client').toList();
    final didianDevices = allDevices.where((d) => d.processType == 'didian').toList();
    
    // 如果没有设备，显示提示
    if (allDevices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '暂无设备数据',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: 'FZXBYS',
              ),
            ),
            SizedBox(height: 8),
            Text(
              '正在加载设备列表...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'FZXBYS',
              ),
            ),
          ],
        ),
      );
    }
    
    // 转换设备状态
    String _getStatusText(int? status) {
      switch (status) {
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          // 机架设备区域
          if (rackDevices.isNotEmpty)
            _buildDeviceTypeArea('rack', rackDevices, _getStatusText),
          // 客户端设备区域
          if (clientDevices.isNotEmpty)
            _buildDeviceTypeArea('Client', clientDevices, _getStatusText),
          // 地垫设备区域
          if (didianDevices.isNotEmpty)
            _buildDeviceTypeArea('didian', didianDevices, _getStatusText),
        ],
      ),
    );
  }
  
  // 构建设备类型区域（一个大底图 + 多个状态矩形）
  Widget _buildDeviceTypeArea(String processType, List<DeviceNode> devices, String Function(int?) getStatusText) {
    return Container(
      width: 300,
      child: Column(
        children: [
          // 底图容器
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getDeviceImage(processType)),
                fit: BoxFit.contain,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: devices.asMap().entries.map((entry) {
                final index = entry.key;
                final device = entry.value;
                final status = getStatusText(device.clientStatus);
                final textColor = status == '工作' ? Colors.black : Colors.white;
                
                // 计算每个设备矩形的位置（根据设备索引排列）
                final position = _calculateDevicePosition(index, devices.length, processType);
                
                return Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 状态矩形框
                      Container(
                        decoration: BoxDecoration(
                          color: _getStatusBackgroundColor(status),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        padding: _getStatusPadding(processType),
                        child: Text(
                          _getStatusDisplayText(status, processType),
                          style: TextStyle(
                            fontSize: _getStatusFontSize(processType),
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: 'FZXBYS',
                            shadows: textColor == Colors.white ? [
                              Shadow(color: Colors.black, offset: Offset(1, 1)),
                            ] : [],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 4),
                      // 设备名称和人数信息
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              device.stationName,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontFamily: 'FZXBYS',
                              ),
                            ),
                            // 人数信息（仅显示会议厅）
                            if (processType == 'rack')
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (device.attendNum != null && device.attendNum! > 0)
                                    Text(
                                      '出席:${device.attendNum}',
                                      style: TextStyle(fontSize: 9, color: HexColor('#900000'), fontFamily: 'FZXBYS'),
                                    ),
                                  if (device.specialNum != null && device.specialNum! > 0)
                                    Text(
                                      '列席:${device.specialNum}',
                                      style: TextStyle(fontSize: 9, color: HexColor('#900000'), fontFamily: 'FZXBYS'),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  // 计算设备在底图上的位置
  Offset _calculateDevicePosition(int index, int total, String processType) {
    // 根据不同设备类型和数量，计算矩形框的位置
    // 注意：这里的位置应该与底图上设备实际位置对应
    // 如果底图上有固定的设备位置，需要根据设备的 StationName 或 IP 来确定具体位置
    // 目前先使用相对偏移的方式，后续可以根据实际底图调整
    
    final baseOffset = _getStatusOffset(processType);
    
    switch (processType) {
      case 'rack':
        // 机架设备：如果多个设备，可以按网格排列
        // 如果底图只有一个位置，所有设备重叠显示；如果有多个位置，按行列排列
        if (total == 1) {
          // 单个设备，使用基础偏移
          return baseOffset;
        } else {
          // 多个设备，网格排列（可根据实际底图调整）
          final cols = 3; // 每行3个
          final row = index ~/ cols;
          final col = index % cols;
          return Offset(
            baseOffset.dx + col * 90,
            baseOffset.dy + row * 110,
          );
        }
      case 'Client':
        // 客户端设备：水平排列
        if (total == 1) {
          return baseOffset;
        } else {
          return Offset(
            baseOffset.dx + index * 100,
            baseOffset.dy,
          );
        }
      case 'didian':
        // 地垫设备：水平排列（位置靠下）
        if (total == 1) {
          return baseOffset;
        } else {
          return Offset(
            baseOffset.dx + index * 100,
            baseOffset.dy,
          );
        }
      default:
        return baseOffset;
    }
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
        return Colors.green; // 半透明红色
      case '设备':
        return Colors.purple.withOpacity(0.8); // 半透明紫色
      case '重报':
        return HexColor('#00F7DE'); // 半透明绿色
      case '错卡':
        return HexColor('#ffa500'); // 半透明红色
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 三个红色按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDisplayButton('会标', Icons.flag),
              _buildDisplayButton('报到情况', Icons.people),
              _buildDisplayButton('标语', Icons.text_fields),
            ],
          ),

          SizedBox(height: 20),

          // 表格标题
          Text(
            '显示内容管理',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'FZXBYS',
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 12),

          // 表格
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // 表头
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '序号',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'FZXBYS',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '内容',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'FZXBYS',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '操作',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'FZXBYS',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 表格内容 - 空状态
                Container(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                  child: Center(
                    child: Text(
                      '空',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontFamily: 'FZXBYS',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // 添加内容功能
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text('添加内容'),
              ),
              SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  // 刷新功能
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: Text('刷新'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 会议管理内容（原有的功能按钮区域）
  Widget _buildMeetingManagementContent() {
    return Container(
      height: 230, // 恢复原来的固定高度
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 第一行：开始、结束、退出
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFunctionButton(
                '开始',
                Icons.play_arrow,
                color: Colors.white,
                enabled: _canStart && _meetStatus != 1,
                onTap: _canStart && _meetStatus != 1 ? _startMeeting : null,
              ),
              _buildFunctionButton(
                '结束',
                Icons.power_settings_new,
                color: Colors.white,
                enabled: !_canStart && _meetStatus == 1,
                onTap: !_canStart && _meetStatus == 1 ? _endMeeting : null,
              ),
              _buildFunctionButton(
                '退出',
                Icons.exit_to_app,
                color: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          // 第二行：数据上报、数据检查、文件选取
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFunctionButton(
                '数据上报',
                Icons.cloud_upload,
                color: Colors.white,
                onTap: () => _showDeviceSelectionDialog('数据上报'),
              ),
                  _buildFunctionButton(
                    '数据检查',
                    Icons.search,
                    color: Colors.white,
                    onTap: _showDataCheckDialog,
                  ),
              _buildFunctionButton(
                '文件选取',
                Icons.folder,
                color: Colors.white,
                onTap: _pickAndUploadFile,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 显示设备选择对话框
  Future<void> _showDeviceSelectionDialog(String action) async {
    if (_deviceTree.isEmpty) {
      _showMessage('暂无设备列表', isError: true);
      return;
    }
    
    final selectedDevices = <String>{..._selectedDeviceIds};
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('请选择设备'),
          content: Container(
            width: 400,
            height: 400,
            child: _buildDeviceTreeForDialog(selectedDevices, setDialogState),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedDeviceIds = selectedDevices;
                });
                Navigator.pop(context, true);
              },
              child: Text('确定'),
            ),
          ],
        ),
      ),
    );
    
    if (result == true && selectedDevices.isNotEmpty) {
      if (action == '数据上报') {
        _reportData();
      } else if (action == '数据检查') {
        _showDataCheckDialog();
      }
    } else if (result == true && selectedDevices.isEmpty) {
      _showMessage('请至少选择一个设备', isError: true);
    }
  }
  
  // 构建设备树用于对话框
  Widget _buildDeviceTreeForDialog(Set<String> selectedDevices, StateSetter setDialogState) {
    return ListView.builder(
      itemCount: _deviceTree.length,
      itemBuilder: (context, index) {
        return _buildTreeTileForDialog(_deviceTree[index], selectedDevices, setDialogState);
      },
    );
  }
  
  // 构建树节点用于对话框
  Widget _buildTreeTileForDialog(DeviceNode node, Set<String> selectedDevices, StateSetter setDialogState) {
    if (node.children.isEmpty) {
      // 叶子节点
      return CheckboxListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(node.stationName),
            if (node.ip != null)
              Text('${_getAttendNum(node.ip)}', style: TextStyle(fontSize: 12)),
          ],
        ),
        value: selectedDevices.contains(node.nodeID ?? node.id),
        onChanged: (value) {
          setDialogState(() {
            if (value == true) {
              selectedDevices.add(node.nodeID ?? node.id);
            } else {
              selectedDevices.remove(node.nodeID ?? node.id);
            }
          });
        },
      );
    } else {
      // 父节点
      return ExpansionTile(
        title: Text(node.stationName),
        children: node.children.map((child) => _buildTreeTileForDialog(child, selectedDevices, setDialogState)).toList(),
      );
    }
  }

  // 修改函数签名，添加onTap参数
  Widget _buildFunctionButton(
    String title,
    IconData icon, {
    Color? color,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    // 根据文字长度调整字体大小
    double fontSize = title.length >= 4 ? 20 : 24;

    return SizedBox(
      width: 140,
      height: 90,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null, // 使用传入的onTap回调
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: HexColor('#A30014')), // 图标颜色保持红色
                SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'FZXBYS',
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

  // 显示管理按钮
  Widget _buildDisplayButton(String title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // 按钮点击功能
        _handleDisplayButtonClick(title);
      },
      icon: Icon(icon, size: 20),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: HexColor('#A30014'),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 处理显示管理按钮点击
  void _handleDisplayButtonClick(String buttonType) {
    switch (buttonType) {
      case '会标':
        // 处理会标显示逻辑
        break;
      case '报到情况':
        // 处理报到情况显示逻辑
        break;
      case '标语':
        // 处理标语显示逻辑
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                          _meetingTitle.isNotEmpty ? _meetingTitle : widget.meetingName,
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
                                            style: TextStyle(
                                              fontFamily: 'FZXBYS',
                                            ),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            '设备点位图',
                                            style: TextStyle(
                                              fontFamily: 'FZXBYS',
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
                                                onTap: () => setState(
                                                  () =>
                                                      _isMeetingManagementSelected =
                                                          true,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color:
                                                            _isMeetingManagementSelected
                                                            ? HexColor(
                                                                '#A30014',
                                                              )!
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
                                                        fontFamily: 'FZXBYS',
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
                                                onTap: () => setState(
                                                  () =>
                                                      _isMeetingManagementSelected =
                                                          false,
                                                ),
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
                                                        fontFamily: 'FZXBYS',
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
                                              fontFamily: 'FZXBYS',
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
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  _notificationMessage.isNotEmpty 
                                                      ? _notificationMessage 
                                                      : '这里显示通知信息',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'FZXBYS',
                                                  ),
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
    );
  }
}
