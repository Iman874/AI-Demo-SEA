import 'dart:convert';
import 'package:http/http.dart' as http;

const String _apiHost = '127.0.0.1';
const String _apiPort = '8000';
const String _apiDeleteAllMessages = 'http://$_apiHost:$_apiPort/api/discussion/delete_all_messages';

Future<bool> deleteAllDiscussionMessages({required String chatRoomId}) async {
  try {
    final resp = await http.post(
      Uri.parse(_apiDeleteAllMessages),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chatroom_id': chatRoomId}),
    );
    return resp.statusCode == 200;
  } catch (e) {
    return false;
  }
}
