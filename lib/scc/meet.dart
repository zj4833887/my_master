class Meet {
  int? ID;
  String? meetID;
  String? parentID;
  String? name;
  String? forShort;
  String? content;
  DateTime? beginTime;
  DateTime? endTime;
  String? appearedType;
  String? specialType;
  int? personNum;
  int? specialNum;
  int? meetFinished;
  int? sign;
  List<int>? background;
  List<int>? foreground;
  String? parameters;

  Meet({
    this.ID,
    this.meetID,
    this.parentID,
    this.name,
    this.forShort,
    this.content,
    this.beginTime,
    this.endTime,
    this.appearedType,
    this.specialType,
    this.personNum,
    this.specialNum,
    this.meetFinished,
    this.sign,
    this.background,
    this.foreground,
    this.parameters,
  });
}