import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';

  Future<bool> login(String email, String password) async {
    // SIMPLE LOGIN - Works without internet
    if (email.isNotEmpty && password.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@').first,
      );

      await _saveUser(user);
      return true;
    }
    return false;
  }

  Future<bool> signup(String email, String password, String name) async {
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
      );

      await _saveUser(user);
      return true;
    }
    return false;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toMap().toString());
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData != null) {
      // For demo - returns a fake user
      final map = {
        'id': '123',
        'email': 'demo@example.com',
        'name': 'Demo User',
        'joinedDate': DateTime.now().toIso8601String()
      };
      return User.fromMap(map);
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}