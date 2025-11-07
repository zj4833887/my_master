import 'dart:convert';
import 'dart:typed_data';
import 'meet.dart';

class MeetVo {
  int id;
  String meetId;
  String parentId;
  String name;
  String forShort;
  String content;
  DateTime beginTime;
  DateTime endTime;
  String appearedType;
  String specialType;
  int personNum;
  int specialNum;
  int meetFinished;
  int sign;
  Uint8List background;
  Uint8List foreground;
  String parameters;
  List<Meet> checkin;

  MeetVo({
    required this.id,
    required this.meetId,
    required this.parentId,
    required this.name,
    required this.forShort,
    required this.content,
    required this.beginTime,
    required this.endTime,
    required this.appearedType,
    required this.specialType,
    required this.personNum,
    required this.specialNum,
    required this.meetFinished,
    required this.sign,
    required this.background,
    required this.foreground,
    required this.parameters,
    required this.checkin,
  });

  @override
  String toString() {
    return 'MeetVo{id: $id, name: $name, meetId: $meetId, beginTime: $beginTime}';
  }
}