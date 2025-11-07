// ping 请求
class ReqPing {
  Map<String, dynamic> params;

  ReqPing({
    required this.params,
  });

  @override
  String toString() {
    return 'ReqPing{name: $params}';
  }
}


// 登录请求
class ReqLogin {
  String name;
  String password;

  ReqLogin({
    required this.name,
    required this.password,
  });

  @override
  String toString() {
    return 'ReqLogin{name: $name, password: $password}';
  }
}

// 会议相关请求
class ReqMeet {
  String meetID;

  ReqMeet({
    required this.meetID,
  });

  @override
  String toString() {
    return 'ReqMeet{meetID: $meetID}';
  }
}

// 数据检查请求
class ReqCheck {
  String stations;
  String tables;

  ReqCheck({
    required this.stations,
    required this.tables,
  });

  @override
  String toString() {
    return 'ReqCheck{stations: $stations, tables: $tables}';
  }
}

// 数据导入请求
class ReqImport {
  String file;

  ReqImport({
    required this.file,
  });

  @override
  String toString() {
    return 'ReqImport{file: $file}';
  }
}


