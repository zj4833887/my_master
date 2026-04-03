import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/login.dart';
import 'scc/scc_client.dart';
import 'utils/local_exit_api.dart';
import 'utils/show_exit_confirm_dialog.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

bool get _isDesktopPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var desktopExitConfirm = false;
  if (_isDesktopPlatform) {
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);
    desktopExitConfirm = true;
  }

  // 在程序启动时设置客户端类型为 Server
  SccClientWrapper.setProcessType('Server').then((result) {
    if (result.isSuccess) {
      print('设置客户端类型成功: Server');
    } else {
      print('设置客户端类型失败: ${result.msg}');
    }
  }).catchError((error) {
    print('设置客户端类型出错: $error');
  });

  runApp(MyApp(desktopExitConfirm: desktopExitConfirm));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.desktopExitConfirm});

  /// Windows / Linux / macOS：拦截系统关闭（标题栏 X、Alt+F4 等），弹出确认框。
  final bool desktopExitConfirm;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver, WindowListener {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.desktopExitConfirm) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (widget.desktopExitConfirm) {
      windowManager.removeListener(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // 程序即将退出（桌面窗口关闭/进程销毁等），通知后端一次即可。
      unawaited(LocalExitApi.callExit());
    }
  }

  @override
  void onWindowClose() {
    if (!widget.desktopExitConfirm) return;
    unawaited(_handleDesktopWindowClose());
  }

  Future<void> _handleDesktopWindowClose() async {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) {
      await windowManager.setPreventClose(false);
      await windowManager.close();
      return;
    }
    if (!await showExitConfirmDialog(ctx)) return;
    await LocalExitApi.callExit();
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: '主控终端',
      theme: ThemeData(
        fontFamily: 'Microsoft YaHei',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(), // 登录页路由
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
