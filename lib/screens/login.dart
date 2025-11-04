// 导入Flutter Material Design组件库，这是构建Material风格UI的基础
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 用于发起网络请求
import 'dart:convert'; // 用于处理 JSON 编码和解码
import './settingScreen.dart'; // 导入设置页面

/// 应用的主入口函数
///
/// 在Flutter中，main函数是应用的启动入口
/// runApp()函数将给定的Widget作为应用的根Widget[1](@ref)
void main() {
  // 运行应用，传入MyApp实例作为根Widget
  runApp(MyApp());
}

/// 应用的主Widget，是一个无状态Widget（StatelessWidget）
///
/// 这个Widget是应用的根组件，负责设置整个应用的基本配置
/// 使用StatelessWidget因为根组件在运行时不需要改变自身状态[4](@ref)
class MyApp extends StatelessWidget {
  /// 构建应用的整体界面
  ///
  /// @param context 构建上下文，提供Widget在树中位置的信息
  /// @return 返回一个MaterialApp实例，这是Material风格应用的基础
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 移除右上角的调试横幅
      title: '电子会议报到系统', // 应用的名称
      theme: ThemeData(
        // 应用的主题设置
        primarySwatch: Colors.red, // 主色调为蓝色
        visualDensity: VisualDensity.adaptivePlatformDensity, // 视觉密度适配不同平台
      ),
      home: LoginScreen(), // 设置登录页面为应用启动后显示的第一个页面
    );
  }
}

/// 登录页面Widget，是一个有状态Widget（StatefulWidget）
///
/// StatefulWidget用于需要动态改变UI状态的页面[4](@ref)
/// 登录页面需要处理用户输入和交互，因此需要使用StatefulWidget
class LoginScreen extends StatefulWidget {
  /// 构造函数
  ///
  /// @param key Widget的可选标识键，用于在Widget树中识别这个Widget
  const LoginScreen({Key? key}) : super(key: key);

  /// 创建与这个Widget关联的State对象
  ///
  /// State对象负责管理Widget的状态和构建UI
  /// @return 返回_LoginScreenState实例
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// LoginScreen的状态类，管理登录页面的状态和UI
///
/// 这个类包含了登录页面的所有业务逻辑和UI构建代码
class _LoginScreenState extends State<LoginScreen> {
  // 表单的全局键，用于控制和管理表单状态
  final _formKey = GlobalKey<FormState>();

  // 用户名输入框的控制器，用于获取和管理输入内容
  final TextEditingController _usernameController = TextEditingController();

  // 密码输入框的控制器，用于获取和管理输入内容
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // 是否正在加载中的状态标志
  bool _isPasswordVisible = false; // 密码是否可见的状态标志
  bool _dialogVisible = false; // 提示对话框是否可见的状态标志

  /// 模拟登录过程的异步方法
  ///
  /// 这个方法处理登录逻辑，包括验证输入和模拟网络请求
  /// 在实际应用中，这里会替换为真实的API调用[4](@ref)
  void _simulateLogin() async {
    // 更新状态，显示加载中UI
    setState(() {
      _isLoading = true;
      _dialogVisible = false; // 隐藏之前的错误对话框
    });

    // 简单的输入验证逻辑
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      // 如果用户名或密码为空，显示提示对话框
      setState(() {
        _isLoading = false;
        _dialogVisible = true;
      });
      return; // 直接返回，不执行后续请求
    }

    // 替换为你的实际 API 端点
    final String apiUrl = "http://localhost:8083/control/login";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'name': _usernameController.text,
          'password': _passwordController.text,
        },
      );
      print(response.body); // 打印响应体，调试用
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['code'] == 200) {
          // 登录成功
          print('登录成功: ${responseData['message']}');
        } else {
          // 登录失败
          print('登录失败: ${responseData['message']}');
        }
      } else {
        // 请求失败
        print('请求失败:');
      }
    } catch (error) {
      print('请求发生错误: $error');
      // 显示错误信息给用户
    } finally {
      // 确保在请求完成或出错后隐藏加载圈
      setState(() {
        _isLoading = false;
      });
      // 无论成功或失败都跳转
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MeetingCheckInScreen()),
      );
    }
  }

  /// 构建登录页面的UI
  ///
  /// 这个方法返回登录页面的完整Widget树
  /// @param context 构建上下文
  /// @return 返回登录页面的Scaffold组件
  @override
  Widget build(BuildContext context) {
    // 使用Scaffold作为页面骨架，提供基本的Material Design布局结构
    return Scaffold(
      // 页面的主体部分，使用Stack实现图层叠加效果
      body: Stack(
        children: [
          // 背景容器，显示渐变背景色
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/baodao.jpg'), // 你的图片路径
                fit: BoxFit.cover, // 让图片覆盖整个屏幕
              ),
            ),
          ),

          // 中心内容区域，包含登录表单
          Center(
            child: SingleChildScrollView(
              // 支持滚动，防止键盘弹出时内容被遮挡
              child: Container(
                width: 400, // 固定宽度
                padding: const EdgeInsets.all(32), // 内边距
                child: Card(
                  // 卡片式设计，提升UI层次感
                  elevation: 8, // 阴影高度
                  shape: RoundedRectangleBorder(
                    // 圆角矩形形状
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24), // 卡片内边距
                    child: Form(
                      // 表单组件，用于管理输入字段和验证
                      key: _formKey, // 表单的全局键
                      child: Column(
                        // 垂直排列的表单字段
                        mainAxisSize: MainAxisSize.min, // 列大小根据内容调整
                        children: [
                          // 登录标题
                          Text(
                            '系统登录',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'FZXBYS',
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // 深蓝色文字
                            ),
                          ),
                          const SizedBox(height: 32), // 间距
                          // 用户名输入框
                          TextFormField(
                            controller: _usernameController, // 控制器
                            decoration: InputDecoration(
                              labelText: '账号', // 标签文字
                              prefixIcon: const Icon(Icons.person), // 前缀图标
                              border: OutlineInputBorder(
                                // 边框样式
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                // 内容边距
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              // 验证器函数
                              if (value == null || value.isEmpty) {
                                return '请输入账号'; // 验证失败的消息
                              }
                              return null; // 验证成功
                            },
                            onFieldSubmitted: (_) => _simulateLogin(), // 回车键提交
                          ),
                          const SizedBox(height: 20), // 间距
                          // 密码输入框
                          TextFormField(
                            controller: _passwordController, // 控制器
                            obscureText: !_isPasswordVisible, // 是否隐藏文本（密码）
                            decoration: InputDecoration(
                              labelText: '密码', // 标签文字
                              prefixIcon: const Icon(Icons.lock), // 前缀图标
                              suffixIcon: IconButton(
                                // 后缀图标（眼睛按钮）
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons
                                            .visibility // 可见状态图标
                                      : Icons.visibility_off, // 不可见状态图标
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  // 切换密码可见状态
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                // 边框样式
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                // 内容边距
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              // 验证器函数
                              if (value == null || value.isEmpty) {
                                return '请输入密码'; // 验证失败的消息
                              }
                              return null; // 验证成功
                            },
                            onFieldSubmitted: (_) => _simulateLogin(), // 回车键提交
                          ),
                          const SizedBox(height: 32), // 间距
                          // 登录按钮
                          SizedBox(
                            width: double.infinity, // 宽度充满父容器
                            height: 50, // 固定高度
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _simulateLogin, // 加载时禁用按钮
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF900000), // 按钮背景色
                                shape: RoundedRectangleBorder(
                                  // 按钮形状
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ), // 按钮内边距
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      // 加载中显示进度指示器
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2, // 进度条粗细
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ), // 进度条颜色
                                      ),
                                    )
                                  : const Text(
                                      // 正常状态显示文字
                                      '登      录',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontFamily: 'FZXBYS',
                                        color: Colors.white,
                                      ),
                                    ),
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

          // 提示对话框，根据_dialogVisible状态决定是否显示
          if (_dialogVisible)
            AlertDialog(
              title: const Text('温馨提示'), // 对话框标题
              content: const Text('请输入账号和密码'), // 对话框内容
              actions: [
                TextButton(
                  onPressed: () {
                    // 点击确定按钮，隐藏对话框
                    setState(() {
                      _dialogVisible = false;
                    });
                  },
                  child: const Text('确定'), // 按钮文字
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 组件销毁时调用的方法
  ///
  /// 用于释放资源和清理控制器，防止内存泄漏[4](@ref)
  @override
  void dispose() {
    _usernameController.dispose(); // 释放用户名控制器
    _passwordController.dispose(); // 释放密码控制器
    super.dispose(); // 调用父类的dispose方法
  }
}
