import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../utils/app_logger.dart';

class QuizProvider extends ChangeNotifier {
  bool _loading = false;
  int? _createdId;

  bool get loading => _loading;
  int? get createdId => _createdId;
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> get classes => _classes;
  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> get quizzes => _quizzes;
  List<Map<String, dynamic>> _materials = [];
  List<Map<String, dynamic>> get materials => _materials;

  Future<int?> createQuiz({required String title, String? duration, int? createdBy, List<int>? classIds}) async {
    _loading = true;
    notifyListeners();
    final payload = {
      'title': title,
      'duration': duration,
      'created_by': createdBy,
      'class_ids': classIds,
    };
    AppLogger.i('createQuiz request: ${payload.toString()}');
    try {
      final resp = await ApiService.createQuiz(payload);
      AppLogger.i('createQuiz response: status=${resp.statusCode} body=${resp.body}');
      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        _createdId = data['id'];
        _loading = false;
        notifyListeners();
        return _createdId;
      }
    } catch (e, st) {
      AppLogger.e('createQuiz error', e, st);
    }
    _loading = false;
    notifyListeners();
    return null;
  }

  Future<bool> loadClasses() async {
    try {
      // Prefer classes that the logged-in student has joined
      // Note: this provider isn't a widget; attempt to read token from shared prefs via AuthProvider is preferable
      // For now, call the public endpoint (fallback) — the UI pages handle token-aware fetching.
      final resp = await ApiService.getClasses();
      AppLogger.i('getClasses response: status=${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final list = (data['data'] as List).cast<Map<String, dynamic>>();
        _classes = list;
        notifyListeners();
        return true;
      }
    } catch (e, st) {
      AppLogger.e('getClasses error', e, st);
    }
    return false;
  }

  Future<bool> loadQuizzes({String? classId}) async {
    try {
      final resp = await ApiService.getQuizzes(classId: classId);
      AppLogger.i('getQuizzes response: status=${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final list = (data['data'] as List).cast<Map<String, dynamic>>();
        _quizzes = list;
        notifyListeners();
        return true;
      }
    } catch (e, st) {
      AppLogger.e('getQuizzes error', e, st);
    }
    return false;
  }

  Future<bool> loadMaterials({String? quizId}) async {
    try {
      final resp = await ApiService.getMaterials(quizId: quizId);
      AppLogger.i('getMaterials response: status=${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final list = (data['data'] as List).cast<Map<String, dynamic>>();
        _materials = list;
        notifyListeners();
        return true;
      }
    } catch (e, st) {
      AppLogger.e('getMaterials error', e, st);
    }
    return false;
  }
}
