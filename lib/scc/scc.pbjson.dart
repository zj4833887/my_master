///
//  Generated code. Do not modify.
//  source: scc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = const {
  '1': 'LoginRequest',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode('CgxMb2dpblJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIaCghwYXNzd29yZBgCIAEoCVIIcGFzc3dvcmQ=');
@$core.Deprecated('Use gRequestDescriptor instead')
const GRequest$json = const {
  '1': 'GRequest',
  '2': const [
    const {'1': 'mreq', '3': 1, '4': 1, '5': 11, '6': '.scc.MeetReq', '9': 0, '10': 'mreq'},
    const {'1': 'creq', '3': 2, '4': 1, '5': 11, '6': '.scc.CheckReq', '9': 0, '10': 'creq'},
    const {'1': 'ireq', '3': 3, '4': 1, '5': 11, '6': '.scc.ImportReq', '9': 0, '10': 'ireq'},
    const {'1': 'freq', '3': 4, '4': 1, '5': 11, '6': '.scc.ReportCheckFailedReq', '9': 0, '10': 'freq'},
    const {'1': 'customs', '3': 5, '4': 1, '5': 11, '6': '.scc.CustomReq', '9': 0, '10': 'customs'},
  ],
  '8': const [
    const {'1': 'req'},
  ],
};

/// Descriptor for `GRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gRequestDescriptor = $convert.base64Decode('CghHUmVxdWVzdBIiCgRtcmVxGAEgASgLMgwuc2NjLk1lZXRSZXFIAFIEbXJlcRIjCgRjcmVxGAIgASgLMg0uc2NjLkNoZWNrUmVxSABSBGNyZXESJAoEaXJlcRgDIAEoCzIOLnNjYy5JbXBvcnRSZXFIAFIEaXJlcRIvCgRmcmVxGAQgASgLMhkuc2NjLlJlcG9ydENoZWNrRmFpbGVkUmVxSABSBGZyZXESKgoHY3VzdG9tcxgFIAEoCzIOLnNjYy5DdXN0b21SZXFIAFIHY3VzdG9tc0IFCgNyZXE=');
@$core.Deprecated('Use customReqDescriptor instead')
const CustomReq$json = const {
  '1': 'CustomReq',
  '2': const [
    const {'1': 'customs', '3': 1, '4': 3, '5': 11, '6': '.scc.CustomReq.CustomsEntry', '10': 'customs'},
  ],
  '3': const [CustomReq_CustomsEntry$json],
};

@$core.Deprecated('Use customReqDescriptor instead')
const CustomReq_CustomsEntry$json = const {
  '1': 'CustomsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `CustomReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customReqDescriptor = $convert.base64Decode('CglDdXN0b21SZXESNQoHY3VzdG9tcxgBIAMoCzIbLnNjYy5DdXN0b21SZXEuQ3VzdG9tc0VudHJ5UgdjdXN0b21zGjoKDEN1c3RvbXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');
@$core.Deprecated('Use meetReqDescriptor instead')
const MeetReq$json = const {
  '1': 'MeetReq',
  '2': const [
    const {'1': 'MeetID', '3': 1, '4': 1, '5': 9, '10': 'MeetID'},
  ],
};

/// Descriptor for `MeetReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetReqDescriptor = $convert.base64Decode('CgdNZWV0UmVxEhYKBk1lZXRJRBgBIAEoCVIGTWVldElE');
@$core.Deprecated('Use checkReqDescriptor instead')
const CheckReq$json = const {
  '1': 'CheckReq',
  '2': const [
    const {'1': 'meetID', '3': 1, '4': 1, '5': 9, '10': 'meetID'},
    const {'1': 'stations', '3': 2, '4': 1, '5': 9, '10': 'stations'},
    const {'1': 'tables', '3': 3, '4': 1, '5': 9, '10': 'tables'},
  ],
};

/// Descriptor for `CheckReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkReqDescriptor = $convert.base64Decode('CghDaGVja1JlcRIWCgZtZWV0SUQYASABKAlSBm1lZXRJRBIaCghzdGF0aW9ucxgCIAEoCVIIc3RhdGlvbnMSFgoGdGFibGVzGAMgASgJUgZ0YWJsZXM=');
@$core.Deprecated('Use reportCheckFailedReqDescriptor instead')
const ReportCheckFailedReq$json = const {
  '1': 'ReportCheckFailedReq',
  '2': const [
    const {'1': 'meetID', '3': 1, '4': 1, '5': 9, '10': 'meetID'},
    const {'1': 'stations', '3': 2, '4': 1, '5': 9, '10': 'stations'},
  ],
};

/// Descriptor for `ReportCheckFailedReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reportCheckFailedReqDescriptor = $convert.base64Decode('ChRSZXBvcnRDaGVja0ZhaWxlZFJlcRIWCgZtZWV0SUQYASABKAlSBm1lZXRJRBIaCghzdGF0aW9ucxgCIAEoCVIIc3RhdGlvbnM=');
@$core.Deprecated('Use importReqDescriptor instead')
const ImportReq$json = const {
  '1': 'ImportReq',
  '2': const [
    const {'1': 'file', '3': 1, '4': 1, '5': 12, '10': 'file'},
  ],
};

/// Descriptor for `ImportReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importReqDescriptor = $convert.base64Decode('CglJbXBvcnRSZXESEgoEZmlsZRgBIAEoDFIEZmlsZQ==');
@$core.Deprecated('Use gResponseDescriptor instead')
const GResponse$json = const {
  '1': 'GResponse',
  '2': const [
    const {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    const {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    const {'1': 'data', '3': 3, '4': 1, '5': 9, '10': 'data'},
    const {'1': 'remark', '3': 4, '4': 1, '5': 9, '10': 'remark'},
  ],
};

/// Descriptor for `GResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gResponseDescriptor = $convert.base64Decode('CglHUmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIQCgNtc2cYAiABKAlSA21zZxISCgRkYXRhGAMgASgJUgRkYXRhEhYKBnJlbWFyaxgEIAEoCVIGcmVtYXJr');
@$core.Deprecated('Use pushReqDescriptor instead')
const PushReq$json = const {
  '1': 'PushReq',
};

/// Descriptor for `PushReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushReqDescriptor = $convert.base64Decode('CgdQdXNoUmVx');
@$core.Deprecated('Use pushMsgDescriptor instead')
const PushMsg$json = const {
  '1': 'PushMsg',
};

/// Descriptor for `PushMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushMsgDescriptor = $convert.base64Decode('CgdQdXNoTXNn');
const $core.Map<$core.String, $core.dynamic> CtrlApiServiceBase$json = const {
  '1': 'CtrlApi',
  '2': const [
    const {'1': 'Ping', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'QueryNoDatabaseParameters', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'QueryMeet', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'SetMeet', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'StartMeet', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'EndMeet', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'ContinueMeet', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'Login', '2': '.scc.LoginRequest', '3': '.scc.GResponse'},
    const {'1': 'DatabaseCheck', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'EndDatabaseCheck', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'ReportCheckInFailed', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'ImportRecord', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'QueryClient', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'QueryOnMeet', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'QueryMeetInfo', '2': '.scc.GRequest', '3': '.scc.GResponse'},
  ],
};

@$core.Deprecated('Use ctrlApiServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> CtrlApiServiceBase$messageJson = const {
  '.scc.GRequest': GRequest$json,
  '.scc.MeetReq': MeetReq$json,
  '.scc.CheckReq': CheckReq$json,
  '.scc.ImportReq': ImportReq$json,
  '.scc.ReportCheckFailedReq': ReportCheckFailedReq$json,
  '.scc.CustomReq': CustomReq$json,
  '.scc.CustomReq.CustomsEntry': CustomReq_CustomsEntry$json,
  '.scc.GResponse': GResponse$json,
  '.scc.LoginRequest': LoginRequest$json,
};

/// Descriptor for `CtrlApi`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List ctrlApiServiceDescriptor = $convert.base64Decode('CgdDdHJsQXBpEiUKBFBpbmcSDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNlEjoKGVF1ZXJ5Tm9EYXRhYmFzZVBhcmFtZXRlcnMSDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNlEioKCVF1ZXJ5TWVldBINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USKAoHU2V0TWVldBINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USKgoJU3RhcnRNZWV0Eg0uc2NjLkdSZXF1ZXN0Gg4uc2NjLkdSZXNwb25zZRIoCgdFbmRNZWV0Eg0uc2NjLkdSZXF1ZXN0Gg4uc2NjLkdSZXNwb25zZRItCgxDb250aW51ZU1lZXQSDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNlEioKBUxvZ2luEhEuc2NjLkxvZ2luUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USLgoNRGF0YWJhc2VDaGVjaxINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USMQoQRW5kRGF0YWJhc2VDaGVjaxINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USNAoTUmVwb3J0Q2hlY2tJbkZhaWxlZBINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USLQoMSW1wb3J0UmVjb3JkEg0uc2NjLkdSZXF1ZXN0Gg4uc2NjLkdSZXNwb25zZRIsCgtRdWVyeUNsaWVudBINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USLAoLUXVlcnlPbk1lZXQSDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNlEi4KDVF1ZXJ5TWVldEluZm8SDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNl');
const $core.Map<$core.String, $core.dynamic> SeatMapApiServiceBase$json = const {
  '1': 'SeatMapApi',
  '2': const [
    const {'1': 'QueryMapInfo', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'QueryMapList', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'Update', '2': '.scc.GRequest', '3': '.scc.GResponse'},
  ],
};

@$core.Deprecated('Use seatMapApiServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> SeatMapApiServiceBase$messageJson = const {
  '.scc.GRequest': GRequest$json,
  '.scc.MeetReq': MeetReq$json,
  '.scc.CheckReq': CheckReq$json,
  '.scc.ImportReq': ImportReq$json,
  '.scc.ReportCheckFailedReq': ReportCheckFailedReq$json,
  '.scc.CustomReq': CustomReq$json,
  '.scc.CustomReq.CustomsEntry': CustomReq_CustomsEntry$json,
  '.scc.GResponse': GResponse$json,
};

/// Descriptor for `SeatMapApi`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List seatMapApiServiceDescriptor = $convert.base64Decode('CgpTZWF0TWFwQXBpEi0KDFF1ZXJ5TWFwSW5mbxINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USLQoMUXVlcnlNYXBMaXN0Eg0uc2NjLkdSZXF1ZXN0Gg4uc2NjLkdSZXNwb25zZRInCgZVcGRhdGUSDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNl');
const $core.Map<$core.String, $core.dynamic> QueryApiServiceBase$json = const {
  '1': 'QueryApi',
  '2': const [
    const {'1': 'cancelCheckIn', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'queryPersonCheckInfo', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'querySearchInfo', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'querySignInInfo', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'replenishCheckIn', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'photoName', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'queryOutPerson', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'queryPersonCheckInLog', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'queryLeaveCheckinPerson', '2': '.scc.GRequest', '3': '.scc.GResponse'},
    const {'1': 'cancelLeaveCheckin', '2': '.scc.GRequest', '3': '.scc.GResponse'},
  ],
};

@$core.Deprecated('Use queryApiServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> QueryApiServiceBase$messageJson = const {
  '.scc.GRequest': GRequest$json,
  '.scc.MeetReq': MeetReq$json,
  '.scc.CheckReq': CheckReq$json,
  '.scc.ImportReq': ImportReq$json,
  '.scc.ReportCheckFailedReq': ReportCheckFailedReq$json,
  '.scc.CustomReq': CustomReq$json,
  '.scc.CustomReq.CustomsEntry': CustomReq_CustomsEntry$json,
  '.scc.GResponse': GResponse$json,
};

/// Descriptor for `QueryApi`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List queryApiServiceDescriptor = $convert.base64Decode('CghRdWVyeUFwaRIuCg1jYW5jZWxDaGVja0luEg0uc2NjLkdSZXF1ZXN0Gg4uc2NjLkdSZXNwb25zZRI1ChRxdWVyeVBlcnNvbkNoZWNrSW5mbxINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USMAoPcXVlcnlTZWFyY2hJbmZvEg0uc2NjLkdSZXF1ZXN0Gg4uc2NjLkdSZXNwb25zZRIwCg9xdWVyeVNpZ25JbkluZm8SDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNlEjEKEHJlcGxlbmlzaENoZWNrSW4SDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNlEioKCXBob3RvTmFtZRINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USLwoOcXVlcnlPdXRQZXJzb24SDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNlEjYKFXF1ZXJ5UGVyc29uQ2hlY2tJbkxvZxINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2USOAoXcXVlcnlMZWF2ZUNoZWNraW5QZXJzb24SDS5zY2MuR1JlcXVlc3QaDi5zY2MuR1Jlc3BvbnNlEjMKEmNhbmNlbExlYXZlQ2hlY2tpbhINLnNjYy5HUmVxdWVzdBoOLnNjYy5HUmVzcG9uc2U=');
const $core.Map<$core.String, $core.dynamic> CommonApiServiceBase$json = const {
  '1': 'CommonApi',
  '2': const [
    const {'1': 'Websocket', '2': '.scc.PushReq', '3': '.scc.PushMsg', '6': true},
  ],
};

@$core.Deprecated('Use commonApiServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> CommonApiServiceBase$messageJson = const {
  '.scc.PushReq': PushReq$json,
  '.scc.PushMsg': PushMsg$json,
};

/// Descriptor for `CommonApi`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List commonApiServiceDescriptor = $convert.base64Decode('CglDb21tb25BcGkSKQoJV2Vic29ja2V0Egwuc2NjLlB1c2hSZXEaDC5zY2MuUHVzaE1zZzAB');
