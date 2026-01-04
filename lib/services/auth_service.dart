import 'package:shared_preferences/shared_preferences.dart';

/// Basit (ders projesi) yerel kimlik doğrulama.
/// Not: Gerçek projede şifreyi düz metin saklama yapılmaz.
class AuthService {
  static const _kLoggedIn = 'auth_logged_in';
  static const _kName = 'auth_name';
  static const _kEmail = 'auth_email';
  static const _kPassword = 'auth_password';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  static Future<String?> currentName() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kName);
    return (v == null || v.trim().isEmpty) ? null : v.trim();
  }

  static Future<String?> currentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kEmail);
    return (v == null || v.trim().isEmpty) ? null : v.trim();
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_kName, name.trim());
    await prefs.setString(_kEmail, email.trim().toLowerCase());
    await prefs.setString(_kPassword, password);

    // Kayıt olur olmaz giriş yap.
    await prefs.setBool(_kLoggedIn, true);
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = (prefs.getString(_kEmail) ?? '').trim().toLowerCase();
    final savedPass = prefs.getString(_kPassword) ?? '';

    final ok = savedEmail.isNotEmpty &&
        savedEmail == email.trim().toLowerCase() &&
        savedPass == password;

    await prefs.setBool(_kLoggedIn, ok);
    return ok;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
  }

  static Future<bool> hasAnyAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_kEmail) ?? '').trim().isNotEmpty &&
        (prefs.getString(_kPassword) ?? '').isNotEmpty;
  }
}
