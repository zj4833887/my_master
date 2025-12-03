import 'dart:async';
import 'dart:convert';
import 'scc.dart';
import 'scc.pb.dart';
import '../config/scc_config.dart';
import 'board.dart';

/// API 响应结果封装
class ApiResult<T> {
  final int code;
  final String msg;
  final T? data;

  ApiResult({
    required this.code,
    required this.msg,
    this.data,
  });

  bool get isSuccess => code == 200;
}

class SccClientWrapper {
  SccClientWrapper._();

  static Scc? _client;

  static Scc get instance {
    _client ??= Scc(SccConfig.host, SccConfig.port);
    return _client!;
  }

  static Future<void> close() async {
    await _client?.close();
    _client = null;
  }

  // 示例方法封装，便于调用
  static Future<ApiResult<String>> ping() async {
    try {
      final resp = await instance.ping();
      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: resp.toString(),
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: null,
      );
    }
  }

  static Future<ApiResult<bool>> login({required String name, required String password}) async {
    try {
      final req = LoginRequest(name: name, password: password);
      final resp = await instance.client.login(req);
      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: resp.code == 200,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  static Future<ApiResult<bool>> setMeet(String meetID) async {
    try {
      final req = MeetReq(meetID: meetID);
      final greq = GRequest(mreq: req);
      final resp = await instance.client.setMeet(greq);
      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: resp.code == 200,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  static Future<ApiResult<List<dynamic>>> queryMeet({String? meetID}) async {
    try {
      // 无参调用：不设置 meetID 字段
      final req = (meetID == null || meetID.isEmpty)
          ? MeetReq()
          : MeetReq(meetID: meetID);
      final greq = req.hasMeetID() && req.meetID.isNotEmpty
          ? GRequest(mreq: req)
          : GRequest();
      final resp = await instance.client.queryMeet(greq);
      
      if (resp.code != 200) {
        return ApiResult(
          code: resp.code,
          msg: resp.msg,
          data: null,
        );
      }

      if (resp.data.isEmpty) {
        return ApiResult(
          code: resp.code,
          msg: '服务器返回空数据',
          data: [],
        );
      }

      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: jsonDecode(resp.data) as List<dynamic>,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: null,
      );
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> queryMeetInfo(String meetID) async {
    try {
      final req = MeetReq(meetID: meetID);
      final greq = GRequest(mreq: req);
      final resp = await instance.client.queryMeetInfo(greq);
      
      if (resp.code != 200) {
        return ApiResult(
          code: resp.code,
          msg: resp.msg,
          data: null,
        );
      }

      if (resp.data.isEmpty) {
        return ApiResult(
          code: resp.code,
          msg: '服务器返回空数据',
          data: {},
        );
      }

      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: jsonDecode(resp.data) as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: null,
      );
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> queryOnMeet() async {
    try {
      final req = GRequest();
      final resp = await instance.client.queryOnMeet(req);
      
      if (resp.code != 200) {
        return ApiResult(
          code: resp.code,
          msg: resp.msg,
          data: null,
        );
      }

      if (resp.data.isEmpty) {
        return ApiResult(
          code: resp.code,
          msg: '服务器返回空数据',
          data: {},
        );
      }

      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: jsonDecode(resp.data) as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: null,
      );
    }
  }

  static Future<ApiResult<bool>> continueMeet(String meetID) async {
    try {
      final req = MeetReq(meetID: meetID);
      final greq = GRequest(mreq: req);
      final resp = await instance.client.continueMeet(greq);
      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: resp.code == 200,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  // 开始会议
  static Future<ApiResult<bool>> startMeet(String meetID) async {
    try {
      final req = MeetReq(meetID: meetID);
      final greq = GRequest(mreq: req);
      final resp = await instance.client.startMeet(greq);
      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: resp.code == 200,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  // 结束会议
  static Future<ApiResult<bool>> endMeet(String meetID) async {
    try {
      final req = MeetReq(meetID: meetID);
      final greq = GRequest(mreq: req);
      final resp = await instance.client.endMeet(greq);
      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: resp.code == 200,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  // 查询客户端
  static Future<ApiResult<List<dynamic>>> queryClient() async {
    try {
      final result = await instance.queryClient();
      return ApiResult(
        code: 200,
        msg: '成功',
        data: result,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: null,
      );
    }
  }

  // 数据检查
  static Future<ApiResult<bool>> databaseCheck({
    required String meetID,
    required String stations,
    required String tables,
  }) async {
    try {
      final req = CheckReq(
        meetID: meetID,
        stations: stations,
        tables: tables,
      );
      final greq = GRequest(creq: req);
      final resp = await instance.client.databaseCheck(greq);
      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: resp.code == 200,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  // 结束数据检查
  static Future<ApiResult<bool>> endDatabaseCheck() async {
    try {
      final req = CheckReq();
      final greq = GRequest(creq: req);
      final resp = await instance.client.endDatabaseCheck(greq);
      return ApiResult(
        code: resp.code,
        msg: resp.msg,
        data: resp.code == 200,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  // 上报报到失败数据
  static Future<ApiResult<bool>> reportCheckInFailed({
    required String meetID,
    required String stations,
  }) async {
    try {
      final req = CheckReq(
        meetID: meetID,
        stations: stations,
      );
      final result = await instance.reportCheckInFailed(req);
      return ApiResult(
        code: 200,
        msg: '成功',
        data: result,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  // 导入报到记录
  static Future<ApiResult<String>> importRecord(List<int> fileData) async {
    try {
      final req = ImportReq(file: fileData);
      final result = await instance.importRecord(req);
      return ApiResult(
        code: 200,
        msg: result,
        data: result,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: null,
      );
    }
  }

  // 订阅指标数据流，处理 NormalData -> DeviceRouteMap
  static StreamSubscription<MetricMsg>? subscribeMetricsData({
    required MetricBoard metricBoard,
    required Function(Map<String, dynamic> data, String channel) onData,
    Function(String error)? onError,
  }) {
    try {
      final stream = instance.subscribeMetrics();
      final subscription = stream.listen(
        (MetricMsg msg) {
          print('msg: $msg');
          // 只关心 NormalData，并且 remark 为 WS_CheckInInfo 的消息
          if (msg.type == NormalData) {
            try {
              final jsonData = jsonDecode(msg.data) as Map<String, dynamic>;
              final channel = msg.channel;
              final remark = jsonData['remark']?.toString() ?? '';
              print('remark: $remark');
              if (remark == 'WS_CheckInInfo') {
                // 仅输出 WS_CheckInInfo 的 gRPC 数据，减少日志噪音
                print(
                    'WS_CheckInInfo MetricMsg -> channel:$channel data:$jsonData');
              }

              if (channel.isNotEmpty) {
                final routeKey = 'channel_$channel';
                metricBoard.DeviceRouteMap[routeKey] = jsonData;
              } else {
                metricBoard.DeviceRouteMap['default'] = jsonData;
              }

              onData(jsonData, channel);
            } catch (e) {
              onError?.call('解析数据错误: $e');
            }
          } else if (msg.type == HeartBeat) {
            // 心跳数据，无需处理
          } else if (msg.type == OriginalData) {
            // 原始数据，不做处理
          }
        },
        onError: (error) {
          onError?.call(error.toString());
        },
        onDone: () {
          // 流结束
        },
      );

      return subscription;
    } catch (e) {
      onError?.call(e.toString());
      return null;
    }
  }
}


