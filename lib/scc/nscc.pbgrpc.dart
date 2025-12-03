///
//  Generated code. Do not modify.
//  source: nscc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'nscc.pb.dart' as $0;
export 'nscc.pb.dart';

class NCtrlApiClient extends $grpc.Client {
  static final _$queryProgressDiagram = $grpc.ClientMethod<$0.NGReq, $0.NGResp>(
      '/nscc.NCtrlApi/QueryProgressDiagram',
      ($0.NGReq value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.NGResp.fromBuffer(value));
  static final _$setProgressDiagram = $grpc.ClientMethod<$0.NGReq, $0.NGResp>(
      '/nscc.NCtrlApi/SetProgressDiagram',
      ($0.NGReq value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.NGResp.fromBuffer(value));

  NCtrlApiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.NGResp> queryProgressDiagram($0.NGReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryProgressDiagram, request, options: options);
  }

  $grpc.ResponseFuture<$0.NGResp> setProgressDiagram($0.NGReq request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setProgressDiagram, request, options: options);
  }
}

abstract class NCtrlApiServiceBase extends $grpc.Service {
  $core.String get $name => 'nscc.NCtrlApi';

  NCtrlApiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.NGReq, $0.NGResp>(
        'QueryProgressDiagram',
        queryProgressDiagram_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.NGReq.fromBuffer(value),
        ($0.NGResp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.NGReq, $0.NGResp>(
        'SetProgressDiagram',
        setProgressDiagram_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.NGReq.fromBuffer(value),
        ($0.NGResp value) => value.writeToBuffer()));
  }

  $async.Future<$0.NGResp> queryProgressDiagram_Pre(
      $grpc.ServiceCall call, $async.Future<$0.NGReq> request) async {
    return queryProgressDiagram(call, await request);
  }

  $async.Future<$0.NGResp> setProgressDiagram_Pre(
      $grpc.ServiceCall call, $async.Future<$0.NGReq> request) async {
    return setProgressDiagram(call, await request);
  }

  $async.Future<$0.NGResp> queryProgressDiagram(
      $grpc.ServiceCall call, $0.NGReq request);
  $async.Future<$0.NGResp> setProgressDiagram(
      $grpc.ServiceCall call, $0.NGReq request);
}
