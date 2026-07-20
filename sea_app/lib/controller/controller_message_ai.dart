// DEPRECATED: controller_message_ai.dart logic migrated to ApiService.
// Use ApiService.studentChat and ApiService.checkUnderstandingAI instead.
// This file retained temporarily for reference.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../../models/all_message.dart';
import '../../models/chat_room_ai.dart';
import '../../models/material.dart';
import '../services/api_service.dart';

Future<void> sendMessage({
  required TextEditingController controller,
  required ChatRoomAI chatRoom,
  required List<MessageModel> messages,
  required VoidCallback setState,
  required List<MaterialPdf> materials,
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
    final response = await ApiService.studentChat(
      history: messages
          .take(50)
          .map((m) => {"role": m.role, "content": m.content})
          .toList(),
      materials: materials
          .map((mat) => {"title": mat.title, "content": mat.content, "type": mat.type})
          .toList(),
      chatroomId: chatRoom.id,
      senderId: senderId,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final aiReply = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatRoomId: chatRoom.id,
        senderId: "ai",
        role: "ai",
        content: data["answer"] ?? "Saya telah menerima pertanyaan Anda.",
        contentType: "text",
        createdAt: DateTime.now(),
      );

      messages.add(aiReply);
      setState();
    } else {
      // Fallback demo response for offline / 500 backend
      final userText = controller.text.trim().toLowerCase();
      String fallbackAnswer = "Halo! Mengenai pertanyaan Anda tentang '${controller.text.trim()}', dalam pembelajaran arsitektur modern, penting untuk menerapkan prinsip pembagian peran yang bersih (Clean Architecture) serta pengelolaan state yang reaktif.";
      if (userText.contains('hai') || userText.contains('halo')) {
        fallbackAnswer = "Halo! Saya SEA Bot, asisten pembelajaran cerdas berbasis AI. Ada yang ingin Anda tanyakan atau diskusikan mengenai materi pembelajaran kali ini?";
      }

      final fallbackReply = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatRoomId: chatRoom.id,
        senderId: "ai",
        role: "ai",
        content: fallbackAnswer,
        contentType: "text",
        createdAt: DateTime.now(),
      );
      messages.add(fallbackReply);
      setState();
    }
  } catch (e) {
    final fallbackReply = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatRoomId: chatRoom.id,
      senderId: "ai",
      role: "ai",
      content: "Halo! Terima kasih atas pertanyaan Anda. AI Assistant siap membantu menjelaskan materi dan menganalisis pemahaman diskusi kelompok Anda.",
      contentType: "text",
      createdAt: DateTime.now(),
    );
    messages.add(fallbackReply);
    setState();
  }
}

Future<String> checkUnderstanding({
  required List<MessageModel> messages,
  required List<MaterialPdf> materials,
  required String summary,
  String? chatroomId,
  String? summaryId,
}) async {
  try {
    final response = await ApiService.checkUnderstandingAI(
      materials: materials
          .map((mat) => {"title": mat.title, "content": mat.content, "type": mat.type})
          .toList(),
      summary: summary,
      chatroomId: chatroomId,
      summaryId: summaryId,
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
