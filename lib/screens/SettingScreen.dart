import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import './MeetingDetailScreen.dart';
import '../scc/scc_client.dart';
import '../widgets/mixed_font_text.dart';
import '../utils/hex_color.dart';

// 会议数据模型
class MeetingData {
  final String? MeetID;
  final String Name;
  final bool? Checkin;
  final int? MeetFinished;
  final String? ParentID;

  MeetingData({
    this.MeetID,
    required this.Name,
    this.Checkin,
    this.MeetFinished,
    this.ParentID,
  });

  factory MeetingData.fromJson(Map<String, dynamic> json) {
    // 处理字段名映射：后端返回的是 Meetid, Parentid, Meetfinished (小写)
    // Checkin 是一个数组，包含子会议
    return MeetingData(
      MeetID: (json['MeetID'] ?? json['Meetid'])?.toString(),
      Name: json['Name']?.toString() ?? '',
      // Checkin 是数组，如果有子会议则不为空
      Checkin: json['Checkin'] != null && 
               json['Checkin'] is List && 
               (json['Checkin'] as List).isNotEmpty,
      MeetFinished: (json['MeetFinished'] ?? json['Meetfinished']) is int 
          ? (json['MeetFinished'] ?? json['Meetfinished']) 
          : ((json['MeetFinished'] ?? json['Meetfinished']) == true || 
             (json['MeetFinished'] ?? json['Meetfinished']) == 1 ? 1 : 0),
      ParentID: (json['ParentID'] ?? json['Parentid'])?.toString(),
    );
  }
}

class TreeNode {
  final String title;
  final List<TreeNode> children;
  final bool isMeeting;
  final MeetingData? meetingData;

  TreeNode(this.title, {
    this.children = const [],
    this.isMeeting = false,
    this.meetingData,
  });
}

class MeetingCheckInScreen extends StatefulWidget {
  @override
  _MeetingCheckInScreenState createState() => _MeetingCheckInScreenState();
}

class _MeetingCheckInScreenState extends State<MeetingCheckInScreen> {
  String _currentTime = '';
  String _currentMeeting = '';
  String? _currentMeetID;
  Timer? _timer;

  // 会议列表数据
  List<MeetingData> _meetingList = [];
  String? _currentOnMeetID; // 当前进行的会议ID
  
  // 会议树形结构
  List<TreeNode> _meetingTree = [];
  
  // 选中的会议ID
  String? _selectedMeetID;
  
  // 是否显示准备会议信息（对应 Vue 的 set）
  bool _isPreparing = false;
  String _preparingTitle = '请选择会议';
  
  // 是否可以继续（对应 Vue 的 flag，当前选中会议是否是正在进行的会议）
  bool _canContinue = false;
  
  // 会议统计数据
  Map<String, Map<String, int>> _attendanceData = {
    '出席情况': {'应到': 0, '实到': 0, '未到': 0, '请假': 0, '实缺': 0},
    '列席情况': {'应到': 0, '实到': 0, '未到': 0, '请假': 0, '实缺': 0},
  };

  // 树节点的展开状态管理
  final Map<String, bool> _expandedState = {};
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });

    // 加载会议数据
    _loadMeetingData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('yyyy年MM月dd日 HH:mm:ss').format(DateTime.now());
    });
  }

  // 加载会议数据
  Future<void> _loadMeetingData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取会议列表（使用 gRPC）
      final result = await SccClientWrapper.queryMeet();
      if (result.isSuccess && result.data != null) {
        // 展开所有会议（包括 Checkin 数组中的子会议）
        List<Map<String, dynamic>> allMeetings = [];
        for (var item in result.data!) {
          // 添加父会议
          allMeetings.add(item as Map<String, dynamic>);
          
          // 如果 Checkin 是数组，添加子会议
          if (item['Checkin'] != null && item['Checkin'] is List) {
            final checkinList = item['Checkin'] as List;
            for (var child in checkinList) {
              if (child is Map<String, dynamic>) {
                allMeetings.add(child);
              }
            }
          }
        }
        
        setState(() {
          _meetingList = allMeetings.map((item) => MeetingData.fromJson(item)).toList();
        });
        print('解析后的会议列表数量: ${_meetingList.length}');
        // 构建树形结构
        _buildMeetingTree();
      }

      // 获取当前进行的会议（使用 gRPC）
      final onMeetResult = await SccClientWrapper.queryOnMeet();
      if (onMeetResult.isSuccess && 
          onMeetResult.data != null &&
          onMeetResult.data!['serverStatus'] != null &&
          onMeetResult.data!['serverStatus']['Meetid'] != null) {
        setState(() {
          _currentOnMeetID = onMeetResult.data!['serverStatus']['Meetid'].toString();
          
          // 找到对应的会议名称
          final currentMeeting = _meetingList.firstWhere(
            (m) => m.MeetID == _currentOnMeetID,
            orElse: () => MeetingData(Name: ''),
          );
          if (currentMeeting.Name.isNotEmpty) {
            _currentMeeting = currentMeeting.Name;
            _currentMeetID = _currentOnMeetID;
          }
        });
      }
    } catch (e) {
      // 错误处理
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 构建会议树形结构
  void _buildMeetingTree() {
    // 找出所有父级会议（ParentID 为 null 或不在列表中的）
    final parentMeetings = _meetingList.where((m) => 
      m.ParentID == null || 
      m.ParentID == '' || 
      !_meetingList.any((item) => item.MeetID != null && item.MeetID == m.ParentID)
    ).toList();

    // 用于检测循环引用的集合
    final Set<String?> processedIDs = {};
    const int maxDepth = 100; // 最大深度限制，防止无限递归

    // 构建树形结构
    List<TreeNode> buildChildren(String? parentID, int depth) {
      // 防止无限递归：检查深度和循环引用
      if (depth > maxDepth) {
        return [];
      }

      if (parentID != null && processedIDs.contains(parentID)) {
        return [];
      }

      if (parentID != null) {
        processedIDs.add(parentID);
      }

      // 过滤子节点，确保 ParentID 匹配且 MeetID 不为空
      final children = _meetingList.where((m) => 
        m.MeetID != null && 
        m.MeetID!.isNotEmpty &&
        m.ParentID == parentID
      ).toList();

      if (children.isEmpty) {
        if (parentID != null) {
          processedIDs.remove(parentID);
        }
        return [];
      }

      final result = children.map((meeting) {
        final childMeetings = buildChildren(meeting.MeetID, depth + 1);
        return TreeNode(
          meeting.Name,
          isMeeting: true,
          meetingData: meeting,
          children: childMeetings,
        );
      }).toList();

      if (parentID != null) {
        processedIDs.remove(parentID);
      }

      return result;
    }

    setState(() {
      _meetingTree = parentMeetings.where((parent) => 
        parent.MeetID != null && parent.MeetID!.isNotEmpty
      ).map((parent) {
        processedIDs.clear(); // 为每个根节点重置
        final children = buildChildren(parent.MeetID, 0);
        return TreeNode(
          parent.Name,
          children: children,
          meetingData: parent,
        );
      }).toList();

      // 初始化展开状态
      if (_meetingTree.isNotEmpty) {
        _expandedState[_meetingTree.first.title] = true;
      }
    });
  }

  // 处理节点点击（准备会议）
  void _handleNodeClick(MeetingData data) {
    setState(() {
      _preparingTitle = '准备进行会议: ${data.Name}';
      _selectedMeetID = data.MeetID;
      
      // 如果有 MeetID，设置 set=true 并加载会议信息
      if (data.MeetID != null && data.MeetID!.isNotEmpty) {
        _isPreparing = true;
        print('270选择会议: ${data.MeetID}');
        _loadMeetingInfo(data.MeetID!);
      } else {
        _isPreparing = false;
      }

      // 判断是否是当前进行的会议（flag 逻辑）
      if (_currentOnMeetID == data.MeetID) {
        _canContinue = true;
        _currentMeeting = data.Name;
        _currentMeetID = data.MeetID;
      } else {
        _canContinue = false;
      }
    });
  }

  // 加载会议信息
  Future<void> _loadMeetingInfo(String meetID) async {
    try {
      // 使用 gRPC 调用
      final result = await SccClientWrapper.queryMeetInfo(meetID);
      print('292加载会议信息: ${result.data}');
      if (result.isSuccess && result.data != null) {
        final num = result.data!;
        setState(() {
          final notyet = (num['Personnum'] ?? 0) - (num['Personattendancenum'] ?? 0);
          final shouldarrive = num['Personnum'] ?? 0;
          final leave = num['Personleavenum'] ?? 0;
          
          _attendanceData['出席情况'] = {
            '应到': shouldarrive,
            '实到': num['Personattendancenum'] ?? 0,
            '未到': notyet,
            '请假': leave,
            '实缺': notyet,
          };

          final specialNum = num['Specialnum'] ?? 0;
          final specialAttend = num['Specialnattendancenum'] ?? 0;
          final specialLeave = num['Specialleavenum'] ?? 0;
          final specialNotyet = specialNum - specialAttend;

          _attendanceData['列席情况'] = {
            '应到': specialNum,
            '实到': specialAttend,
            '未到': specialNotyet,
            '请假': specialLeave,
            '实缺': specialNotyet,
          };
        });
      }
    } catch (e) {
      // 错误处理
    }
  }

  // 进入会议（对应 Vue 的 setUp - 选择按钮）
  void _enterMeeting() async {
    // 检查 set 状态（对应 Vue 的 if (this.set)）
    if (!_isPreparing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请您选择二级会议')),
      );
      return;
    }

    if (_selectedMeetID == null || _selectedMeetID!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请您选择二级会议')),
      );
      return;
    }

    try {
      // 使用 gRPC 调用设置会议
      final result = await SccClientWrapper.setMeet(_selectedMeetID!);
      
      if (result.isSuccess && result.data == true) {
        // 跳转到主页面，传递 MeetId 参数
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingDetailScreen(
              meetingName: _preparingTitle.replaceAll('准备进行会议: ', ''),
              meetId: _selectedMeetID,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.msg.isNotEmpty ? result.msg : '请您选择二级会议')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  // 继续会议（对应 Vue 的 gonext）
  void _continueMeeting() async {
    if (_selectedMeetID == null || _selectedMeetID!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请您选择二级会议')),
      );
      return;
    }

    try {
      // 使用 gRPC 调用继续会议
      final result = await SccClientWrapper.continueMeet(_selectedMeetID!);
      
      if (result.isSuccess && result.data == true) {
        // 跳转到主页面，传递 MeetId 参数
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingDetailScreen(
              meetingName: _preparingTitle.replaceAll('准备进行会议: ', ''),
              meetId: _selectedMeetID,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.msg.isNotEmpty ? result.msg : '请您选择二级会议')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  // 递归构建树形结构
  Widget _buildTree(TreeNode node, {int level = 0}) {
    final hasChildren = node.children.isNotEmpty;
    final isExpanded = _expandedState[node.title] ?? (level == 0);
    final meetingData = node.meetingData;
    final isSelected = meetingData != null && _selectedMeetID == meetingData.MeetID;

    // 判断会议状态
    String? statusText;
    Color? statusColor;
    if (meetingData != null && meetingData.Checkin == false) {
      if (meetingData.MeetFinished == 1) {
        statusText = '（已结束）';
        statusColor = HexColor('#5FB878');
      } else {
        statusText = '（未开始）';
        statusColor = Colors.red;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 节点本身
        Container(
          margin: EdgeInsets.only(left: (level * 20.0)),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.red[50]
                : (isExpanded && hasChildren ? Colors.grey[50] : null),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 8, right: 8),
            leading: hasChildren
                ? IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      color: Colors.red[700],
                    ),
                    onPressed: () {
                      setState(() {
                        _expandedState[node.title] = !isExpanded;
                      });
                    },
                  )
                : SizedBox(width: 40),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    node.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Microsoft YaHei',
                      fontWeight: node.isMeeting
                          ? FontWeight.normal
                          : FontWeight.w500,
                      color: node.isMeeting
                          ? (isSelected
                                ? Colors.red[700]
                                : Colors.black87)
                          : Colors.blue[800],
                    ),
                  ),
                ),
                if (statusText != null && statusColor != null)
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Microsoft YaHei',
                      color: statusColor,
                    ),
                  ),
              ],
            ),
            trailing: node.isMeeting
                ? Icon(Icons.meeting_room, color: Colors.red[700], size: 20)
                : null,
            onTap: () {
              if (node.isMeeting && meetingData != null) {
                _handleNodeClick(meetingData);
              } else if (hasChildren) {
                setState(() {
                  _expandedState[node.title] = !isExpanded;
                });
              }
            },
          ),
        ),
        // 子节点
        if (hasChildren && isExpanded)
          ...node.children
              .map((child) => _buildTree(child, level: level + 1))
              .toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/title.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // 顶部背景图区域
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/title.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 主体内容区域
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/dise.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    margin: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildMeetingStructure(),
                        SizedBox(width: 16),
                        _buildMeetingOverview(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingStructure() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree, color: Colors.red[700], size: 24),
                SizedBox(width: 8),
                Text(
                  '会议组织结构',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Microsoft YaHei',
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                Spacer(),
                // 刷新按钮
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.red[700]),
                  tooltip: '刷新',
                  onPressed: _isLoading ? null : () {
                    _loadMeetingData();
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            // 树形结构容器（带下拉刷新）
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: _isLoading && _meetingTree.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _meetingTree.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '暂无会议数据',
                                  style: TextStyle(
                                    fontFamily: 'Microsoft YaHei',
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _isLoading ? null : () {
                                    _loadMeetingData();
                                  },
                                  icon: Icon(Icons.refresh),
                                  label: Text('刷新'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await _loadMeetingData();
                            },
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _meetingTree
                                    .map((node) => _buildTree(node))
                                    .toList(),
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingOverview() {
    return Expanded(
      flex: 4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.red[700], size: 24),
                SizedBox(width: 8),
                Text(
                  '会议情况概览',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Microsoft YaHei',
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 当前会议信息
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.meeting_room, color: Colors.blue[700]),
                      SizedBox(width: 8),
                      Text(
                        '当前会议:',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Microsoft YaHei',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _isPreparing ? _preparingTitle : (_currentMeeting.isNotEmpty ? _currentMeeting : '未选择会议'),
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Microsoft YaHei',
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // 进入会议按钮（根据 _canContinue 决定调用哪个方法）
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _canContinue ? _continueMeeting : _enterMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#A30014'),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Microsoft YaHei',
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: Icon(_canContinue ? Icons.play_arrow : Icons.login, size: 24),
                label: Text(_canContinue ? '继续会议' : '进入会议'),
              ),
            ),
            SizedBox(height: 20),
            // 出席和列席情况
            Expanded(
              child: Row(
                children: [
                  _buildAttendanceCard('出席情况', Colors.blue),
                  SizedBox(width: 16),
                  _buildAttendanceCard('列席情况', Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(String type, MaterialColor color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    type == '出席情况' ? Icons.people : Icons.people_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Microsoft YaHei',
                    fontWeight: FontWeight.bold,
                    color: color[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: Column(
                children: _attendanceData[type]!.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Microsoft YaHei',
                            color: Colors.grey[700],
                          ),
                        ),
                        MixedFontText(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Microsoft YaHei',
                            fontWeight: FontWeight.bold,
                            color: color[700],
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
      ),
    );
  }
}
