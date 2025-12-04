import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
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

class ProgressStepResult {
  final int step;
  final dynamic payload;

  const ProgressStepResult({
    required this.step,
    required this.payload,
  });
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

  static Future<ApiResult<Map<String, dynamic>>> queryDeviceRouteMap(
      {String? meetID}) async {
    try {
      final result = await instance.queryDeviceRouteMap(meetId: meetID);
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
      // 将 List<int> 转换为 base64 字符串
      final fileString = base64Encode(fileData);
      final req = ImportReq(file: fileString);
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

  // 设置客户端类型
  static Future<ApiResult<bool>> setProcessType(String type) async {
    try {
      final preq = PType(type: type);
      final req = SignInClientReq(preq: preq);
      final result = await instance.setProcessType(req);
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
          // NormalData：业务数据（统计、报到点位图等），通过 msg.channel 区分逻辑通道
          if (msg.type == NormalData) {
            try {
              final jsonData = jsonDecode(msg.data) as Map<String, dynamic>;
              final channel = msg.channel; // 这里区分 NormalData / DeviceRouteMap

              // 所有 NormalData 都写入 DeviceRouteMap，key 带上 channel 方便区分
              final routeKey =
                  channel.isNotEmpty ? 'channel_$channel' : 'channel_NormalData';
              metricBoard.DeviceRouteMap[routeKey] = jsonData;

              // 回调到上层，由 UI 根据 channel 决定是统计、点位图还是其他展示
              onData(jsonData, channel);
            } catch (e) {
              onError?.call('解析数据错误: $e');
            }
          } else if (msg.type == HeartBeat) {
            // 心跳数据，无需处理
          } else if (msg.type == OriginalData) {
            // OriginalData：负责 WS_Client / WS_MeetInfo / WS_CheckInInfo / WS_StationNum 等显示类数据
            try {
              final jsonData = jsonDecode(msg.data) as Map<String, dynamic>;
              final remark = jsonData['remark']?.toString() ?? '';

              // 使用 remark 作为 channel 传回上层，方便区分不同 WS_* 类型
              final effectiveChannel =
                  remark.isNotEmpty ? remark : msg.channel;
              onData(jsonData, effectiveChannel);
            } catch (e) {
              onError?.call('解析 OriginalData 错误: $e');
            }
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

  static Future<ApiResult<ProgressStepResult>> queryProgressStep({String? meetID}) async {
    try {
      final result =
          await instance.queryProgressDiagram(meetId: meetID);
      developer.log(
        '477queryProgressDiagram payload: $result',
        name: 'SccClientWrapper',
      );
      final step = _extractProgressStep(result);
      if (step == null) {
        return ApiResult(
          code: -1,
          msg: '解析步骤数据失败',
          data: null,
        );
      }

      return ApiResult(
        code: 200,
        msg: '成功',
        data: ProgressStepResult(step: step, payload: result),
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: null,
      );
    }
  }

  static Future<ApiResult<bool>> setProgressStep({
    required int step,
    String? meetID,
  }) async {
    try {
      final sanitizedStep = step < 1 ? 1 : step;
      final success = await instance.setProgressDiagram(
        step: sanitizedStep,
        meetId: meetID,
      );
      return ApiResult(
        code: success ? 200 : -1,
        msg: success ? '成功' : '更新失败',
        data: success,
      );
    } catch (e) {
      return ApiResult(
        code: -1,
        msg: e.toString(),
        data: false,
      );
    }
  }

  static int? _extractProgressStep(dynamic payload) {
    if (payload == null) return null;
    final normalized = _normalizePayload(payload);

    if (normalized is num) {
      final value = normalized.toInt();
      return value < 1 ? 1 : value;
    }

    if (normalized is Map) {
      final map = normalized.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );

      final directKeys = <String>[
        'step',
        'Step',
        'currentStep',
        'current',
        'progress',
        'progressStep',
        'completedStep',
        'value',
      ];

      for (final key in directKeys) {
        if (map.containsKey(key)) {
          final candidate = _extractProgressStep(map[key]);
          if (candidate != null) {
            return candidate;
          }
        }
      }

      for (final nestedKey in ['data', 'steps', 'list', 'items', 'diagram']) {
        if (map.containsKey(nestedKey)) {
          final candidate = _extractProgressStep(map[nestedKey]);
          if (candidate != null) {
            return candidate;
          }
        }
      }

      final maybeStep = map['step'];
      final executed = map['executed'];
      if (maybeStep is num) {
        if (executed is bool) {
          if (executed) {
            return maybeStep.toInt();
          }
        } else {
          return maybeStep.toInt();
        }
      }

      return null;
    }

    if (normalized is List) {
      int? highest;
      for (final item in normalized) {
        final candidate = _extractProgressStep(item);
        if (candidate != null) {
          if (highest == null || candidate > highest) {
            highest = candidate;
          }
        }
      }
      return highest;
    }

    return null;
  }

  static dynamic _normalizePayload(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      final numeric = int.tryParse(trimmed);
      if (numeric != null) {
        return numeric;
      }
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          return jsonDecode(trimmed);
        } catch (_) {
          return value;
        }
      }
    }
    return value;
  }
}


