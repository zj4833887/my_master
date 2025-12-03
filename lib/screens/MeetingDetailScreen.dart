import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../scc/scc_client.dart';
import '../scc/board.dart';

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

  // 会议状态
  int _meetStatus = 0; // 0=未开启, 1=进行中, 2=结束
  
  // 会议是否已开始（用于控制按钮显示）
  bool _isMeetingStarted = false;

  // 客户端列表
  List<Map<String, dynamic>> _clientList = [];

  // MetricBoard 实例
  final MetricBoard _metricBoard = MetricBoard();

  // 订阅流
  StreamSubscription? _metricsSubscription;

  // 设备数据（从客户端列表生成）
  List<Map<String, dynamic>> _devices = [];

  // 加载状态
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _meetingTitle = widget.meetingName;
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _metricsSubscription?.cancel();
    super.dispose();
  }

  // 初始化数据
  Future<void> _initializeData() async {
    // 加载客户端列表
    await _loadClientList();
    
    // 如果提供了 meetId，先通过 queryMeetInfo 获取初始数据
    if (widget.meetId != null && widget.meetId!.isNotEmpty) {
      await _loadInitialMeetingInfo();
    }
    
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
            
            // 根据 FacilityTypeName 与端口设置 ProcessType
            final facilityType = client['FacilityTypeName']?.toString() ?? '';
            final ip = client['IP']?.toString() ?? '';
            if (facilityType == '报到终端') {
              if (ip.contains(':1030') || ip.endsWith('1030')) {
                client['ProcessType'] = 'didian';
              } else {
                client['ProcessType'] = 'rack';
              }
            } else {
              client['ProcessType'] = 'Client';
            }
            
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
        print('subscribeMetrics -> channel: $channel, data: $data');

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

        if (looksLikeCheckIn) {
          print('WS_CheckInInfo payload detected: $data');
          _handleCheckInInfo(data);
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
              _meetingTitle = '会议暂未开启';
              _isMeetingStarted = false;
              break;
            case 1:
              _meetingTitle = '会议正在进行';
              _isMeetingStarted = true;
              break;
            case 2:
              _meetingTitle = '会议结束';
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
        final personnum = _parseInt(nums['Personnum'] ?? 0);
        // 只输出 Personnum
        print(personnum);
        final personattendancenum = _parseInt(nums['Personattendancenum'] ?? 0);
        final personleavenum = _parseInt(nums['Personleavenum'] ?? 0);
        final notyet = personnum - personattendancenum; // 未到

        // 创建新的 Map 以确保 setState 能检测到变化
        attendStats = {
          '应到': personnum,
          '实到': personattendancenum,
          '未到': notyet,
          '请假': personleavenum,
          '实缺': notyet - personleavenum,
        };

        // 列席统计数据
        final specialnum = _parseInt(nums['Specialnum'] ?? 0);
        final specialnattendancenum = _parseInt(nums['Specialnattendancenum'] ?? 0);
        final specialleavenum = _parseInt(nums['Specialleavenum'] ?? 0);
        final specialNotyet = specialnum - specialnattendancenum; // 列席未到

        // 创建新的 Map 以确保 setState 能检测到变化
        guestStats = {
          '应到': specialnum,
          '实到': specialnattendancenum,
          '未到': specialNotyet,
          '请假': specialleavenum,
          '实缺': specialNotyet - specialleavenum,
        };
      }
    });
  }

  // 处理报到信息 (WS_CheckInInfo)
  void _handleCheckInInfo(Map<String, dynamic> data) {
    print('WS_CheckInInfo: $data');
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

  // 更新设备列表
  void _updateDevicesList() {
    _devices = _clientList.map((client) {
      final processType = client['ProcessType'] ?? 'Server';
      final clientStatus = client['ClientStatus'] ?? 0;
      final stationName = client['StationName'] ?? '';
      
      // 根据 ProcessType 和 ClientStatus 确定状态
      String status = _getStatusFromClientStatus(clientStatus, processType);
      
      // 获取出席和列席人数（如果是 rack 类型）
      int attend = 0;
      int guest = 0;
      if (processType == 'rack' || processType == 'Server') {
        // 这里可以从其他数据源获取，暂时使用默认值
        attend = client['attend'] ?? 0;
        guest = client['guest'] ?? 0;
      }
      
      return {
        'name': stationName.isNotEmpty ? stationName : (client['Name'] ?? ''),
        'ProcessType': processType,
        'status': status,
        'attend': attend,
        'guest': guest,
        'NodeID': client['NodeID'],
        'ClientStatus': clientStatus,
      };
    }).toList();
  }

  // 根据 ClientStatus 获取状态文本
  String _getStatusFromClientStatus(int clientStatus, String processType) {
    // 对于报到终端/地垫终端，需要根据 CheckIn 状态实时展示
    if (processType == 'Client' || processType == 'didian') {
      switch (clientStatus) {
        case -3:
          return '重报';
        case -2:
          return '报到';
        case 3:
          return '工作';
        case 5:
          return '结束';
        case 4:
        case 0:
          return '脱机';
        default:
          return '联机';
      }
    }

    // 其他类型按照会议设备逻辑显示
    switch (clientStatus) {
      case 0:
        return '空闲';
      case 3:
        return '工作';
      case 4:
      case 5:
        return '结束';
      case -2:
        return '报到';
      case -3:
        return '重报';
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

  // 开始会议
  Future<void> _handleStartMeeting() async {
    if (widget.meetId == null || widget.meetId!.isEmpty) {
      _showMessage('会议ID不能为空', isError: true);
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SccClientWrapper.startMeet(widget.meetId!);
      if (result.isSuccess) {
        setState(() {
          _isMeetingStarted = true;
        });
        _showMessage('会议开始成功');
      } else {
        _showMessage(result.msg.isNotEmpty ? result.msg : '会议开始失败', isError: true);
      }
    } catch (e) {
      _showMessage('操作失败: $e', isError: true);
    } finally {
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
          title: Text('确认结束会议', style: TextStyle(fontFamily: 'FZXBYS')),
          content: Text('确定要结束当前会议吗？', style: TextStyle(fontFamily: 'FZXBYS')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('取消', style: TextStyle(fontFamily: 'FZXBYS')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('确定', style: TextStyle(fontFamily: 'FZXBYS', color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SccClientWrapper.endMeet(widget.meetId!);
      if (result.isSuccess) {
        setState(() {
          _isMeetingStarted = false;
        });
        _showMessage('会议结束成功');
      } else {
        _showMessage(result.msg.isNotEmpty ? result.msg : '会议结束失败', isError: true);
      }
    } catch (e) {
      _showMessage('操作失败: $e', isError: true);
    } finally {
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

    // 获取站点列表（从客户端列表）
    final stations = _clientList
        .where((client) => client['StationName'] != null && client['StationName'].toString().isNotEmpty)
        .map((client) => client['StationName'].toString())
        .toList();

    if (stations.isEmpty) {
      _showMessage('没有可用的站点', isError: true);
      return;
    }

    // 显示站点选择对话框
    final selectedStations = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return _StationSelectionDialog(
          stations: stations,
          title: '选择要上报的站点',
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

    // 显示数据检查参数输入对话框
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return _DataCheckDialog();
      },
    );

    if (result == null) return;

    final stations = result['stations'] ?? '';
    final tables = result['tables'] ?? '';

    if (stations.isEmpty || tables.isEmpty) {
      _showMessage('站点和表名不能为空', isError: true);
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final checkResult = await SccClientWrapper.databaseCheck(
        meetID: widget.meetId!,
        stations: stations,
        tables: tables,
      );
      if (checkResult.isSuccess) {
        _showMessage('数据检查成功');
      } else {
        _showMessage(checkResult.msg.isNotEmpty ? checkResult.msg : '数据检查失败', isError: true);
      }
    } catch (e) {
      _showMessage('操作失败: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 文件选取
  Future<void> _handleFilePick() async {
    if (_isLoading) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        if (!await file.exists()) {
          _showMessage('文件不存在', isError: true);
          return;
        }

        // 读取文件内容
        final fileBytes = await file.readAsBytes();
        final fileData = fileBytes.toList();

        setState(() {
          _isLoading = true;
        });

        try {
          final importResult = await SccClientWrapper.importRecord(fileData);
          if (importResult.isSuccess) {
            _showMessage('文件导入成功: ${importResult.data ?? ""}');
          } else {
            _showMessage(importResult.msg.isNotEmpty ? importResult.msg : '文件导入失败', isError: true);
          }
        } catch (e) {
          _showMessage('导入失败: $e', isError: true);
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _showMessage('文件选择失败: $e', isError: true);
    }
  }

  // 显示消息
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'FZXBYS'),
        ),
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
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final String processType = device['ProcessType'] as String;
        final bool isRack = processType == 'rack';
        final String status = device['status'] as String; // 先定义status变量
        final Color textColor = status == '工作'
            ? Colors.black
            : Colors.white; // 然后使用它
        return Container(
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
                          fontFamily: 'FZXBYS',
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
                    fontFamily: 'FZXBYS',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 人数信息（仅显示会议厅）
              Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    Text(
                      '出席: ${device['attend']}',
                      style: TextStyle(fontSize: 12, fontFamily: 'FZXBYS'),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '列席: ${device['guest']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontFamily: 'FZXBYS',
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        return HexColor('#00F7DE'); // 报到状态使用青色
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
      height: 230, // 适当的高度，容纳两行按钮
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 第一行：开始/结束、比业务流程、退出
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 根据会议状态显示"开始"或"结束"按钮
              _buildFunctionButton(
                _isMeetingStarted ? '结束' : '开始',
                _isMeetingStarted ? Icons.power_settings_new : Icons.play_arrow,
                color: Colors.white,
                onTap: _isMeetingStarted ? _handleEndMeeting : _handleStartMeeting,
              ),
              _buildFunctionButton(
                '比业务流程',
                Icons.compare_arrows,
                color: Colors.white,
                onTap: _handleEndMeeting,
              ),
              _buildFunctionButton(
                '退出',
                Icons.exit_to_app,
                color: Colors.white,
                onTap: () {
                  // 退出按钮点击事件
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
                onTap: _handleDataReport,
              ),
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
            ],
          ),
        ],
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
    // 根据文字长度调整字体大小
    double fontSize = title.length >= 4 ? 20 : 24;
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
                                                  '这里显示通知信息',
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

// 站点选择对话框
class _StationSelectionDialog extends StatefulWidget {
  final List<String> stations;
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
      title: Text(widget.title, style: TextStyle(fontFamily: 'FZXBYS')),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 400),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.stations.length,
          itemBuilder: (context, index) {
            final station = widget.stations[index];
            final isSelected = _selectedStations.contains(station);
            return CheckboxListTile(
              title: Text(station, style: TextStyle(fontFamily: 'FZXBYS')),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedStations.add(station);
                  } else {
                    _selectedStations.remove(station);
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
          child: Text('取消', style: TextStyle(fontFamily: 'FZXBYS')),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedStations.toList());
          },
          child: Text('确定', style: TextStyle(fontFamily: 'FZXBYS', color: Colors.red)),
        ),
      ],
    );
  }
}

// 数据检查参数输入对话框
class _DataCheckDialog extends StatefulWidget {
  @override
  State<_DataCheckDialog> createState() => _DataCheckDialogState();
}

class _DataCheckDialogState extends State<_DataCheckDialog> {
  final TextEditingController _stationsController = TextEditingController();
  final TextEditingController _tablesController = TextEditingController();

  @override
  void dispose() {
    _stationsController.dispose();
    _tablesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('数据检查参数', style: TextStyle(fontFamily: 'FZXBYS')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _stationsController,
            decoration: InputDecoration(
              labelText: '站点 (多个用逗号分隔)',
              hintText: '例如: 站点1,站点2',
              border: OutlineInputBorder(),
            ),
            style: TextStyle(fontFamily: 'FZXBYS'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _tablesController,
            decoration: InputDecoration(
              labelText: '表名 (多个用逗号分隔)',
              hintText: '例如: 表1,表2',
              border: OutlineInputBorder(),
            ),
            style: TextStyle(fontFamily: 'FZXBYS'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消', style: TextStyle(fontFamily: 'FZXBYS')),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'stations': _stationsController.text.trim(),
              'tables': _tablesController.text.trim(),
            });
          },
          child: Text('确定', style: TextStyle(fontFamily: 'FZXBYS', color: Colors.red)),
        ),
      ],
    );
  }
}
