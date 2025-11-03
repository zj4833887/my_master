import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import './MeetingDetailScreen.dart';
class TreeNode {
  final String title;
  final List<TreeNode> children;
  final bool isMeeting;
  
  TreeNode(this.title, {this.children = const [], this.isMeeting = false});
}

final List<TreeNode> meetingTree = [
  TreeNode('滨海市第三次代表大会', children: [
    TreeNode('开幕式', isMeeting: true),
    TreeNode('第一次全体会议', isMeeting: true),
    TreeNode('第二次全体会议', isMeeting: true),
    TreeNode('闭幕式', isMeeting: true),
  ]),
];

void main() {
  runApp(MeetingCheckInApp());
}

class MeetingCheckInApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '电子会议报到系统',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MeetingCheckInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MeetingCheckInScreen extends StatefulWidget {
  @override
  _MeetingCheckInScreenState createState() => _MeetingCheckInScreenState();
}

class _MeetingCheckInScreenState extends State<MeetingCheckInScreen> {
  String _currentTime = '';
  String _currentMeeting = '开幕式';
  Timer? _timer;

  // 模拟数据
  Map<String, Map<String, int>> _attendanceData = {
    '出席情况': {'应到': 300, '实到': 0, '未到': 0, '请假': 0, '实缺': 0},
    '列席情况': {'应到': 50, '实到': 0, '未到': 0, '请假': 0, '实缺': 0},
  };

  // 树节点的展开状态管理 - 简化版本
  final Map<String, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
    
    // 初始化根节点为展开状态
    _expandedState['滨海市第三次代表大会'] = true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
    });
  }

  void _enterMeeting() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MeetingDetailScreen(meetingName: _currentMeeting),
    ),
  );
}

  void _selectMeeting(String meeting) {
    setState(() {
      _currentMeeting = meeting;
      // 模拟更新数据
      _attendanceData['出席情况']?['实到'] = meeting == '开幕式' ? 285 : 290;
      _attendanceData['出席情况']?['未到'] = meeting == '开幕式' ? 10 : 5;
      _attendanceData['出席情况']?['请假'] = meeting == '开幕式' ? 5 : 5;
      _attendanceData['出席情况']?['实缺'] = meeting == '开幕式' ? 15 : 10;

      _attendanceData['列席情况']?['实到'] = meeting == '开幕式' ? 45 : 48;
      _attendanceData['列席情况']?['未到'] = meeting == '开幕式' ? 3 : 1;
      _attendanceData['列席情况']?['请假'] = meeting == '开幕式' ? 2 : 1;
      _attendanceData['列席情况']?['实缺'] = meeting == '开幕式' ? 5 : 2;
    });
  }

  // 递归构建树形结构 - 修复版本
  Widget _buildTree(TreeNode node, {int level = 0}) {
    final hasChildren = node.children.isNotEmpty;
    final isExpanded = _expandedState[node.title] ?? (level == 0); // 根节点默认展开
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 节点本身
        Container(
          margin: EdgeInsets.only(left: (level * 20.0)),
          decoration: BoxDecoration(
            color: node.isMeeting && _currentMeeting == node.title 
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
            title: Text(
              node.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: node.isMeeting ? FontWeight.normal : FontWeight.w500,
                color: node.isMeeting 
                    ? (_currentMeeting == node.title ? Colors.red[700] : Colors.black87)
                    : Colors.blue[800],
              ),
            ),
            trailing: node.isMeeting
                ? Icon(Icons.meeting_room, color: Colors.red[700], size: 20)
                : null,
            onTap: () {
              if (node.isMeeting) {
                _selectMeeting(node.title);
              } else if (hasChildren) {
                setState(() {
                  _expandedState[node.title] = !isExpanded;
                });
              }
            },
          ),
        ),
        // 子节点
        if (hasChildren && isExpanded) ...node.children.map((child) => 
          _buildTree(child, level: level + 1)
        ).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[700],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      color: Colors.red[700],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.yellow,
            size: 40,
          ),
          SizedBox(width: 16),
          Text(
            '电子会议报到系统主控终端',
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 树形结构容器
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meetingTree.map((node) => 
                      _buildTree(node)
                    ).toList(),
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
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 当前时间显示
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: Colors.red[700]),
                  SizedBox(width: 8),
                  Text(
                    _currentTime,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    _currentMeeting,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // 进入会议按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _enterMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: Icon(Icons.login, size: 24),
                label: Text('进入会议'),
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
                          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                        ),
                        Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 16,
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