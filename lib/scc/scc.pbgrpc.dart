///
//  Generated code. Do not modify.
//  source: scc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'scc.pb.dart' as $0;
export 'scc.pb.dart';

class CtrlApiClient extends $grpc.Client {
  static final _$ping = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/Ping',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryNoDatabaseParameters =
      $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
          '/scc.CtrlApi/QueryNoDatabaseParameters',
          ($0.GRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryMeet = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/QueryMeet',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$setMeet = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/SetMeet',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$startMeet = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/StartMeet',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$endMeet = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/EndMeet',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$continueMeet = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/ContinueMeet',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.GResponse>(
      '/scc.CtrlApi/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$databaseCheck = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/DatabaseCheck',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$endDatabaseCheck =
      $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
          '/scc.CtrlApi/EndDatabaseCheck',
          ($0.GRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$reportCheckInFailed =
      $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
          '/scc.CtrlApi/ReportCheckInFailed',
          ($0.GRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$importRecord = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/ImportRecord',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryClient = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/QueryClient',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryOnMeet = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/QueryOnMeet',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryMeetInfo = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.CtrlApi/QueryMeetInfo',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));

  CtrlApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GResponse> ping($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ping, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryNoDatabaseParameters(
      $0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryNoDatabaseParameters, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryMeet($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryMeet, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> setMeet($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setMeet, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> startMeet($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$startMeet, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> endMeet($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$endMeet, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> continueMeet($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$continueMeet, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> login($0.LoginRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$login, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> databaseCheck($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$databaseCheck, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> endDatabaseCheck($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$endDatabaseCheck, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> reportCheckInFailed($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$reportCheckInFailed, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> importRecord($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$importRecord, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryClient($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryClient, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryOnMeet($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryOnMeet, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryMeetInfo($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryMeetInfo, request, options: options);
  }
}

abstract class CtrlApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.CtrlApi';

  CtrlApiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'Ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'QueryNoDatabaseParameters',
        queryNoDatabaseParameters_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'QueryMeet',
        queryMeet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'SetMeet',
        setMeet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'StartMeet',
        startMeet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'EndMeet',
        endMeet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'ContinueMeet',
        continueMeet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.GResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'DatabaseCheck',
        databaseCheck_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'EndDatabaseCheck',
        endDatabaseCheck_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'ReportCheckInFailed',
        reportCheckInFailed_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'ImportRecord',
        importRecord_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'QueryClient',
        queryClient_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'QueryOnMeet',
        queryOnMeet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'QueryMeetInfo',
        queryMeetInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GResponse> ping_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return ping(call, await request);
  }

  $async.Future<$0.GResponse> queryNoDatabaseParameters_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return queryNoDatabaseParameters(call, await request);
  }

  $async.Future<$0.GResponse> queryMeet_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return queryMeet(call, await request);
  }

  $async.Future<$0.GResponse> setMeet_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return setMeet(call, await request);
  }

  $async.Future<$0.GResponse> startMeet_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return startMeet(call, await request);
  }

  $async.Future<$0.GResponse> endMeet_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return endMeet(call, await request);
  }

  $async.Future<$0.GResponse> continueMeet_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return continueMeet(call, await request);
  }

  $async.Future<$0.GResponse> login_Pre(
      $grpc.ServiceCall call, $async.Future<$0.LoginRequest> request) async {
    return login(call, await request);
  }

  $async.Future<$0.GResponse> databaseCheck_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return databaseCheck(call, await request);
  }

  $async.Future<$0.GResponse> endDatabaseCheck_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return endDatabaseCheck(call, await request);
  }

  $async.Future<$0.GResponse> reportCheckInFailed_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return reportCheckInFailed(call, await request);
  }

  $async.Future<$0.GResponse> importRecord_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return importRecord(call, await request);
  }

  $async.Future<$0.GResponse> queryClient_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return queryClient(call, await request);
  }

  $async.Future<$0.GResponse> queryOnMeet_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return queryOnMeet(call, await request);
  }

  $async.Future<$0.GResponse> queryMeetInfo_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return queryMeetInfo(call, await request);
  }

  $async.Future<$0.GResponse> ping($grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> queryNoDatabaseParameters(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> queryMeet(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> setMeet(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> startMeet(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> endMeet(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> continueMeet(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> login(
      $grpc.ServiceCall call, $0.LoginRequest request);
  $async.Future<$0.GResponse> databaseCheck(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> endDatabaseCheck(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> reportCheckInFailed(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> importRecord(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> queryClient(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> queryOnMeet(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> queryMeetInfo(
      $grpc.ServiceCall call, $0.GRequest request);
}

class SeatMapApiClient extends $grpc.Client {
  static final _$queryMapInfo = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.SeatMapApi/QueryMapInfo',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryMapList = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.SeatMapApi/QueryMapList',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$update = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.SeatMapApi/Update',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));

  SeatMapApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GResponse> queryMapInfo($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryMapInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryMapList($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryMapList, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> update($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$update, request, options: options);
  }
}

abstract class SeatMapApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.SeatMapApi';

  SeatMapApiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'QueryMapInfo',
        queryMapInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'QueryMapList',
        queryMapList_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GResponse> queryMapInfo_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return queryMapInfo(call, await request);
  }

  $async.Future<$0.GResponse> queryMapList_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return queryMapList(call, await request);
  }

  $async.Future<$0.GResponse> update_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return update(call, await request);
  }

  $async.Future<$0.GResponse> queryMapInfo(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> queryMapList(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> update(
      $grpc.ServiceCall call, $0.GRequest request);
}

class QueryApiClient extends $grpc.Client {
  static final _$cancelCheckIn = $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
      '/scc.QueryApi/cancelCheckIn',
      ($0.QueryReq value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryPersonCheckInfo =
      $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
          '/scc.QueryApi/queryPersonCheckInfo',
          ($0.QueryReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$querySearchInfo =
      $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
          '/scc.QueryApi/querySearchInfo',
          ($0.QueryReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$querySignInInfo =
      $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
          '/scc.QueryApi/querySignInInfo',
          ($0.QueryReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$replenishCheckIn =
      $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
          '/scc.QueryApi/replenishCheckIn',
          ($0.QueryReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$photoName = $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
      '/scc.QueryApi/photoName',
      ($0.QueryReq value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryOutPerson = $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
      '/scc.QueryApi/queryOutPerson',
      ($0.QueryReq value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryPersonCheckInLog =
      $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
          '/scc.QueryApi/queryPersonCheckInLog',
          ($0.QueryReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryLeaveCheckinPerson =
      $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
          '/scc.QueryApi/queryLeaveCheckinPerson',
          ($0.QueryReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$cancelLeaveCheckin =
      $grpc.ClientMethod<$0.QueryReq, $0.GResponse>(
          '/scc.QueryApi/cancelLeaveCheckin',
          ($0.QueryReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));

  QueryApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GResponse> cancelCheckIn($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$cancelCheckIn, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryPersonCheckInfo($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryPersonCheckInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> querySearchInfo($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$querySearchInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> querySignInInfo($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$querySignInInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> replenishCheckIn($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$replenishCheckIn, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> photoName($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$photoName, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryOutPerson($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryOutPerson, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryPersonCheckInLog($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryPersonCheckInLog, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryLeaveCheckinPerson(
      $0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryLeaveCheckinPerson, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> cancelLeaveCheckin($0.QueryReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$cancelLeaveCheckin, request, options: options);
  }
}

abstract class QueryApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.QueryApi';

  QueryApiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'cancelCheckIn',
        cancelCheckIn_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'queryPersonCheckInfo',
        queryPersonCheckInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'querySearchInfo',
        querySearchInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'querySignInInfo',
        querySignInInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'replenishCheckIn',
        replenishCheckIn_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'photoName',
        photoName_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'queryOutPerson',
        queryOutPerson_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'queryPersonCheckInLog',
        queryPersonCheckInLog_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'queryLeaveCheckinPerson',
        queryLeaveCheckinPerson_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryReq, $0.GResponse>(
        'cancelLeaveCheckin',
        cancelLeaveCheckin_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueryReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GResponse> cancelCheckIn_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return cancelCheckIn(call, await request);
  }

  $async.Future<$0.GResponse> queryPersonCheckInfo_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return queryPersonCheckInfo(call, await request);
  }

  $async.Future<$0.GResponse> querySearchInfo_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return querySearchInfo(call, await request);
  }

  $async.Future<$0.GResponse> querySignInInfo_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return querySignInInfo(call, await request);
  }

  $async.Future<$0.GResponse> replenishCheckIn_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return replenishCheckIn(call, await request);
  }

  $async.Future<$0.GResponse> photoName_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return photoName(call, await request);
  }

  $async.Future<$0.GResponse> queryOutPerson_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return queryOutPerson(call, await request);
  }

  $async.Future<$0.GResponse> queryPersonCheckInLog_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return queryPersonCheckInLog(call, await request);
  }

  $async.Future<$0.GResponse> queryLeaveCheckinPerson_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return queryLeaveCheckinPerson(call, await request);
  }

  $async.Future<$0.GResponse> cancelLeaveCheckin_Pre(
      $grpc.ServiceCall call, $async.Future<$0.QueryReq> request) async {
    return cancelLeaveCheckin(call, await request);
  }

  $async.Future<$0.GResponse> cancelCheckIn(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> queryPersonCheckInfo(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> querySearchInfo(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> querySignInInfo(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> replenishCheckIn(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> photoName(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> queryOutPerson(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> queryPersonCheckInLog(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> queryLeaveCheckinPerson(
      $grpc.ServiceCall call, $0.QueryReq request);
  $async.Future<$0.GResponse> cancelLeaveCheckin(
      $grpc.ServiceCall call, $0.QueryReq request);
}

class SloganApiClient extends $grpc.Client {
  static final _$send = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.SloganApi/send',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$query = $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
      '/scc.SloganApi/query',
      ($0.GRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));
  static final _$queryCurrentSlog =
      $grpc.ClientMethod<$0.GRequest, $0.GResponse>(
          '/scc.SloganApi/queryCurrentSlog',
          ($0.GRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));

  SloganApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GResponse> send($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$send, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> query($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$query, request, options: options);
  }

  $grpc.ResponseFuture<$0.GResponse> queryCurrentSlog($0.GRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryCurrentSlog, request, options: options);
  }
}

abstract class SloganApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.SloganApi';

  SloganApiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'send',
        send_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'query',
        query_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GRequest, $0.GResponse>(
        'queryCurrentSlog',
        queryCurrentSlog_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GRequest.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GResponse> send_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return send(call, await request);
  }

  $async.Future<$0.GResponse> query_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return query(call, await request);
  }

  $async.Future<$0.GResponse> queryCurrentSlog_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GRequest> request) async {
    return queryCurrentSlog(call, await request);
  }

  $async.Future<$0.GResponse> send($grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> query(
      $grpc.ServiceCall call, $0.GRequest request);
  $async.Future<$0.GResponse> queryCurrentSlog(
      $grpc.ServiceCall call, $0.GRequest request);
}

class MetricApiClient extends $grpc.Client {
  static final _$ping = $grpc.ClientMethod<$0.MetricReq, $0.MetricConfirm>(
      '/scc.MetricApi/ping',
      ($0.MetricReq value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.MetricConfirm.fromBuffer(value));
  static final _$subscribeMetrics =
      $grpc.ClientMethod<$0.MetricReq, $0.MetricMsg>(
          '/scc.MetricApi/subscribeMetrics',
          ($0.MetricReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.MetricMsg.fromBuffer(value));

  MetricApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.MetricConfirm> ping($0.MetricReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ping, request, options: options);
  }

  $grpc.ResponseStream<$0.MetricMsg> subscribeMetrics($0.MetricReq request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$subscribeMetrics, $async.Stream.fromIterable([request]),
        options: options);
  }
}

abstract class MetricApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.MetricApi';

  MetricApiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.MetricReq, $0.MetricConfirm>(
        'ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MetricReq.fromBuffer(value),
        ($0.MetricConfirm value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MetricReq, $0.MetricMsg>(
        'subscribeMetrics',
        subscribeMetrics_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.MetricReq.fromBuffer(value),
        ($0.MetricMsg value) => value.writeToBuffer()));
  }

  $async.Future<$0.MetricConfirm> ping_Pre(
      $grpc.ServiceCall call, $async.Future<$0.MetricReq> request) async {
    return ping(call, await request);
  }

  $async.Stream<$0.MetricMsg> subscribeMetrics_Pre(
      $grpc.ServiceCall call, $async.Future<$0.MetricReq> request) async* {
    yield* subscribeMetrics(call, await request);
  }

  $async.Future<$0.MetricConfirm> ping(
      $grpc.ServiceCall call, $0.MetricReq request);
  $async.Stream<$0.MetricMsg> subscribeMetrics(
      $grpc.ServiceCall call, $0.MetricReq request);
}

class SignInClientApiClient extends $grpc.Client {
  static final _$setProcessType =
      $grpc.ClientMethod<$0.SignInClientReq, $0.GResponse>(
          '/scc.SignInClientApi/setProcessType',
          ($0.SignInClientReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GResponse.fromBuffer(value));

  SignInClientApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.GResponse> setProcessType($0.SignInClientReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setProcessType, request, options: options);
  }
}

abstract class SignInClientApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.SignInClientApi';

  SignInClientApiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SignInClientReq, $0.GResponse>(
        'setProcessType',
        setProcessType_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SignInClientReq.fromBuffer(value),
        ($0.GResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GResponse> setProcessType_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SignInClientReq> request) async {
    return setProcessType(call, await request);
  }

  $async.Future<$0.GResponse> setProcessType(
      $grpc.ServiceCall call, $0.SignInClientReq request);
}
