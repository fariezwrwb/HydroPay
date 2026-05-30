import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyToken = 'token';
  static const _keyRole = 'role';
  static const _keyOwnerToken = 'owner_token';

  static Future<void> saveSession({
    required String token,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRole, role);
  }

  static Future<void> saveOwnerToken(String ownerToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOwnerToken, ownerToken);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<String?> getOwnerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOwnerToken);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRole);

  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


// Method untuk hapus session saat logout:
static Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('role');
}
}
