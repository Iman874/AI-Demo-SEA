import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/all_message.dart';
import '../models/chat_room_ai.dart';
import '../models/material.dart'; // pastikan baris ini ada

// API config
const String apiHost = "127.0.0.1";
const String apiPort = "8000";
const String apiStudentChat = "http://$apiHost:$apiPort/api/student/chat";
const String apiCheckUnderstanding = "http://$apiHost:$apiPort/api/student/check_understanding";

/// Fungsi utilitas untuk mengirim pesan ke chatroom AI.
/// [controller] = TextEditingController input user
/// [chatRoom] = ChatRoomAI target
// ignore: unintended_html_in_doc_comment
/// [messages] = List<MessageModel> yang menampung history
/// [setState] = fungsi untuk update state di UI
Future<void> sendMessage({
  required TextEditingController controller,
  required ChatRoomAI chatRoom,
  required List<MessageModel> messages,
  required VoidCallback setState,
  required List<MaterialPdf> materials, // Tambahkan parameter ini
  required String senderId,
  String role = 'student',
}) async {
  if (controller.text.trim().isEmpty) return;

  // buat message student
  final newMessage = MessageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    chatRoomId: chatRoom.id,
    senderId: senderId,
    role: role,
    content: controller.text.trim(),
    contentType: "text",
    createdAt: DateTime.now(),
  );

  // update UI
  messages.add(newMessage);
  controller.clear();
  setState();

  try {
    // kirim request ke API
    final response = await http.post(
      Uri.parse(apiStudentChat),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "history": messages
            .take(50) // ambil max 50 pesan terakhir
            .map((m) => {
                  "role": m.role,
                  "content": m.content,
                })
            .toList(),
        "materials": materials
            .map((mat) => {
                  "title": mat.title,
                  "content": mat.content,
                  "type": mat.type,
                })
            .toList(),
        "chatroom_id": chatRoom.id,
        "sender_id": senderId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final aiContent = data["answer"] ?? "Error: no answer";

      final aiReply = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatRoomId: chatRoom.id,
        senderId: "ai",
        role: "ai",
        content: aiContent,
        contentType: "text",
        createdAt: DateTime.now(),
      );

      messages.add(aiReply);
      setState();

      // return persisted ai content if backend included any metadata
      return;
    } else {
      final errorReply = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatRoomId: chatRoom.id,
        senderId: "ai",
        role: "ai",
        content: "Error: ${response.statusCode}",
        contentType: "text",
        createdAt: DateTime.now(),
      );
      messages.add(errorReply);
      setState();
    }
  } catch (e) {
    final errorReply = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatRoomId: chatRoom.id,
      senderId: "ai",
      role: "ai",
      content: "Error connecting to server: $e",
      contentType: "text",
      createdAt: DateTime.now(),
    );
    messages.add(errorReply);
    setState();
  }
}

Future<String> checkUnderstanding({
  required List<MessageModel> messages,
  required List<MaterialPdf> materials,
  required String summary,
}) async {
  try {
    final response = await http.post(
      Uri.parse(apiCheckUnderstanding),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "materials": materials
            .map((mat) => {
                  "title": mat.title,
                  "content": mat.content,
                  "type": mat.type,
                })
            .toList(),
        // summary dikirim ke API
        "summary": summary,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["result"] ?? "No result";
    } else {
      return "Error: ${response.statusCode}";
    }
  } catch (e) {
    return "Error: $e";
  }
}
