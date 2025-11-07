import 'dart:convert';
import 'dart:typed_data';
import 'package:grpc/grpc.dart';
import './scc.pb.dart';
import './scc.pbgrpc.dart';

class Scc {
  late ClientChannel channel;
  late CtrlApiClient client;

  Scc(String host, int port) {
    channel = ClientChannel (
      host,
      port: port,
      options: ChannelOptions(
        credentials: const ChannelCredentials.insecure(),
        codecRegistry: CodecRegistry(codecs: const [GzipCodec()]),
      ),
    );
    client = CtrlApiClient(channel);
  }

  Future<void> close() async {
    await channel.shutdown();
  }

  // 调用测试
  Future<GResponse> ping([Map<String, String>? req]) async {
    try {
      final ur = CustomReq();
      if (req?.isNotEmpty ?? false) {
        ur.customs.addAll(req!);
      }

      var greq = GRequest(customs: ur);
      final resp = await client.ping(greq);
      return resp;
    } catch (e) {
      rethrow;
    }
  }

  // 查询会议 parameters 参数
  Future<Map<String, dynamic>> queryNoDatabaseParameters() async {
    try {
      final req = GRequest();
      final resp = await client.queryNoDatabaseParameters(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      if (resp.data.isEmpty) {
        throw Exception('服务器返回空数据');
      }

      return jsonDecode(resp.data) as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // 查询会议
  Future<List<dynamic>> queryMeet(MeetReq r) async {
    try {
      // 后端无参获取列表时不应携带 mreq
      final req = r.hasMeetID() && r.meetID.isNotEmpty
          ? GRequest(mreq: r)
          : GRequest();
      final resp = await client.queryMeet(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      if (resp.data.isEmpty) {
        throw Exception('服务器返回空数据');
      }

      return jsonDecode(resp.data);
    } catch (e) {
      rethrow;
    }
  }

  // 设置会议
  Future<bool> setMeet(MeetReq r) async {
    try {
      final greq = GRequest(mreq: r);
      final resp = await client.setMeet(greq);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // 开始会议
  Future<bool> startMeet(MeetReq r) async {
    try {
      final req = GRequest(mreq: r);
      final resp = await client.startMeet(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // 结束会议
  Future<bool> endMeet(MeetReq r) async {
    try {
      final req = GRequest(mreq: r);
      final resp = await client.endMeet(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // 继续会议
  Future<bool> continueMeet(MeetReq r) async {
    try {
      final req = GRequest(mreq: r);
      final resp = await client.continueMeet(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // 登录
  Future<bool> login(LoginRequest req) async {
    try {
      final resp = await client.login(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // 数据校验
  Future<bool> databaseCheck(CheckReq r) async {
    try {
      final req = GRequest(creq: r);
      final resp = await client.databaseCheck(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // 结束数据校验
  Future<bool> endDatabaseCheck(CheckReq r) async {
    try {
      final req = GRequest(creq: r);
      final resp = await client.endDatabaseCheck(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  //上报报到失败数据
  Future<bool> reportCheckInFailed(CheckReq r) async {
    try {
      final req = GRequest(creq: r);
      final resp = await client.reportCheckInFailed(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  //导入报到记录
  Future<String> importRecord(ImportReq r) async {
    try {
      final req = GRequest(ireq: r);
      final resp = await client.importRecord(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      return resp.msg;
    } catch (e) {
      rethrow;
    }
  }

  //查询客户端
  Future<List<dynamic>> queryClient() async {
    try {
      final req = GRequest();
      final resp = await client.queryClient(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      if (resp.data.isEmpty) {
        throw Exception('服务器返回空数据');
      }

      return jsonDecode(resp.data);
    } catch (e) {
      rethrow;
    }
  }

  //查寻当前会议
  Future<dynamic> queryOnMeet() async {
    try {
      final req = GRequest();
      final resp = await client.queryOnMeet(req);

      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      if (resp.data.isEmpty) {
        throw Exception('服务器返回空数据');
      }

      return jsonDecode(resp.data);
    } catch (e) {
      rethrow;
    }
  }

  //查询会议信息
  Future<dynamic> queryMeetInfo(MeetReq r) async {
    try {
      final req = GRequest(mreq: r);
      final resp = await client.queryMeetInfo(req);
      if (resp.code != 200) {
        throw Exception('请求失败，错误码: ${resp.code}, 消息: ${resp.msg}');
      }

      if (resp.data.isEmpty) {
        throw Exception('服务器返回空数据');
      }

      return jsonDecode(resp.data);
    } catch (e) {
      rethrow;
    }
  }
}