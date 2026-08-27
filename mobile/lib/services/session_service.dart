import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyPlayerId = 'player_id';
  static const _keyRoomId = 'room_id';
  static const _keyNickname = 'nickname';
  static const _keyRole = 'role';
  static const _keyBackendUrl = 'backend_url';
  static const _keyLastUrls = 'last_urls';
  static const _keyDarkMode = 'dark_mode';

  Future<void> saveSession({
    required String playerId,
    required String roomId,
    required String nickname,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlayerId, playerId);
    await prefs.setString(_keyRoomId, roomId);
    await prefs.setString(_keyNickname, nickname);
    await prefs.setString(_keyRole, role);
  }

  Future<Map<String, String>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final playerId = prefs.getString(_keyPlayerId);
    final roomId = prefs.getString(_keyRoomId);
    final nickname = prefs.getString(_keyNickname);
    final role = prefs.getString(_keyRole);

    if (playerId == null || roomId == null || nickname == null || role == null) {
      return null;
    }

    return {
      'player_id': playerId,
      'room_id': roomId,
      'nickname': nickname,
      'role': role,
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlayerId);
    await prefs.remove(_keyRoomId);
    await prefs.remove(_keyNickname);
    await prefs.remove(_keyRole);
  }

  Future<String> getBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBackendUrl) ?? 'http://localhost:5000';
  }

  Future<void> saveBackendUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBackendUrl, url);

    // Сохраняем в историю последних URL
    final historyRaw = prefs.getStringList(_keyLastUrls) ?? [];
    final history = List<String>.from(historyRaw);
    history.remove(url); // убираем дубликат
    history.insert(0, url); // добавляем в начало
    if (history.length > 3) history.removeLast(); // не больше 3
    await prefs.setStringList(_keyLastUrls, history);
  }

  Future<List<String>> getLastUrls() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyLastUrls) ?? [];
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }
}
