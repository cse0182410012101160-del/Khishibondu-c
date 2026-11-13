import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'cached_user';
  static const String _keyCrops = 'cached_crops';
  static const String _keyWeather = 'cached_weather';
  static const String _keyLastDivision = 'last_known_division';
  static const String _keyChatThreads = 'cached_chat_threads';
  static const String _keyChatMessagesPrefix = 'cached_chat_messages_';

  // Auth Token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }

  // User Profile
  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _prefs.setString(_keyUser, jsonEncode(userJson));
  }

  Map<String, dynamic>? getUser() {
    final str = _prefs.getString(_keyUser);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Crops Cache (For offline rural browsing)
  Future<void> cacheCrops(List<dynamic> crops) async {
    await _prefs.setString(_keyCrops, jsonEncode(crops));
  }

  List<dynamic>? getCachedCrops() {
    final str = _prefs.getString(_keyCrops);
    if (str == null) return null;
    try {
      return jsonDecode(str) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Weather Cache
  Future<void> cacheWeather(Map<String, dynamic> weather) async {
    await _prefs.setString(_keyWeather, jsonEncode(weather));
  }

  Map<String, dynamic>? getCachedWeather() {
    final str = _prefs.getString(_keyWeather);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Last known division (geo-based market discovery, offline-first)
  Future<void> saveLastDivision(String division) async {
    await _prefs.setString(_keyLastDivision, division);
  }

  String? getLastDivision() {
    return _prefs.getString(_keyLastDivision);
  }

  // ---- Offline chat persistence (rural connectivity) ----
  Future<void> cacheChatThreads(List<dynamic> threads) async {
    await _prefs.setString(_keyChatThreads, jsonEncode(threads));
  }

  List<dynamic>? getCachedChatThreads() {
    final str = _prefs.getString(_keyChatThreads);
    if (str == null) return null;
    try {
      return jsonDecode(str) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheChatMessages(String threadId, List<dynamic> messages) async {
    await _prefs.setString('$_keyChatMessagesPrefix$threadId', jsonEncode(messages));
  }

  List<dynamic>? getCachedChatMessages(String threadId) {
    final str = _prefs.getString('$_keyChatMessagesPrefix$threadId');
    if (str == null) return null;
    try {
      return jsonDecode(str) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }
}

