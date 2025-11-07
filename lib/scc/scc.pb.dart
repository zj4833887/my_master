///
//  Generated code. Do not modify.
//  source: scc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class LoginRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'LoginRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'password')
    ..hasRequiredFields = false
  ;

  LoginRequest._() : super();
  factory LoginRequest({
    $core.String? name,
    $core.String? password,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (password != null) {
      _result.password = password;
    }
    return _result;
  }
  factory LoginRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoginRequest clone() => LoginRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoginRequest copyWith(void Function(LoginRequest) updates) => super.copyWith((message) => updates(message as LoginRequest)) as LoginRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static LoginRequest create() => LoginRequest._();
  LoginRequest createEmptyInstance() => create();
  static $pb.PbList<LoginRequest> createRepeated() => $pb.PbList<LoginRequest>();
  @$core.pragma('dart2js:noInline')
  static LoginRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginRequest>(create);
  static LoginRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => clearField(2);
}

enum GRequest_Req {
  mreq, 
  creq, 
  ireq, 
  freq, 
  customs, 
  notSet
}

class GRequest extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, GRequest_Req> _GRequest_ReqByTag = {
    1 : GRequest_Req.mreq,
    2 : GRequest_Req.creq,
    3 : GRequest_Req.ireq,
    4 : GRequest_Req.freq,
    5 : GRequest_Req.customs,
    0 : GRequest_Req.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5])
    ..aOM<MeetReq>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mreq', subBuilder: MeetReq.create)
    ..aOM<CheckReq>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'creq', subBuilder: CheckReq.create)
    ..aOM<ImportReq>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ireq', subBuilder: ImportReq.create)
    ..aOM<ReportCheckFailedReq>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'freq', subBuilder: ReportCheckFailedReq.create)
    ..aOM<CustomReq>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'customs', subBuilder: CustomReq.create)
    ..hasRequiredFields = false
  ;

  GRequest._() : super();
  factory GRequest({
    MeetReq? mreq,
    CheckReq? creq,
    ImportReq? ireq,
    ReportCheckFailedReq? freq,
    CustomReq? customs,
  }) {
    final _result = create();
    if (mreq != null) {
      _result.mreq = mreq;
    }
    if (creq != null) {
      _result.creq = creq;
    }
    if (ireq != null) {
      _result.ireq = ireq;
    }
    if (freq != null) {
      _result.freq = freq;
    }
    if (customs != null) {
      _result.customs = customs;
    }
    return _result;
  }
  factory GRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GRequest clone() => GRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GRequest copyWith(void Function(GRequest) updates) => super.copyWith((message) => updates(message as GRequest)) as GRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GRequest create() => GRequest._();
  GRequest createEmptyInstance() => create();
  static $pb.PbList<GRequest> createRepeated() => $pb.PbList<GRequest>();
  @$core.pragma('dart2js:noInline')
  static GRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GRequest>(create);
  static GRequest? _defaultInstance;

  GRequest_Req whichReq() => _GRequest_ReqByTag[$_whichOneof(0)]!;
  void clearReq() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  MeetReq get mreq => $_getN(0);
  @$pb.TagNumber(1)
  set mreq(MeetReq v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMreq() => $_has(0);
  @$pb.TagNumber(1)
  void clearMreq() => clearField(1);
  @$pb.TagNumber(1)
  MeetReq ensureMreq() => $_ensure(0);

  @$pb.TagNumber(2)
  CheckReq get creq => $_getN(1);
  @$pb.TagNumber(2)
  set creq(CheckReq v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCreq() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreq() => clearField(2);
  @$pb.TagNumber(2)
  CheckReq ensureCreq() => $_ensure(1);

  @$pb.TagNumber(3)
  ImportReq get ireq => $_getN(2);
  @$pb.TagNumber(3)
  set ireq(ImportReq v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasIreq() => $_has(2);
  @$pb.TagNumber(3)
  void clearIreq() => clearField(3);
  @$pb.TagNumber(3)
  ImportReq ensureIreq() => $_ensure(2);

  @$pb.TagNumber(4)
  ReportCheckFailedReq get freq => $_getN(3);
  @$pb.TagNumber(4)
  set freq(ReportCheckFailedReq v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFreq() => $_has(3);
  @$pb.TagNumber(4)
  void clearFreq() => clearField(4);
  @$pb.TagNumber(4)
  ReportCheckFailedReq ensureFreq() => $_ensure(3);

  @$pb.TagNumber(5)
  CustomReq get customs => $_getN(4);
  @$pb.TagNumber(5)
  set customs(CustomReq v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCustoms() => $_has(4);
  @$pb.TagNumber(5)
  void clearCustoms() => clearField(5);
  @$pb.TagNumber(5)
  CustomReq ensureCustoms() => $_ensure(4);
}

class CustomReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'CustomReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'customs', entryClassName: 'CustomReq.CustomsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('scc'))
    ..hasRequiredFields = false
  ;

  CustomReq._() : super();
  factory CustomReq({
    $core.Map<$core.String, $core.String>? customs,
  }) {
    final _result = create();
    if (customs != null) {
      _result.customs.addAll(customs);
    }
    return _result;
  }
  factory CustomReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CustomReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CustomReq clone() => CustomReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CustomReq copyWith(void Function(CustomReq) updates) => super.copyWith((message) => updates(message as CustomReq)) as CustomReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CustomReq create() => CustomReq._();
  CustomReq createEmptyInstance() => create();
  static $pb.PbList<CustomReq> createRepeated() => $pb.PbList<CustomReq>();
  @$core.pragma('dart2js:noInline')
  static CustomReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CustomReq>(create);
  static CustomReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.String> get customs => $_getMap(0);
}

class MeetReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MeetReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'MeetID', protoName: 'MeetID')
    ..hasRequiredFields = false
  ;

  MeetReq._() : super();
  factory MeetReq({
    $core.String? meetID,
  }) {
    final _result = create();
    if (meetID != null) {
      _result.meetID = meetID;
    }
    return _result;
  }
  factory MeetReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MeetReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MeetReq clone() => MeetReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MeetReq copyWith(void Function(MeetReq) updates) => super.copyWith((message) => updates(message as MeetReq)) as MeetReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MeetReq create() => MeetReq._();
  MeetReq createEmptyInstance() => create();
  static $pb.PbList<MeetReq> createRepeated() => $pb.PbList<MeetReq>();
  @$core.pragma('dart2js:noInline')
  static MeetReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MeetReq>(create);
  static MeetReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get meetID => $_getSZ(0);
  @$pb.TagNumber(1)
  set meetID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMeetID() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeetID() => clearField(1);
}

class CheckReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'CheckReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'meetID', protoName: 'meetID')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'stations')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'tables')
    ..hasRequiredFields = false
  ;

  CheckReq._() : super();
  factory CheckReq({
    $core.String? meetID,
    $core.String? stations,
    $core.String? tables,
  }) {
    final _result = create();
    if (meetID != null) {
      _result.meetID = meetID;
    }
    if (stations != null) {
      _result.stations = stations;
    }
    if (tables != null) {
      _result.tables = tables;
    }
    return _result;
  }
  factory CheckReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CheckReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CheckReq clone() => CheckReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CheckReq copyWith(void Function(CheckReq) updates) => super.copyWith((message) => updates(message as CheckReq)) as CheckReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CheckReq create() => CheckReq._();
  CheckReq createEmptyInstance() => create();
  static $pb.PbList<CheckReq> createRepeated() => $pb.PbList<CheckReq>();
  @$core.pragma('dart2js:noInline')
  static CheckReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CheckReq>(create);
  static CheckReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get meetID => $_getSZ(0);
  @$pb.TagNumber(1)
  set meetID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMeetID() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeetID() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get stations => $_getSZ(1);
  @$pb.TagNumber(2)
  set stations($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStations() => $_has(1);
  @$pb.TagNumber(2)
  void clearStations() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get tables => $_getSZ(2);
  @$pb.TagNumber(3)
  set tables($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTables() => $_has(2);
  @$pb.TagNumber(3)
  void clearTables() => clearField(3);
}

class ReportCheckFailedReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ReportCheckFailedReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'meetID', protoName: 'meetID')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'stations')
    ..hasRequiredFields = false
  ;

  ReportCheckFailedReq._() : super();
  factory ReportCheckFailedReq({
    $core.String? meetID,
    $core.String? stations,
  }) {
    final _result = create();
    if (meetID != null) {
      _result.meetID = meetID;
    }
    if (stations != null) {
      _result.stations = stations;
    }
    return _result;
  }
  factory ReportCheckFailedReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReportCheckFailedReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReportCheckFailedReq clone() => ReportCheckFailedReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReportCheckFailedReq copyWith(void Function(ReportCheckFailedReq) updates) => super.copyWith((message) => updates(message as ReportCheckFailedReq)) as ReportCheckFailedReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ReportCheckFailedReq create() => ReportCheckFailedReq._();
  ReportCheckFailedReq createEmptyInstance() => create();
  static $pb.PbList<ReportCheckFailedReq> createRepeated() => $pb.PbList<ReportCheckFailedReq>();
  @$core.pragma('dart2js:noInline')
  static ReportCheckFailedReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReportCheckFailedReq>(create);
  static ReportCheckFailedReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get meetID => $_getSZ(0);
  @$pb.TagNumber(1)
  set meetID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMeetID() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeetID() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get stations => $_getSZ(1);
  @$pb.TagNumber(2)
  set stations($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStations() => $_has(1);
  @$pb.TagNumber(2)
  void clearStations() => clearField(2);
}

class ImportReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ImportReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'file', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  ImportReq._() : super();
  factory ImportReq({
    $core.List<$core.int>? file,
  }) {
    final _result = create();
    if (file != null) {
      _result.file = file;
    }
    return _result;
  }
  factory ImportReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportReq clone() => ImportReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportReq copyWith(void Function(ImportReq) updates) => super.copyWith((message) => updates(message as ImportReq)) as ImportReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ImportReq create() => ImportReq._();
  ImportReq createEmptyInstance() => create();
  static $pb.PbList<ImportReq> createRepeated() => $pb.PbList<ImportReq>();
  @$core.pragma('dart2js:noInline')
  static ImportReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportReq>(create);
  static ImportReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get file => $_getN(0);
  @$pb.TagNumber(1)
  set file($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => clearField(1);
}

class GResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'msg')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'remark')
    ..hasRequiredFields = false
  ;

  GResponse._() : super();
  factory GResponse({
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
  factory GResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GResponse clone() => GResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GResponse copyWith(void Function(GResponse) updates) => super.copyWith((message) => updates(message as GResponse)) as GResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GResponse create() => GResponse._();
  GResponse createEmptyInstance() => create();
  static $pb.PbList<GResponse> createRepeated() => $pb.PbList<GResponse>();
  @$core.pragma('dart2js:noInline')
  static GResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GResponse>(create);
  static GResponse? _defaultInstance;

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

class PushReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PushReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  PushReq._() : super();
  factory PushReq() => create();
  factory PushReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PushReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PushReq clone() => PushReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PushReq copyWith(void Function(PushReq) updates) => super.copyWith((message) => updates(message as PushReq)) as PushReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PushReq create() => PushReq._();
  PushReq createEmptyInstance() => create();
  static $pb.PbList<PushReq> createRepeated() => $pb.PbList<PushReq>();
  @$core.pragma('dart2js:noInline')
  static PushReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushReq>(create);
  static PushReq? _defaultInstance;
}

class PushMsg extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PushMsg', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  PushMsg._() : super();
  factory PushMsg() => create();
  factory PushMsg.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PushMsg.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PushMsg clone() => PushMsg()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PushMsg copyWith(void Function(PushMsg) updates) => super.copyWith((message) => updates(message as PushMsg)) as PushMsg; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PushMsg create() => PushMsg._();
  PushMsg createEmptyInstance() => create();
  static $pb.PbList<PushMsg> createRepeated() => $pb.PbList<PushMsg>();
  @$core.pragma('dart2js:noInline')
  static PushMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushMsg>(create);
  static PushMsg? _defaultInstance;
}

class CtrlApiApi {
  $pb.RpcClient _client;
  CtrlApiApi(this._client);

  $async.Future<GResponse> ping($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'Ping', request, emptyResponse);
  }
  $async.Future<GResponse> queryNoDatabaseParameters($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'QueryNoDatabaseParameters', request, emptyResponse);
  }
  $async.Future<GResponse> queryMeet($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'QueryMeet', request, emptyResponse);
  }
  $async.Future<GResponse> setMeet($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'SetMeet', request, emptyResponse);
  }
  $async.Future<GResponse> startMeet($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'StartMeet', request, emptyResponse);
  }
  $async.Future<GResponse> endMeet($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'EndMeet', request, emptyResponse);
  }
  $async.Future<GResponse> continueMeet($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'ContinueMeet', request, emptyResponse);
  }
  $async.Future<GResponse> login($pb.ClientContext? ctx, LoginRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'Login', request, emptyResponse);
  }
  $async.Future<GResponse> databaseCheck($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'DatabaseCheck', request, emptyResponse);
  }
  $async.Future<GResponse> endDatabaseCheck($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'EndDatabaseCheck', request, emptyResponse);
  }
  $async.Future<GResponse> reportCheckInFailed($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'ReportCheckInFailed', request, emptyResponse);
  }
  $async.Future<GResponse> importRecord($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'ImportRecord', request, emptyResponse);
  }
  $async.Future<GResponse> queryClient($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'QueryClient', request, emptyResponse);
  }
  $async.Future<GResponse> queryOnMeet($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'QueryOnMeet', request, emptyResponse);
  }
  $async.Future<GResponse> queryMeetInfo($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'CtrlApi', 'QueryMeetInfo', request, emptyResponse);
  }
}

class SeatMapApiApi {
  $pb.RpcClient _client;
  SeatMapApiApi(this._client);

  $async.Future<GResponse> queryMapInfo($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'SeatMapApi', 'QueryMapInfo', request, emptyResponse);
  }
  $async.Future<GResponse> queryMapList($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'SeatMapApi', 'QueryMapList', request, emptyResponse);
  }
  $async.Future<GResponse> update($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'SeatMapApi', 'Update', request, emptyResponse);
  }
}

class QueryApiApi {
  $pb.RpcClient _client;
  QueryApiApi(this._client);

  $async.Future<GResponse> cancelCheckIn($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'cancelCheckIn', request, emptyResponse);
  }
  $async.Future<GResponse> queryPersonCheckInfo($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'queryPersonCheckInfo', request, emptyResponse);
  }
  $async.Future<GResponse> querySearchInfo($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'querySearchInfo', request, emptyResponse);
  }
  $async.Future<GResponse> querySignInInfo($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'querySignInInfo', request, emptyResponse);
  }
  $async.Future<GResponse> replenishCheckIn($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'replenishCheckIn', request, emptyResponse);
  }
  $async.Future<GResponse> photoName($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'photoName', request, emptyResponse);
  }
  $async.Future<GResponse> queryOutPerson($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'queryOutPerson', request, emptyResponse);
  }
  $async.Future<GResponse> queryPersonCheckInLog($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'queryPersonCheckInLog', request, emptyResponse);
  }
  $async.Future<GResponse> queryLeaveCheckinPerson($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'queryLeaveCheckinPerson', request, emptyResponse);
  }
  $async.Future<GResponse> cancelLeaveCheckin($pb.ClientContext? ctx, GRequest request) {
    var emptyResponse = GResponse();
    return _client.invoke<GResponse>(ctx, 'QueryApi', 'cancelLeaveCheckin', request, emptyResponse);
  }
}

class CommonApiApi {
  $pb.RpcClient _client;
  CommonApiApi(this._client);

  $async.Future<PushMsg> websocket($pb.ClientContext? ctx, PushReq request) {
    var emptyResponse = PushMsg();
    return _client.invoke<PushMsg>(ctx, 'CommonApi', 'Websocket', request, emptyResponse);
  }
}

