///
//  Generated code. Do not modify.
//  source: scc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
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
  sreq, 
  notSet
}

class GRequest extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, GRequest_Req> _GRequest_ReqByTag = {
    1 : GRequest_Req.mreq,
    2 : GRequest_Req.creq,
    3 : GRequest_Req.ireq,
    4 : GRequest_Req.freq,
    5 : GRequest_Req.customs,
    6 : GRequest_Req.sreq,
    0 : GRequest_Req.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6])
    ..aOM<MeetReq>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mreq', subBuilder: MeetReq.create)
    ..aOM<CheckReq>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'creq', subBuilder: CheckReq.create)
    ..aOM<ImportReq>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ireq', subBuilder: ImportReq.create)
    ..aOM<ReportCheckFailedReq>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'freq', subBuilder: ReportCheckFailedReq.create)
    ..aOM<CustomReq>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'customs', subBuilder: CustomReq.create)
    ..aOM<SendSloganReq>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sreq', subBuilder: SendSloganReq.create)
    ..hasRequiredFields = false
  ;

  GRequest._() : super();
  factory GRequest({
    MeetReq? mreq,
    CheckReq? creq,
    ImportReq? ireq,
    ReportCheckFailedReq? freq,
    CustomReq? customs,
    SendSloganReq? sreq,
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
    if (sreq != null) {
      _result.sreq = sreq;
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

  @$pb.TagNumber(6)
  SendSloganReq get sreq => $_getN(5);
  @$pb.TagNumber(6)
  set sreq(SendSloganReq v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasSreq() => $_has(5);
  @$pb.TagNumber(6)
  void clearSreq() => clearField(6);
  @$pb.TagNumber(6)
  SendSloganReq ensureSreq() => $_ensure(5);
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

enum QueryReq_Req {
  sreq, 
  ireq, 
  preq, 
  oreq, 
  notSet
}

class QueryReq extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, QueryReq_Req> _QueryReq_ReqByTag = {
    1 : QueryReq_Req.sreq,
    2 : QueryReq_Req.ireq,
    3 : QueryReq_Req.preq,
    4 : QueryReq_Req.oreq,
    0 : QueryReq_Req.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4])
    ..aOM<SearchReq>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sreq', subBuilder: SearchReq.create)
    ..aOM<SignInReq>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ireq', subBuilder: SignInReq.create)
    ..aOM<PersonReq>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'preq', subBuilder: PersonReq.create)
    ..aOM<QueryTypeReq>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'oreq', subBuilder: QueryTypeReq.create)
    ..hasRequiredFields = false
  ;

  QueryReq._() : super();
  factory QueryReq({
    SearchReq? sreq,
    SignInReq? ireq,
    PersonReq? preq,
    QueryTypeReq? oreq,
  }) {
    final _result = create();
    if (sreq != null) {
      _result.sreq = sreq;
    }
    if (ireq != null) {
      _result.ireq = ireq;
    }
    if (preq != null) {
      _result.preq = preq;
    }
    if (oreq != null) {
      _result.oreq = oreq;
    }
    return _result;
  }
  factory QueryReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryReq clone() => QueryReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryReq copyWith(void Function(QueryReq) updates) => super.copyWith((message) => updates(message as QueryReq)) as QueryReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryReq create() => QueryReq._();
  QueryReq createEmptyInstance() => create();
  static $pb.PbList<QueryReq> createRepeated() => $pb.PbList<QueryReq>();
  @$core.pragma('dart2js:noInline')
  static QueryReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryReq>(create);
  static QueryReq? _defaultInstance;

  QueryReq_Req whichReq() => _QueryReq_ReqByTag[$_whichOneof(0)]!;
  void clearReq() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SearchReq get sreq => $_getN(0);
  @$pb.TagNumber(1)
  set sreq(SearchReq v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSreq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSreq() => clearField(1);
  @$pb.TagNumber(1)
  SearchReq ensureSreq() => $_ensure(0);

  @$pb.TagNumber(2)
  SignInReq get ireq => $_getN(1);
  @$pb.TagNumber(2)
  set ireq(SignInReq v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasIreq() => $_has(1);
  @$pb.TagNumber(2)
  void clearIreq() => clearField(2);
  @$pb.TagNumber(2)
  SignInReq ensureIreq() => $_ensure(1);

  @$pb.TagNumber(3)
  PersonReq get preq => $_getN(2);
  @$pb.TagNumber(3)
  set preq(PersonReq v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPreq() => $_has(2);
  @$pb.TagNumber(3)
  void clearPreq() => clearField(3);
  @$pb.TagNumber(3)
  PersonReq ensurePreq() => $_ensure(2);

  @$pb.TagNumber(4)
  QueryTypeReq get oreq => $_getN(3);
  @$pb.TagNumber(4)
  set oreq(QueryTypeReq v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasOreq() => $_has(3);
  @$pb.TagNumber(4)
  void clearOreq() => clearField(4);
  @$pb.TagNumber(4)
  QueryTypeReq ensureOreq() => $_ensure(3);
}

class SearchReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SearchReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'meetID', protoName: 'meetID')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'condition')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'kind')
    ..hasRequiredFields = false
  ;

  SearchReq._() : super();
  factory SearchReq({
    $core.String? meetID,
    $core.String? condition,
    $core.String? kind,
  }) {
    final _result = create();
    if (meetID != null) {
      _result.meetID = meetID;
    }
    if (condition != null) {
      _result.condition = condition;
    }
    if (kind != null) {
      _result.kind = kind;
    }
    return _result;
  }
  factory SearchReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchReq clone() => SearchReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchReq copyWith(void Function(SearchReq) updates) => super.copyWith((message) => updates(message as SearchReq)) as SearchReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SearchReq create() => SearchReq._();
  SearchReq createEmptyInstance() => create();
  static $pb.PbList<SearchReq> createRepeated() => $pb.PbList<SearchReq>();
  @$core.pragma('dart2js:noInline')
  static SearchReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchReq>(create);
  static SearchReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get meetID => $_getSZ(0);
  @$pb.TagNumber(1)
  set meetID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMeetID() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeetID() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get condition => $_getSZ(1);
  @$pb.TagNumber(2)
  set condition($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCondition() => $_has(1);
  @$pb.TagNumber(2)
  void clearCondition() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => clearField(3);
}

class SignInReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SignInReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'meetID', protoName: 'meetID')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'condition')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'kind')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'size')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'index')
    ..hasRequiredFields = false
  ;

  SignInReq._() : super();
  factory SignInReq({
    $core.String? meetID,
    $core.String? condition,
    $core.String? kind,
    $core.String? type,
    $core.String? size,
    $core.String? index,
  }) {
    final _result = create();
    if (meetID != null) {
      _result.meetID = meetID;
    }
    if (condition != null) {
      _result.condition = condition;
    }
    if (kind != null) {
      _result.kind = kind;
    }
    if (type != null) {
      _result.type = type;
    }
    if (size != null) {
      _result.size = size;
    }
    if (index != null) {
      _result.index = index;
    }
    return _result;
  }
  factory SignInReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignInReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignInReq clone() => SignInReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignInReq copyWith(void Function(SignInReq) updates) => super.copyWith((message) => updates(message as SignInReq)) as SignInReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SignInReq create() => SignInReq._();
  SignInReq createEmptyInstance() => create();
  static $pb.PbList<SignInReq> createRepeated() => $pb.PbList<SignInReq>();
  @$core.pragma('dart2js:noInline')
  static SignInReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignInReq>(create);
  static SignInReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get meetID => $_getSZ(0);
  @$pb.TagNumber(1)
  set meetID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMeetID() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeetID() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get condition => $_getSZ(1);
  @$pb.TagNumber(2)
  set condition($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCondition() => $_has(1);
  @$pb.TagNumber(2)
  void clearCondition() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get type => $_getSZ(3);
  @$pb.TagNumber(4)
  set type($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get size => $_getSZ(4);
  @$pb.TagNumber(5)
  set size($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearSize() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get index => $_getSZ(5);
  @$pb.TagNumber(6)
  set index($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIndex() => $_has(5);
  @$pb.TagNumber(6)
  void clearIndex() => clearField(6);
}

class PersonReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PersonReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'meetID', protoName: 'meetID')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'personId', protoName: 'personId')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'leaveCheckin', protoName: 'leaveCheckin')
    ..hasRequiredFields = false
  ;

  PersonReq._() : super();
  factory PersonReq({
    $core.String? meetID,
    $core.String? personId,
    $core.String? leaveCheckin,
  }) {
    final _result = create();
    if (meetID != null) {
      _result.meetID = meetID;
    }
    if (personId != null) {
      _result.personId = personId;
    }
    if (leaveCheckin != null) {
      _result.leaveCheckin = leaveCheckin;
    }
    return _result;
  }
  factory PersonReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PersonReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PersonReq clone() => PersonReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PersonReq copyWith(void Function(PersonReq) updates) => super.copyWith((message) => updates(message as PersonReq)) as PersonReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PersonReq create() => PersonReq._();
  PersonReq createEmptyInstance() => create();
  static $pb.PbList<PersonReq> createRepeated() => $pb.PbList<PersonReq>();
  @$core.pragma('dart2js:noInline')
  static PersonReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PersonReq>(create);
  static PersonReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get meetID => $_getSZ(0);
  @$pb.TagNumber(1)
  set meetID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMeetID() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeetID() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get personId => $_getSZ(1);
  @$pb.TagNumber(2)
  set personId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPersonId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPersonId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get leaveCheckin => $_getSZ(2);
  @$pb.TagNumber(3)
  set leaveCheckin($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLeaveCheckin() => $_has(2);
  @$pb.TagNumber(3)
  void clearLeaveCheckin() => clearField(3);
}

class QueryTypeReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryTypeReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'meetID', protoName: 'meetID')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'personId', protoName: 'personId')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'size')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'index')
    ..hasRequiredFields = false
  ;

  QueryTypeReq._() : super();
  factory QueryTypeReq({
    $core.String? meetID,
    $core.String? personId,
    $core.String? type,
    $core.String? size,
    $core.String? index,
  }) {
    final _result = create();
    if (meetID != null) {
      _result.meetID = meetID;
    }
    if (personId != null) {
      _result.personId = personId;
    }
    if (type != null) {
      _result.type = type;
    }
    if (size != null) {
      _result.size = size;
    }
    if (index != null) {
      _result.index = index;
    }
    return _result;
  }
  factory QueryTypeReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryTypeReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryTypeReq clone() => QueryTypeReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryTypeReq copyWith(void Function(QueryTypeReq) updates) => super.copyWith((message) => updates(message as QueryTypeReq)) as QueryTypeReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryTypeReq create() => QueryTypeReq._();
  QueryTypeReq createEmptyInstance() => create();
  static $pb.PbList<QueryTypeReq> createRepeated() => $pb.PbList<QueryTypeReq>();
  @$core.pragma('dart2js:noInline')
  static QueryTypeReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryTypeReq>(create);
  static QueryTypeReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get meetID => $_getSZ(0);
  @$pb.TagNumber(1)
  set meetID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMeetID() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeetID() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get personId => $_getSZ(1);
  @$pb.TagNumber(2)
  set personId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPersonId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPersonId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get size => $_getSZ(3);
  @$pb.TagNumber(4)
  set size($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearSize() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get index => $_getSZ(4);
  @$pb.TagNumber(5)
  set index($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearIndex() => clearField(5);
}

class SendSloganReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SendSloganReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..hasRequiredFields = false
  ;

  SendSloganReq._() : super();
  factory SendSloganReq({
    $core.String? data,
  }) {
    final _result = create();
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory SendSloganReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendSloganReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendSloganReq clone() => SendSloganReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendSloganReq copyWith(void Function(SendSloganReq) updates) => super.copyWith((message) => updates(message as SendSloganReq)) as SendSloganReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SendSloganReq create() => SendSloganReq._();
  SendSloganReq createEmptyInstance() => create();
  static $pb.PbList<SendSloganReq> createRepeated() => $pb.PbList<SendSloganReq>();
  @$core.pragma('dart2js:noInline')
  static SendSloganReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendSloganReq>(create);
  static SendSloganReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get data => $_getSZ(0);
  @$pb.TagNumber(1)
  set data($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
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
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'uid')
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timestamp', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  PushReq._() : super();
  factory PushReq({
    $core.String? uid,
    $core.int? timestamp,
  }) {
    final _result = create();
    if (uid != null) {
      _result.uid = uid;
    }
    if (timestamp != null) {
      _result.timestamp = timestamp;
    }
    return _result;
  }
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

  @$pb.TagNumber(1)
  $core.String get uid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get timestamp => $_getIZ(1);
  @$pb.TagNumber(2)
  set timestamp($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);
}

class PushMsg extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PushMsg', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type', $pb.PbFieldType.O3)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  PushMsg._() : super();
  factory PushMsg({
    $core.int? type,
    $core.String? data,
    $fixnum.Int64? timestamp,
  }) {
    final _result = create();
    if (type != null) {
      _result.type = type;
    }
    if (data != null) {
      _result.data = data;
    }
    if (timestamp != null) {
      _result.timestamp = timestamp;
    }
    return _result;
  }
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

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get data => $_getSZ(1);
  @$pb.TagNumber(2)
  set data($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => clearField(3);
}

class MetricReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MetricReq', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'uid')
    ..aInt64(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  MetricReq._() : super();
  factory MetricReq({
    $core.String? uid,
    $fixnum.Int64? timestamp,
  }) {
    final _result = create();
    if (uid != null) {
      _result.uid = uid;
    }
    if (timestamp != null) {
      _result.timestamp = timestamp;
    }
    return _result;
  }
  factory MetricReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MetricReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MetricReq clone() => MetricReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MetricReq copyWith(void Function(MetricReq) updates) => super.copyWith((message) => updates(message as MetricReq)) as MetricReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MetricReq create() => MetricReq._();
  MetricReq createEmptyInstance() => create();
  static $pb.PbList<MetricReq> createRepeated() => $pb.PbList<MetricReq>();
  @$core.pragma('dart2js:noInline')
  static MetricReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MetricReq>(create);
  static MetricReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);
}

class MetricConfirm extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MetricConfirm', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'code', $pb.PbFieldType.O3)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..hasRequiredFields = false
  ;

  MetricConfirm._() : super();
  factory MetricConfirm({
    $core.int? code,
    $core.String? message,
    $core.String? data,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    if (message != null) {
      _result.message = message;
    }
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory MetricConfirm.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MetricConfirm.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MetricConfirm clone() => MetricConfirm()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MetricConfirm copyWith(void Function(MetricConfirm) updates) => super.copyWith((message) => updates(message as MetricConfirm)) as MetricConfirm; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MetricConfirm create() => MetricConfirm._();
  MetricConfirm createEmptyInstance() => create();
  static $pb.PbList<MetricConfirm> createRepeated() => $pb.PbList<MetricConfirm>();
  @$core.pragma('dart2js:noInline')
  static MetricConfirm getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MetricConfirm>(create);
  static MetricConfirm? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get data => $_getSZ(2);
  @$pb.TagNumber(3)
  set data($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);
}

class MetricMsg extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MetricMsg', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'scc'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type', $pb.PbFieldType.O3)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'channel')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..aInt64(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  MetricMsg._() : super();
  factory MetricMsg({
    $core.int? type,
    $core.String? channel,
    $core.String? data,
    $fixnum.Int64? timestamp,
  }) {
    final _result = create();
    if (type != null) {
      _result.type = type;
    }
    if (channel != null) {
      _result.channel = channel;
    }
    if (data != null) {
      _result.data = data;
    }
    if (timestamp != null) {
      _result.timestamp = timestamp;
    }
    return _result;
  }
  factory MetricMsg.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MetricMsg.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MetricMsg clone() => MetricMsg()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MetricMsg copyWith(void Function(MetricMsg) updates) => super.copyWith((message) => updates(message as MetricMsg)) as MetricMsg; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MetricMsg create() => MetricMsg._();
  MetricMsg createEmptyInstance() => create();
  static $pb.PbList<MetricMsg> createRepeated() => $pb.PbList<MetricMsg>();
  @$core.pragma('dart2js:noInline')
  static MetricMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MetricMsg>(create);
  static MetricMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get channel => $_getSZ(1);
  @$pb.TagNumber(2)
  set channel($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChannel() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannel() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get data => $_getSZ(2);
  @$pb.TagNumber(3)
  set data($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);
}

