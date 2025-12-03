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
    const {'1': 'sreq', '3': 6, '4': 1, '5': 11, '6': '.scc.SendSloganReq', '9': 0, '10': 'sreq'},
  ],
  '8': const [
    const {'1': 'req'},
  ],
};

/// Descriptor for `GRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gRequestDescriptor = $convert.base64Decode('CghHUmVxdWVzdBIiCgRtcmVxGAEgASgLMgwuc2NjLk1lZXRSZXFIAFIEbXJlcRIjCgRjcmVxGAIgASgLMg0uc2NjLkNoZWNrUmVxSABSBGNyZXESJAoEaXJlcRgDIAEoCzIOLnNjYy5JbXBvcnRSZXFIAFIEaXJlcRIvCgRmcmVxGAQgASgLMhkuc2NjLlJlcG9ydENoZWNrRmFpbGVkUmVxSABSBGZyZXESKgoHY3VzdG9tcxgFIAEoCzIOLnNjYy5DdXN0b21SZXFIAFIHY3VzdG9tcxIoCgRzcmVxGAYgASgLMhIuc2NjLlNlbmRTbG9nYW5SZXFIAFIEc3JlcUIFCgNyZXE=');
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
@$core.Deprecated('Use queryReqDescriptor instead')
const QueryReq$json = const {
  '1': 'QueryReq',
  '2': const [
    const {'1': 'sreq', '3': 1, '4': 1, '5': 11, '6': '.scc.SearchReq', '9': 0, '10': 'sreq'},
    const {'1': 'ireq', '3': 2, '4': 1, '5': 11, '6': '.scc.SignInReq', '9': 0, '10': 'ireq'},
    const {'1': 'preq', '3': 3, '4': 1, '5': 11, '6': '.scc.PersonReq', '9': 0, '10': 'preq'},
    const {'1': 'oreq', '3': 4, '4': 1, '5': 11, '6': '.scc.QueryTypeReq', '9': 0, '10': 'oreq'},
  ],
  '8': const [
    const {'1': 'req'},
  ],
};

/// Descriptor for `QueryReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryReqDescriptor = $convert.base64Decode('CghRdWVyeVJlcRIkCgRzcmVxGAEgASgLMg4uc2NjLlNlYXJjaFJlcUgAUgRzcmVxEiQKBGlyZXEYAiABKAsyDi5zY2MuU2lnbkluUmVxSABSBGlyZXESJAoEcHJlcRgDIAEoCzIOLnNjYy5QZXJzb25SZXFIAFIEcHJlcRInCgRvcmVxGAQgASgLMhEuc2NjLlF1ZXJ5VHlwZVJlcUgAUgRvcmVxQgUKA3JlcQ==');
@$core.Deprecated('Use searchReqDescriptor instead')
const SearchReq$json = const {
  '1': 'SearchReq',
  '2': const [
    const {'1': 'meetID', '3': 1, '4': 1, '5': 9, '10': 'meetID'},
    const {'1': 'condition', '3': 2, '4': 1, '5': 9, '10': 'condition'},
    const {'1': 'kind', '3': 3, '4': 1, '5': 9, '10': 'kind'},
  ],
};

/// Descriptor for `SearchReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchReqDescriptor = $convert.base64Decode('CglTZWFyY2hSZXESFgoGbWVldElEGAEgASgJUgZtZWV0SUQSHAoJY29uZGl0aW9uGAIgASgJUgljb25kaXRpb24SEgoEa2luZBgDIAEoCVIEa2luZA==');
@$core.Deprecated('Use signInReqDescriptor instead')
const SignInReq$json = const {
  '1': 'SignInReq',
  '2': const [
    const {'1': 'meetID', '3': 1, '4': 1, '5': 9, '10': 'meetID'},
    const {'1': 'condition', '3': 2, '4': 1, '5': 9, '10': 'condition'},
    const {'1': 'kind', '3': 3, '4': 1, '5': 9, '10': 'kind'},
    const {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'size', '3': 5, '4': 1, '5': 9, '10': 'size'},
    const {'1': 'index', '3': 6, '4': 1, '5': 9, '10': 'index'},
  ],
};

/// Descriptor for `SignInReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signInReqDescriptor = $convert.base64Decode('CglTaWduSW5SZXESFgoGbWVldElEGAEgASgJUgZtZWV0SUQSHAoJY29uZGl0aW9uGAIgASgJUgljb25kaXRpb24SEgoEa2luZBgDIAEoCVIEa2luZBISCgR0eXBlGAQgASgJUgR0eXBlEhIKBHNpemUYBSABKAlSBHNpemUSFAoFaW5kZXgYBiABKAlSBWluZGV4');
@$core.Deprecated('Use personReqDescriptor instead')
const PersonReq$json = const {
  '1': 'PersonReq',
  '2': const [
    const {'1': 'meetID', '3': 1, '4': 1, '5': 9, '10': 'meetID'},
    const {'1': 'personId', '3': 2, '4': 1, '5': 9, '10': 'personId'},
    const {'1': 'leaveCheckin', '3': 3, '4': 1, '5': 9, '10': 'leaveCheckin'},
  ],
};

/// Descriptor for `PersonReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List personReqDescriptor = $convert.base64Decode('CglQZXJzb25SZXESFgoGbWVldElEGAEgASgJUgZtZWV0SUQSGgoIcGVyc29uSWQYAiABKAlSCHBlcnNvbklkEiIKDGxlYXZlQ2hlY2tpbhgDIAEoCVIMbGVhdmVDaGVja2lu');
@$core.Deprecated('Use queryTypeReqDescriptor instead')
const QueryTypeReq$json = const {
  '1': 'QueryTypeReq',
  '2': const [
    const {'1': 'meetID', '3': 1, '4': 1, '5': 9, '10': 'meetID'},
    const {'1': 'personId', '3': 2, '4': 1, '5': 9, '10': 'personId'},
    const {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'size', '3': 4, '4': 1, '5': 9, '10': 'size'},
    const {'1': 'index', '3': 5, '4': 1, '5': 9, '10': 'index'},
  ],
};

/// Descriptor for `QueryTypeReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryTypeReqDescriptor = $convert.base64Decode('CgxRdWVyeVR5cGVSZXESFgoGbWVldElEGAEgASgJUgZtZWV0SUQSGgoIcGVyc29uSWQYAiABKAlSCHBlcnNvbklkEhIKBHR5cGUYAyABKAlSBHR5cGUSEgoEc2l6ZRgEIAEoCVIEc2l6ZRIUCgVpbmRleBgFIAEoCVIFaW5kZXg=');
@$core.Deprecated('Use sendSloganReqDescriptor instead')
const SendSloganReq$json = const {
  '1': 'SendSloganReq',
  '2': const [
    const {'1': 'data', '3': 1, '4': 1, '5': 9, '10': 'data'},
  ],
};

/// Descriptor for `SendSloganReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendSloganReqDescriptor = $convert.base64Decode('Cg1TZW5kU2xvZ2FuUmVxEhIKBGRhdGEYASABKAlSBGRhdGE=');
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
  '2': const [
    const {'1': 'uid', '3': 1, '4': 1, '5': 9, '10': 'uid'},
    const {'1': 'timestamp', '3': 2, '4': 1, '5': 5, '10': 'timestamp'},
  ],
};

/// Descriptor for `PushReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushReqDescriptor = $convert.base64Decode('CgdQdXNoUmVxEhAKA3VpZBgBIAEoCVIDdWlkEhwKCXRpbWVzdGFtcBgCIAEoBVIJdGltZXN0YW1w');
@$core.Deprecated('Use pushMsgDescriptor instead')
const PushMsg$json = const {
  '1': 'PushMsg',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    const {'1': 'data', '3': 2, '4': 1, '5': 9, '10': 'data'},
    const {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `PushMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushMsgDescriptor = $convert.base64Decode('CgdQdXNoTXNnEhIKBHR5cGUYASABKAVSBHR5cGUSEgoEZGF0YRgCIAEoCVIEZGF0YRIcCgl0aW1lc3RhbXAYAyABKANSCXRpbWVzdGFtcA==');
@$core.Deprecated('Use metricReqDescriptor instead')
const MetricReq$json = const {
  '1': 'MetricReq',
  '2': const [
    const {'1': 'uid', '3': 1, '4': 1, '5': 9, '10': 'uid'},
    const {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `MetricReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metricReqDescriptor = $convert.base64Decode('CglNZXRyaWNSZXESEAoDdWlkGAEgASgJUgN1aWQSHAoJdGltZXN0YW1wGAIgASgDUgl0aW1lc3RhbXA=');
@$core.Deprecated('Use metricConfirmDescriptor instead')
const MetricConfirm$json = const {
  '1': 'MetricConfirm',
  '2': const [
    const {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'data', '3': 3, '4': 1, '5': 9, '10': 'data'},
  ],
};

/// Descriptor for `MetricConfirm`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metricConfirmDescriptor = $convert.base64Decode('Cg1NZXRyaWNDb25maXJtEhIKBGNvZGUYASABKAVSBGNvZGUSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZRISCgRkYXRhGAMgASgJUgRkYXRh');
@$core.Deprecated('Use metricMsgDescriptor instead')
const MetricMsg$json = const {
  '1': 'MetricMsg',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    const {'1': 'channel', '3': 2, '4': 1, '5': 9, '10': 'channel'},
    const {'1': 'data', '3': 3, '4': 1, '5': 9, '10': 'data'},
    const {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `MetricMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metricMsgDescriptor = $convert.base64Decode('CglNZXRyaWNNc2cSEgoEdHlwZRgBIAEoBVIEdHlwZRIYCgdjaGFubmVsGAIgASgJUgdjaGFubmVsEhIKBGRhdGEYAyABKAlSBGRhdGESHAoJdGltZXN0YW1wGAQgASgDUgl0aW1lc3RhbXA=');
