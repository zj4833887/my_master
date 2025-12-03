///
//  Generated code. Do not modify.
//  source: nscc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use nGReqDescriptor instead')
const NGReq$json = const {
  '1': 'NGReq',
  '2': const [
    const {'1': 'meetID', '3': 1, '4': 1, '5': 9, '10': 'meetID'},
    const {'1': 'step', '3': 2, '4': 1, '5': 5, '10': 'step'},
  ],
};

/// Descriptor for `NGReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nGReqDescriptor = $convert.base64Decode('CgVOR1JlcRIWCgZtZWV0SUQYASABKAlSBm1lZXRJRBISCgRzdGVwGAIgASgFUgRzdGVw');
@$core.Deprecated('Use nGRespDescriptor instead')
const NGResp$json = const {
  '1': 'NGResp',
  '2': const [
    const {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    const {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    const {'1': 'data', '3': 3, '4': 1, '5': 9, '10': 'data'},
    const {'1': 'remark', '3': 4, '4': 1, '5': 9, '10': 'remark'},
  ],
};

/// Descriptor for `NGResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nGRespDescriptor = $convert.base64Decode('CgZOR1Jlc3ASEgoEY29kZRgBIAEoBVIEY29kZRIQCgNtc2cYAiABKAlSA21zZxISCgRkYXRhGAMgASgJUgRkYXRhEhYKBnJlbWFyaxgEIAEoCVIGcmVtYXJr');
