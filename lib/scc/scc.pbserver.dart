///
//  Generated code. Do not modify.
//  source: scc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'package:protobuf/protobuf.dart' as $pb;

import 'dart:core' as $core;
import 'scc.pb.dart' as $0;
import 'scc.pbjson.dart';

export 'scc.pb.dart';

abstract class CtrlApiServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GResponse> ping($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryNoDatabaseParameters($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryMeet($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> setMeet($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> startMeet($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> endMeet($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> continueMeet($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> login($pb.ServerContext ctx, $0.LoginRequest request);
  $async.Future<$0.GResponse> databaseCheck($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> endDatabaseCheck($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> reportCheckInFailed($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> importRecord($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryClient($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryOnMeet($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryMeetInfo($pb.ServerContext ctx, $0.GRequest request);

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
      case 'Ping': return $0.GRequest();
      case 'QueryNoDatabaseParameters': return $0.GRequest();
      case 'QueryMeet': return $0.GRequest();
      case 'SetMeet': return $0.GRequest();
      case 'StartMeet': return $0.GRequest();
      case 'EndMeet': return $0.GRequest();
      case 'ContinueMeet': return $0.GRequest();
      case 'Login': return $0.LoginRequest();
      case 'DatabaseCheck': return $0.GRequest();
      case 'EndDatabaseCheck': return $0.GRequest();
      case 'ReportCheckInFailed': return $0.GRequest();
      case 'ImportRecord': return $0.GRequest();
      case 'QueryClient': return $0.GRequest();
      case 'QueryOnMeet': return $0.GRequest();
      case 'QueryMeetInfo': return $0.GRequest();
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
      case 'Ping': return this.ping(ctx, request as $0.GRequest);
      case 'QueryNoDatabaseParameters': return this.queryNoDatabaseParameters(ctx, request as $0.GRequest);
      case 'QueryMeet': return this.queryMeet(ctx, request as $0.GRequest);
      case 'SetMeet': return this.setMeet(ctx, request as $0.GRequest);
      case 'StartMeet': return this.startMeet(ctx, request as $0.GRequest);
      case 'EndMeet': return this.endMeet(ctx, request as $0.GRequest);
      case 'ContinueMeet': return this.continueMeet(ctx, request as $0.GRequest);
      case 'Login': return this.login(ctx, request as $0.LoginRequest);
      case 'DatabaseCheck': return this.databaseCheck(ctx, request as $0.GRequest);
      case 'EndDatabaseCheck': return this.endDatabaseCheck(ctx, request as $0.GRequest);
      case 'ReportCheckInFailed': return this.reportCheckInFailed(ctx, request as $0.GRequest);
      case 'ImportRecord': return this.importRecord(ctx, request as $0.GRequest);
      case 'QueryClient': return this.queryClient(ctx, request as $0.GRequest);
      case 'QueryOnMeet': return this.queryOnMeet(ctx, request as $0.GRequest);
      case 'QueryMeetInfo': return this.queryMeetInfo(ctx, request as $0.GRequest);
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CtrlApiServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => CtrlApiServiceBase$messageJson;
}

abstract class SeatMapApiServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GResponse> queryMapInfo($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryMapList($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> update($pb.ServerContext ctx, $0.GRequest request);

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
      case 'QueryMapInfo': return $0.GRequest();
      case 'QueryMapList': return $0.GRequest();
      case 'Update': return $0.GRequest();
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
      case 'QueryMapInfo': return this.queryMapInfo(ctx, request as $0.GRequest);
      case 'QueryMapList': return this.queryMapList(ctx, request as $0.GRequest);
      case 'Update': return this.update(ctx, request as $0.GRequest);
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SeatMapApiServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SeatMapApiServiceBase$messageJson;
}

abstract class QueryApiServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GResponse> cancelCheckIn($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryPersonCheckInfo($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> querySearchInfo($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> querySignInInfo($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> replenishCheckIn($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> photoName($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryOutPerson($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryPersonCheckInLog($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> queryLeaveCheckinPerson($pb.ServerContext ctx, $0.GRequest request);
  $async.Future<$0.GResponse> cancelLeaveCheckin($pb.ServerContext ctx, $0.GRequest request);

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
      case 'cancelCheckIn': return $0.GRequest();
      case 'queryPersonCheckInfo': return $0.GRequest();
      case 'querySearchInfo': return $0.GRequest();
      case 'querySignInInfo': return $0.GRequest();
      case 'replenishCheckIn': return $0.GRequest();
      case 'photoName': return $0.GRequest();
      case 'queryOutPerson': return $0.GRequest();
      case 'queryPersonCheckInLog': return $0.GRequest();
      case 'queryLeaveCheckinPerson': return $0.GRequest();
      case 'cancelLeaveCheckin': return $0.GRequest();
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
      case 'cancelCheckIn': return this.cancelCheckIn(ctx, request as $0.GRequest);
      case 'queryPersonCheckInfo': return this.queryPersonCheckInfo(ctx, request as $0.GRequest);
      case 'querySearchInfo': return this.querySearchInfo(ctx, request as $0.GRequest);
      case 'querySignInInfo': return this.querySignInInfo(ctx, request as $0.GRequest);
      case 'replenishCheckIn': return this.replenishCheckIn(ctx, request as $0.GRequest);
      case 'photoName': return this.photoName(ctx, request as $0.GRequest);
      case 'queryOutPerson': return this.queryOutPerson(ctx, request as $0.GRequest);
      case 'queryPersonCheckInLog': return this.queryPersonCheckInLog(ctx, request as $0.GRequest);
      case 'queryLeaveCheckinPerson': return this.queryLeaveCheckinPerson(ctx, request as $0.GRequest);
      case 'cancelLeaveCheckin': return this.cancelLeaveCheckin(ctx, request as $0.GRequest);
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => QueryApiServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => QueryApiServiceBase$messageJson;
}

abstract class CommonApiServiceBase extends $pb.GeneratedService {
  $async.Future<$0.PushMsg> websocket($pb.ServerContext ctx, $0.PushReq request);

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
      case 'Websocket': return $0.PushReq();
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
      case 'Websocket': return this.websocket(ctx, request as $0.PushReq);
      default: throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CommonApiServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => CommonApiServiceBase$messageJson;
}

