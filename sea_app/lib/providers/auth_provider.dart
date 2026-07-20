import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/app_logger.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  User? _user;
  bool _loading = false;
  int _classesVersion = 0; // bump to notify class-list refresh

  String? get token => _token;
  User? get user => _user;
  bool get loading => _loading;
  int get classesVersion => _classesVersion;

  void bumpClassesVersion() {
    _classesVersion++;
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userStr = prefs.getString('user_data');
    if (userStr != null && userStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(userStr);
        _user = User.fromJson(Map<String, dynamic>.from(decoded));
      } catch (e) {
        // ignore parse error
      }
    }
    if (_token != null) {
      await fetchUser();
    }
    notifyListeners();
  }

  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Future<bool> register({required String name, required String email, required String password, required String role}) async {
    _loading = true;
    notifyListeners();
    try {
      AppLogger.i('Register request', {'name': name, 'email': email, 'role': role}.toString());
      final resp = await ApiService.register({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      AppLogger.i('Register response', 'status=${resp.statusCode} body=${resp.body}');
      _loading = false;
      notifyListeners();
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      AppLogger.e('Register error', e, StackTrace.current);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    notifyListeners();
    try {
      AppLogger.i('Login request', {'email': email}.toString());
      final resp = await ApiService.login({
        'email': email,
        'password': password,
      });
      AppLogger.i('Login response', 'status=${resp.statusCode} body=${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final token = data['token'] ?? data['access_token'] ?? data['data']?['token'];
        if (token != null) {
          _token = token.toString();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _token!);
          await fetchUser();
          _loading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      AppLogger.e('Login error', e, StackTrace.current);
    }
    _loading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchUser() async {
    if (_token == null) return;
    try {
      AppLogger.i('FetchUser request', 'token=${_token?.substring(0, 8)}...');
      final resp = await ApiService.getUser(_token!);
      AppLogger.i('FetchUser response', 'status=${resp.statusCode} body=${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final userJson = data['user'] ?? data['data'] ?? data;
        _user = User.fromJson(Map<String, dynamic>.from(userJson));
        await _saveUserToPrefs(_user!);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.e('fetchUser error', e, StackTrace.current);
    }
  }

  Future<void> setDevModeUser(User user, String token) async {
    _token = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await _saveUserToPrefs(user);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    notifyListeners();
  }
}
