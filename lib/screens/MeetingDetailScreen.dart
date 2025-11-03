import 'package:flutter/material.dart';

class MeetingDetailScreen extends StatefulWidget {
  final String meetingName;

  MeetingDetailScreen({required this.meetingName});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 统计数据 - 完全按照图片中的数值
  final Map<String, int> attendStats = {
    '应到': 2200,
    '实到': 2150,
    '未到': 50,
    '请假': 0,
    '实缺': 50,
  };
  final Map<String, int> guestStats = {
    '应到': 2200,
    '实到': 2150,
    '未到': 50,
    '请假': 0,
    '实缺': 50,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
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
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        // 右侧：数字
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
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
    final items = List.generate(24, (i) => i);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  index % 3 == 0 ? '空闲' : (index % 3 == 1 ? '结束' : '工作'),
                  style: TextStyle(
                    color: index % 3 == 0
                        ? Colors.black54
                        : (index % 3 == 1 ? Colors.orange : Colors.blue),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text('0${(index % 12) + 1}—厅', style: TextStyle(fontSize: 12)),
            Text(
              '出席: ${8 - (index % 3)} 列席: ${index % 2}',
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendList() {
    // 模拟设备数据 - 根据图片中的状态和布局
    final devices = [
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
        'status': '设备',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '设备',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '设备',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '设备',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '报到显示终端',
        'ProcessType': 'Client',
        'status': '设备',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
      {
        'name': '地垫式报到设备',
        'ProcessType': 'didian',
        'status': '设备',
        'attend': 0,
        'guest': 0,
        'color': Colors.grey,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 修正：应该是3而不是9
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final bool isEquipment = device['ProcessType'] == 'rack';

        return Container(
          decoration: BoxDecoration(
            color: isEquipment ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
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
                    image: AssetImage(
                      _getDeviceImage(device['ProcessType'] as String),
                    ),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Transform.translate(
                    // 矩形框的装饰
                    offset: Offset(-1, -15),
                    child: Container(
                      // 矩形框的装饰
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(
                          device['status'] as String,
                        ),
                        borderRadius: BorderRadius.circular(0),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 12,
                      ),
                      child: Text(
                        _getStatusDisplayText(device['status'] as String),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),

              // 人数信息（仅显示会议厅）
              if (!isEquipment) ...[
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Text(
                        '出席: ${device['attend']}',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '列席: ${device['guest']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
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

  // 根据状态获取背景颜色
  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case '工作':
        return Colors.white; // 半透明蓝色
      case '结束':
        return Colors.orange; // 半透明橙色
      case '空闲':
        return Colors.black; // 半透明灰色
      case '重报':
        return Colors.green; // 半透明紫色
      case '错卡':
        return Colors.red;
      default:
        return Colors.black.withOpacity(0.6); // 默认半透明黑色
    }
  }

  // 修改状态显示文本
  String _getStatusDisplayText(String status) {
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
        return status;
    }
  }

  // 辅助方法 - 需要放在类中，而不是方法内
  ColorFilter _getStatusColorFilter(String status) {
    switch (status) {
      case '工作':
        return ColorFilter.mode(Colors.blue.withOpacity(0.6), BlendMode.color);
      case '结束':
        return ColorFilter.mode(
          Colors.orange.withOpacity(0.6),
          BlendMode.color,
        );
      case '空闲':
      default:
        return ColorFilter.mode(Colors.grey.withOpacity(0.6), BlendMode.color);
    }
  }

  Widget _buildFunctionButton(String title, IconData icon, {Color? color}) {
    return ElevatedButton.icon(
      onPressed: () {
        if (title == '退出') Navigator.pop(context);
      },
      icon: Icon(icon, color: color ?? Colors.red),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: (color ?? Colors.red).withOpacity(0.08),
        foregroundColor: color ?? Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meetingName),
        backgroundColor: Colors.red[700],
      ),
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
                          '第一次全体代表大会',
                          style: TextStyle(
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
                                      labelColor: Colors.red[700],
                                      unselectedLabelColor: Colors.grey,
                                      indicatorColor: Colors.red[700],
                                      tabs: [
                                        Tab(text: '报到情况'),
                                        Tab(text: '设备点位图'),
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
                          Container(
                            width: 700,
                            child: Column(
                              children: [
                                Card(
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
                                          '会议管理',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[800],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        GridView.count(
                                          shrinkWrap: true,
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 6,
                                          mainAxisSpacing: 6,
                                          childAspectRatio: 1.2,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          children: [
                                            _buildFunctionButton(
                                              '开始',
                                              Icons.play_arrow,
                                              color: Colors.red,
                                            ),
                                            _buildFunctionButton(
                                              '结束',
                                              Icons.power_settings_new,
                                              color: Colors.red,
                                            ),
                                            _buildFunctionButton(
                                              '退出',
                                              Icons.exit_to_app,
                                              color: Colors.red,
                                            ),
                                            _buildFunctionButton(
                                              '数据上报',
                                              Icons.cloud_upload,
                                              color: Colors.orange,
                                            ),
                                            _buildFunctionButton(
                                              '数据检查',
                                              Icons.search,
                                              color: Colors.green,
                                            ),
                                            _buildFunctionButton(
                                              '文件选取',
                                              Icons.folder,
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
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
                                                  '这里显示通知信息。\n\n示例：会议将在 10 分钟后开始，请相关人员就位。\n\n注意事项：\n• 请提前15分钟入场\n• 携带有效证件\n• 保持会场安静',
                                                  style: TextStyle(
                                                    fontSize: 14,
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
