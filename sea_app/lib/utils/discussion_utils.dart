// DEPRECATED: moved to ApiService.deleteAllDiscussionMessages
import '../services/api_service.dart';

Future<bool> deleteAllDiscussionMessages({required String chatRoomId}) async {
  try {
    final resp = await ApiService.deleteAllDiscussionMessages(chatroomId: chatRoomId);
    return resp.statusCode == 200;
  } catch (e) {
    return false;
  }
}
