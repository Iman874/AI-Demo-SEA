import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Configure host/port to match backend defaults
  static const String apiHost = 'http://127.0.0.1:8000';

  static Future<http.Response> register(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/register'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> login(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/login'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> getUser(String token) {
    return http.get(Uri.parse('$apiHost/api/user'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });
  }

  static Future<http.Response> createQuiz(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/quizzes'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> getClasses() {
    return http.get(Uri.parse('$apiHost/api/classes'), headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getClassMembers({required String classId}) {
    final uri = Uri.parse('$apiHost/api/class-members?class_id=$classId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getMyClasses({String? token, String? userId}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final uri = userId == null
        ? Uri.parse('$apiHost/api/my-classes')
        : Uri.parse('$apiHost/api/my-classes?user_id=$userId');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> getUserClassIds({String? token, String? userId}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final uri = userId == null
        ? Uri.parse('$apiHost/api/user-class-ids')
        : Uri.parse('$apiHost/api/user-class-ids?user_id=$userId');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> createClass(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/classes'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> joinClass(Map<String, dynamic> body, {String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.post(Uri.parse('$apiHost/api/join-class'), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> getDiscussions({String? classId}) {
    final uri = classId == null
        ? Uri.parse('$apiHost/api/discussions')
        : Uri.parse('$apiHost/api/discussions?class_id=$classId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getMaterials({String? quizId}) {
    final uri = quizId == null
        ? Uri.parse('$apiHost/api/materials')
        : Uri.parse('$apiHost/api/materials?quiz_id=$quizId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getMaterialsForDiscussion({String? discussionId}) {
    final uri = discussionId == null
        ? Uri.parse('$apiHost/api/materials')
        : Uri.parse('$apiHost/api/materials?discussion_id=$discussionId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionMembers({String? discussionId, String? chatroomId}) {
    Uri uri;
    if (discussionId != null) {
      uri = Uri.parse('$apiHost/api/discussion-members?discussion_id=$discussionId');
    } else if (chatroomId != null) {
      uri = Uri.parse('$apiHost/api/discussion-members?chatroom_id=$chatroomId');
    } else {
      uri = Uri.parse('$apiHost/api/discussion-members');
    }
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionQuestions({String? chatroomId}) {
    final uri = chatroomId == null
        ? Uri.parse('$apiHost/api/discussion-questions')
        : Uri.parse('$apiHost/api/discussion-questions?chatroom_id=$chatroomId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionSummariesDb({String? chatroomId}) {
    final uri = chatroomId == null
        ? Uri.parse('$apiHost/api/discussion-summaries')
        : Uri.parse('$apiHost/api/discussion-summaries?chatroom_id=$chatroomId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getDiscussionUnderstandings({String? summaryId}) {
    final uri = summaryId == null
        ? Uri.parse('$apiHost/api/discussion-understandings')
        : Uri.parse('$apiHost/api/discussion-understandings?summary_id=$summaryId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getQuizzes({String? classId}) {
    final uri = classId == null
        ? Uri.parse('$apiHost/api/quizzes')
        : Uri.parse('$apiHost/api/quizzes?class_id=$classId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getQuizQuestions({required String quizId}) {
    final uri = Uri.parse('$apiHost/api/quiz-questions?quiz_id=$quizId');
    return http.get(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> submitQuizResult(Map<String, dynamic> body, {String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.post(Uri.parse('$apiHost/api/result-quiz'), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> getQuizResults({String? userId, String? quizId, String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    String query = '';
    if (userId != null) query += 'user_id=$userId';
    if (quizId != null) query += '${query.isEmpty ? '' : '&'}quiz_id=$quizId';
  final uri = Uri.parse('${apiHost}/api/result-quiz${query.isEmpty ? '' : '?$query'}');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> getQuizResultDetails({required String userId, required String quizId, String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final uri = Uri.parse('$apiHost/api/result-quiz?user_id=$userId&quiz_id=$quizId&details=1');
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> createMaterial(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/materials'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> createDiscussion(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/discussions'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> updateDiscussion(String id, Map<String, dynamic> body) {
    return http.put(Uri.parse('$apiHost/api/discussions/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> getDiscussion(String id) {
    return http.get(Uri.parse('$apiHost/api/discussions/$id'), headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> createFullQuiz(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/quizzes/save'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> generateQuestions(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/generate-questions'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> generateGroups(Map<String, dynamic> body) {
    return http.post(Uri.parse('$apiHost/api/generate-groups'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }
}
