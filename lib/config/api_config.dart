/// API 配置类
/// 统一管理所有 API 相关的配置和常量
class ApiConfig {
  // 私有构造函数，防止实例化
  ApiConfig._();

  /// API 基础 URL
  /// 根据环境可以修改为不同的地址
  static const String baseUrl = 'http://192.168.0.160:50051';

  /// API 基础路径
  static const String apiPath = '/control';

  /// 完整的 API 基础 URL（包含路径）
  static String get apiBaseUrl => '$baseUrl$apiPath';

  /// 登录接口
  static String get loginUrl => '$apiBaseUrl/login';

  /// 查询会议列表
  static String get queryMeetUrl => '$apiBaseUrl/queryMeet';

  /// 查询当前进行的会议
  static String get queryOnMeetUrl => '$apiBaseUrl/queryOnMeet';

  /// 查询会议信息
  static String get queryMeetInfoUrl => '$apiBaseUrl/queryMeetInfo';

  /// 设置会议
  static String get setMeetUrl => '$apiBaseUrl/setMeet';

  /// 继续会议
  static String get continueMeetUrl => '$apiBaseUrl/continueMeet';
}


