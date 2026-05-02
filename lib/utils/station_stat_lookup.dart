/// WS_StationNum 推送里用字段 `Station` 作为 key，客户端列表用 IP / 站名等标识。
/// 在此处做多路匹配，避免 `Station` 与 `IP` 写法不一致时人数一直为 0。
Map<String, int>? lookupStationStatRow(
  Map<String, Map<String, int>> stats,
  String ip, {
  String stationName = '',
  String? nodeId,
}) {
  if (stats.isEmpty) return null;

  Map<String, int>? byKey(String? raw) {
    final key = raw?.trim() ?? '';
    if (key.isEmpty) return null;
    return stats[key];
  }

  for (final key in <String?>[
    ip,
    stationName,
    nodeId,
  ]) {
    final hit = byKey(key);
    if (hit != null) return hit;
  }

  final colon = ip.lastIndexOf(':');
  if (colon > 0) {
    final tail = ip.substring(colon + 1);
    if (int.tryParse(tail) != null) {
      final host = ip.substring(0, colon);
      final hit = byKey(host);
      if (hit != null) return hit;
    }
  }

  final ipLower = ip.trim().toLowerCase();
  final nameLower = stationName.trim().toLowerCase();
  final nodeLower = (nodeId ?? '').trim().toLowerCase();

  for (final e in stats.entries) {
    final kl = e.key.trim().toLowerCase();
    if (kl == ipLower || kl == nameLower || (nodeLower.isNotEmpty && kl == nodeLower)) {
      return e.value;
    }
    if (ipLower.isNotEmpty && ipLower.startsWith('$kl:')) {
      return e.value;
    }
  }
  return null;
}
