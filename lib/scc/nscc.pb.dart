///
//  Generated code. Do not modify.
//  source: nscc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NGReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'NGReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'nscc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'meetID', protoName: 'meetID')
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'step', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  NGReq._() : super();
  factory NGReq({
    $core.String? meetID,
    $core.int? step,
  }) {
    final _result = create();
    if (meetID != null) {
      _result.meetID = meetID;
    }
    if (step != null) {
      _result.step = step;
    }
    return _result;
  }
  factory NGReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NGReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NGReq clone() => NGReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NGReq copyWith(void Function(NGReq) updates) => super.copyWith((message) => updates(message as NGReq)) as NGReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NGReq create() => NGReq._();
  NGReq createEmptyInstance() => create();
  static $pb.PbList<NGReq> createRepeated() => $pb.PbList<NGReq>();
  @$core.pragma('dart2js:noInline')
  static NGReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NGReq>(create);
  static NGReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get meetID => $_getSZ(0);
  @$pb.TagNumber(1)
  set meetID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMeetID() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeetID() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get step => $_getIZ(1);
  @$pb.TagNumber(2)
  set step($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStep() => $_has(1);
  @$pb.TagNumber(2)
  void clearStep() => clearField(2);
}

class NGResp extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'NGResp', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'nscc'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'msg')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'remark')
    ..hasRequiredFields = false
  ;

  NGResp._() : super();
  factory NGResp({
    $core.int? code,
    $core.String? msg,
    $core.String? data,
    $core.String? remark,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    if (msg != null) {
      _result.msg = msg;
    }
    if (data != null) {
      _result.data = data;
    }
    if (remark != null) {
      _result.remark = remark;
    }
    return _result;
  }
  factory NGResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NGResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NGResp clone() => NGResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NGResp copyWith(void Function(NGResp) updates) => super.copyWith((message) => updates(message as NGResp)) as NGResp; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NGResp create() => NGResp._();
  NGResp createEmptyInstance() => create();
  static $pb.PbList<NGResp> createRepeated() => $pb.PbList<NGResp>();
  @$core.pragma('dart2js:noInline')
  static NGResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NGResp>(create);
  static NGResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get data => $_getSZ(2);
  @$pb.TagNumber(3)
  set data($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get remark => $_getSZ(3);
  @$pb.TagNumber(4)
  set remark($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRemark() => $_has(3);
  @$pb.TagNumber(4)
  void clearRemark() => clearField(4);
}

