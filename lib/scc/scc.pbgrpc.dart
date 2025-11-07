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

class QueryApiClient extends $grpc.Client {
  QueryApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);
}

abstract class QueryApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.QueryApi';

  QueryApiServiceBase() {}
}

class CompareChipClient extends $grpc.Client {
  CompareChipClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);
}

abstract class CompareChipServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.CompareChip';

  CompareChipServiceBase() {}
}

class SloganApiClient extends $grpc.Client {
  SloganApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);
}

abstract class SloganApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.SloganApi';

  SloganApiServiceBase() {}
}

class PortableApiClient extends $grpc.Client {
  PortableApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);
}

abstract class PortableApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.PortableApi';

  PortableApiServiceBase() {}
}

class CommonApiClient extends $grpc.Client {
  CommonApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);
}

abstract class CommonApiServiceBase extends $grpc.Service {
  $core.String get $name => 'scc.CommonApi';

  CommonApiServiceBase() {}
}
