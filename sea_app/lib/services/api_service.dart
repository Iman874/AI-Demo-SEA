import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized API service with dynamic host/port configuration.
/// Call ApiService.init() early (e.g., in main()) to load persisted config.
class ApiService {
  static const _prefHostKey = 'api_host';
  static const _prefPortKey = 'api_port';
  static const _prefSchemeKey = 'api_scheme';

  static String _host = '127.0.0.1';
  static String _port = '8000'; // empty string => no port appended
  static String _scheme = 'http'; // 'http' or 'https'

  /// Initialize by loading saved host/port if present.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _host = prefs.getString(_prefHostKey) ?? _host;
      _port = prefs.getString(_prefPortKey) ?? _port;
      _scheme = prefs.getString(_prefSchemeKey) ?? _scheme;
    } catch (_) {
      // ignore load errors, keep defaults
    }
  }

  /// Set and persist host/port.
  static Future<void> setConfig({required String host, required String port, String? scheme}) async {
    _host = host.trim();
    _port = port.trim();
    if (scheme != null && (scheme == 'http' || scheme == 'https')) {
      _scheme = scheme;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefHostKey, _host);
      await prefs.setString(_prefPortKey, _port);
      await prefs.setString(_prefSchemeKey, _scheme);
    } catch (_) {
      // ignore persistence errors
    }
  }

  static String get host => _host;
  static String get port => _port;
  static String get scheme => _scheme;
  static String get base => _port.isEmpty ? '$_scheme://$_host' : '$_scheme://$_host:$_port';

  /// Simple connectivity check against /api/echo returning true on HTTP 200.
  static Future<bool> checkConnection() async {
    try {
      final resp = await http.post(Uri.parse('$base/api/echo'),
          headers: {'Content-Type': 'application/json'}, body: jsonEncode({'ping': 'pong'}));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<http.Response> register(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/register'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> login(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/login'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> getUser(String token) {
    return http.get(Uri.parse('$base/api/user'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
  }

  static Future<http.Response> createQuiz(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/quizzes'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> getClasses() {
    return http.get(Uri.parse('$base/api/classes'), headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getClassMembers({required String classId}) {
    final uri = Uri.parse('$base/api/class-members?class_id=$classId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getMyClasses({String? token, String? userId}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final uri = userId == null
        ? Uri.parse('$base/api/my-classes')
        : Uri.parse('$base/api/my-classes?user_id=$userId');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> getUserClassIds({String? token, String? userId}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final uri = userId == null
        ? Uri.parse('$base/api/user-class-ids')
        : Uri.parse('$base/api/user-class-ids?user_id=$userId');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> createClass(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/classes'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> joinClass(Map<String, dynamic> body, {String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.post(Uri.parse('$base/api/join-class'), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> getDiscussions({String? classId}) {
    final uri = classId == null
        ? Uri.parse('$base/api/discussions')
        : Uri.parse('$base/api/discussions?class_id=$classId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getMaterials({String? quizId}) {
    final uri = quizId == null
        ? Uri.parse('$base/api/materials')
        : Uri.parse('$base/api/materials?quiz_id=$quizId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getMaterialsForDiscussion({String? discussionId}) {
    final uri = discussionId == null
        ? Uri.parse('$base/api/materials')
        : Uri.parse('$base/api/materials?discussion_id=$discussionId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionMembers({String? discussionId, String? chatroomId, String? userId}) {
    Uri uri;
    if (discussionId != null) {
      final q = userId != null ? 'discussion_id=$discussionId&user_id=$userId' : 'discussion_id=$discussionId';
      uri = Uri.parse('$base/api/discussion-members?$q');
    } else if (chatroomId != null) {
      final q = userId != null ? 'chatroom_id=$chatroomId&user_id=$userId' : 'chatroom_id=$chatroomId';
      uri = Uri.parse('$base/api/discussion-members?$q');
    } else {
      uri = Uri.parse('$base/api/discussion-members');
    }
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionQuestions({String? chatroomId}) {
    final uri = chatroomId == null
        ? Uri.parse('$base/api/discussion-questions')
        : Uri.parse('$base/api/discussion-questions?chatroom_id=$chatroomId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionSummariesDb({String? chatroomId}) {
    final uri = chatroomId == null
        ? Uri.parse('$base/api/discussion-summaries')
        : Uri.parse('$base/api/discussion-summaries?chatroom_id=$chatroomId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionMessages({required String chatroomId}) {
    final uri = Uri.parse('$base/api/discussion/messages?chatroom_id=$chatroomId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionUnderstandings({String? summaryId, String? chatroomId, String? discussionId}) {
    Uri uri;
    if (summaryId != null) {
      uri = Uri.parse('$base/api/discussion-understandings?summary_id=$summaryId');
    } else if (chatroomId != null) {
      uri = Uri.parse('$base/api/discussion-understandings?chatroom_id=$chatroomId');
    } else if (discussionId != null) {
      uri = Uri.parse('$base/api/discussion-understandings?discussion_id=$discussionId');
    } else {
      uri = Uri.parse('$base/api/discussion-understandings');
    }
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getQuizzes({String? classId}) {
    final uri = classId == null
        ? Uri.parse('$base/api/quizzes')
        : Uri.parse('$base/api/quizzes?class_id=$classId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getQuizQuestions({required String quizId}) {
    final uri = Uri.parse('$base/api/quiz-questions?quiz_id=$quizId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> submitQuizResult(Map<String, dynamic> body, {String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.post(Uri.parse('$base/api/result-quiz'), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> getQuizResults({String? userId, String? quizId, String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    String query = '';
    if (userId != null) query += 'user_id=$userId';
    if (quizId != null) query += '${query.isEmpty ? '' : '&'}quiz_id=$quizId';
    final uri = Uri.parse('$base/api/result-quiz${query.isEmpty ? '' : '?$query'}');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> getQuizResultDetails({required String userId, required String quizId, String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final uri = Uri.parse('$base/api/result-quiz?user_id=$userId&quiz_id=$quizId&details=1');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> createMaterial(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/materials'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> createDiscussion(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/discussions'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> updateDiscussion(String id, Map<String, dynamic> body) {
    return http.put(Uri.parse('$base/api/discussions/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> getDiscussion(String id) {
    return http.get(Uri.parse('$base/api/discussions/$id'), headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> createFullQuiz(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/quizzes/save'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> generateQuestions(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/generate-questions'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> generateGroups(Map<String, dynamic> body) {
    return http.post(Uri.parse('$base/api/generate-groups'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  // --- Student AI endpoints centralized ---
  static Future<http.Response> studentChat({required List<Map<String, String>> history, required List<Map<String, String>> materials, String? chatroomId, String? senderId}) {
    return http.post(Uri.parse('$base/api/student/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'history': history,
          'materials': materials,
          if (chatroomId != null) 'chatroom_id': chatroomId,
          if (senderId != null) 'sender_id': senderId,
        }));
  }

  static Future<http.Response> checkUnderstandingAI({
    required List<Map<String, String>> materials,
    required String summary,
    String? chatroomId,
    String? summaryId,
  }) {
    final body = {
      'materials': materials,
      'summary': summary,
      if (chatroomId != null) 'chatroom_id': chatroomId,
      if (summaryId != null) 'summary_id': summaryId,
    };
    return http.post(
      Uri.parse('$base/api/student/check_understanding'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  // Discussion helpers
  static Future<http.Response> submitDiscussionSummary({required String chatroomId, required String userId, required String content}) {
    return http.post(Uri.parse('$base/api/discussion/submit_summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'chatroom_id': chatroomId, 'user_id': userId, 'content': content}));
  }

  static Future<http.Response> deleteAllDiscussionMessages({required String chatroomId}) {
    return http.post(Uri.parse('$base/api/discussion/delete_all_messages'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode({'chatroom_id': chatroomId}));
  }
}
