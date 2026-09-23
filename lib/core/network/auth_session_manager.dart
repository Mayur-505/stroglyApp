import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionManager {
  static final AuthSessionManager instance = AuthSessionManager._internal();
  factory AuthSessionManager() => instance;
  AuthSessionManager._internal();

  static const String _keyToken = 'strongly_auth_token';
  static const String _keyUserId = 'strongly_user_id';
  static const String _keyIsGuest = 'strongly_is_guest';
  static const String _keyUserName = 'strongly_user_name';
  static const String _keyUserEmail = 'strongly_user_email';

  static const String _keyUserAvatar = 'strongly_user_avatar';

  String? _token;
  String? _userId;
  bool _isGuest = false;
  String? _userName;
  String? _userEmail;
  String? _userAvatar;

  String? get token => _token;
  String? get userId => _userId;
  bool get isGuest => _isGuest;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userAvatar => _userAvatar;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_keyToken);
      _userId = prefs.getString(_keyUserId);
      _isGuest = prefs.getBool(_keyIsGuest) ?? false;
      _userName = prefs.getString(_keyUserName);
      _userEmail = prefs.getString(_keyUserEmail);
      _userAvatar = prefs.getString(_keyUserAvatar);
    } catch (_) {}
  }

  Future<void> saveSession({
    required String token,
    required String userId,
    bool isGuest = false,
    String? name,
    String? email,
    String? avatar,
  }) async {
    _token = token;
    _userId = userId;
    _isGuest = isGuest;
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (avatar != null) _userAvatar = avatar;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUserId, userId);
      await prefs.setBool(_keyIsGuest, isGuest);
      if (name != null) {
        await prefs.setString(_keyUserName, name);
      }
      if (email != null) {
        await prefs.setString(_keyUserEmail, email);
      }
      if (avatar != null) {
        await prefs.setString(_keyUserAvatar, avatar);
      }
    } catch (_) {}
  }

  Future<void> clearSession() async {
    _token = null;
    _userId = null;
    _isGuest = false;
    _userName = null;
    _userEmail = null;
    _userAvatar = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyIsGuest);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserAvatar);
    } catch (_) {}
  }
}
