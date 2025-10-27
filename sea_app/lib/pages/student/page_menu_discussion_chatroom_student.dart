import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import models
// use AuthProvider to get current user instead of local dummy
import '../../models/chat_room_ai.dart';
import '../../models/all_message.dart';
import '../../models/material.dart';
import '../../models/summary_discussion.dart';
import '../../models/discussion_room.dart';

// import utils
import '../../services/api_service.dart';

// import components
import '../../component/window/window_add_summary.dart';
import '../../controller/controller_message_ai.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DiscussionPageChatRoomStudent extends StatefulWidget {
  final DiscussionRoom discussion;
  const DiscussionPageChatRoomStudent({super.key, required this.discussion});

  @override
  State<DiscussionPageChatRoomStudent> createState() =>
      _DiscussionPageChatRoomStudentState();
}

class _DiscussionPageChatRoomStudentState
    extends State<DiscussionPageChatRoomStudent> {
  final TextEditingController _controller = TextEditingController();
  // ambil dummy data dari models
  // chatRoom adapter built from discussion
  late ChatRoomAI chatRoom;
  String? studentId;
  String? studentName;
  final ScrollController _chatScrollController = ScrollController();

  // bikin list messages yang bisa diupdate
  List<MessageModel> messages = List.from(sampleMessages);

  // bikin list materials yang bisa diupdate
  List<MaterialPdf> materials = [];

  // bikin list summaries yang bisa diupdate
  // start empty; load real summaries from backend in _loadPersistedSummaries
  List<SummaryDiscussion> summaries = [];

  SummaryDiscussion? get currentSummary {
    final idx = summaries.indexWhere((s) => s.fkIdChatroomAi == chatRoom.id);
    return idx >= 0 ? summaries[idx] : null;
  }

  String? understandingResult;

  @override
  void initState() {
    super.initState();
    // initialize chatRoom adapter once
    chatRoom = ChatRoomAI(
      id: widget.discussion.idDiscussionRoom,
      title: widget.discussion.title,
      description: widget.discussion.description,
      createdBy: widget.discussion.createdBy,
      aiModel: 'gemini-2.0-flash',
      createdAt: widget.discussion.createdAt,
    );

    // kick off loading materials
    _loadMaterials();
    // load persisted messages and summaries from backend after frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPersistedMessages();
      await _loadPersistedSummaries();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        studentId = auth.user!.id;
        studentName = auth.user!.name;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    try {
      final resp = await ApiService.getMaterialsForDiscussion(discussionId: widget.discussion.idDiscussionRoom);
      if (resp.statusCode == 200) {
        try {
          final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
          final list = (decoded['data'] as List<dynamic>?) ?? [];
          materials = list.map((m) => MaterialPdfJson.fromJson(m as Map<String, dynamic>)).toList();
          if (mounted) setState(() {});
        } catch (e) {
          // ignore parse errors
        }
      }
    } catch (_) {
      // ignore network errors
    }
  }

  Future<void> _loadPersistedMessages() async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/api/discussion/messages?chatroom_id=${chatRoom.id}');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        final persisted = list.map((m) {
          return MessageModel(
            id: (m['id_message'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
            chatRoomId: (m['fk_id_chatroomai'] ?? chatRoom.id).toString(),
            senderId: (m['fk_id_user'] != null) ? m['fk_id_user'].toString() : (m['role'] == 'ai' ? 'ai' : 'unknown'),
            role: m['role'] ?? (m['fk_id_user'] == null ? 'ai' : 'student'),
            content: m['content'] ?? '',
            contentType: m['content_type'] ?? 'text',
            createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        final existingIds = messages.map((e) => e.id).toSet();
        for (final pm in persisted) {
          if (!existingIds.contains(pm.id)) {
            messages.add(pm);
          }
        }
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        if (!mounted) return;
        setState(() {});
        // scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_chatScrollController.hasClients) {
            _chatScrollController.jumpTo(_chatScrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      // ignore network errors
    }
  }

  Future<void> _loadPersistedSummaries() async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/api/discussion/summaries?chatroom_id=${chatRoom.id}');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        final persisted = list.map((s) {
          final map = s as Map<String, dynamic>;
          return SummaryDiscussion.fromJson(map);
        }).toList();
        summaries = persisted;
        if (!mounted) return;
        setState(() {});
        if (currentSummary != null && understandingResult == null) {
          final result = await checkUnderstanding(
            messages: messages,
            materials: materials,
            summary: currentSummary?.content ?? '',
          );
          if (!mounted) return;
          setState(() {
            understandingResult = result;
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    // chatRoom is initialized in initState
    return Scaffold(
      appBar: AppBar(title: Text('Discussion with AI (${chatRoom.title})')),
      // use TopHeader instead of AppBar to match app style
      body: Column(
        children: [
          //TopHeader(title: , backgroundColor: const Color.fromARGB(255, 57, 35, 35)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Section: Discussion Materials (left-aligned)
                Text("Discussion Materials",
                    style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Column(
            children: materials
                .map((mat) => _materialCard(mat.title))
                .toList(),
          ),
          const SizedBox(height: 16),


          const SizedBox(height: 16),

          // Section: Discussion Summary
          Text("Discussion Summary",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => WindowAddSummary(
                      summaries: summaries,
                      chatRoomId: chatRoom.id,
                      userId: studentId ?? '',
                      initialContent: currentSummary?.content, // tambahkan ini
                    ),
                  );
                  if (!mounted) return;
                  // refresh summaries and UI
                  setState(() {});
                  // if summary now exists for this user, auto-run understanding and persist
                  if (currentSummary != null) {
                    // call understanding API
                    if (!mounted) return;
                    setState(() { understandingResult = null; });
                    final result = await checkUnderstanding(
                      messages: messages,
                      materials: materials,
                      summary: currentSummary?.content ?? '',
                    );
                    if (!mounted) return;
                    setState(() { understandingResult = result; });
                  }
                },
                child: Text(currentSummary == null ? "Add Summary" : "Edit Summary"),
              ),
            ),
          ),
          if (currentSummary != null)
            Card(
              child: ListTile(
                title: Text(currentSummary!.content),
                subtitle: Text("By: ${currentSummary!.fkIdUser ?? 'Unknown'}"),
              ),
            ),
          const SizedBox(height: 16),
          // Understanding value will be shown automatically after summary is added
          if (understandingResult != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  title: Text("Result: $understandingResult"),
                ),
              ),
            ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),

          // Chat card (centered) - internal scroll only
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Container(
                  height: 520,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // title inside card
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('AI Discussion Room', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      const SizedBox(height: 8),

                      // chat messages area (scrollable)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: messages.isEmpty
                              ? Center(
                                  child: Text(
                                    'No messages yet. Start the discussion by asking a question.',
                                    style: TextStyle(color: Colors.grey.shade600),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Scrollbar(
                                  controller: _chatScrollController,
                                  child: ListView(
                                    controller: _chatScrollController,
                                    children: messages.map((msg) {
                                      final sender = (msg.role == "ai")
                                          ? "SEA Bot"
                                          : (msg.senderId == studentId ? (studentName ?? 'You') : 'Teacher');
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: ChatBubble(
                                          "${sender}: ${msg.content}",
                                          isUser: msg.role == "student",
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // input row inside the card
                      _buildInputRow(),
                    ],
                  ),
                ),
              ),
            ),
          ),
                const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _materialCard(String title) {
    return Card(
      child: ListTile(
        leading: Image.asset(
          'assets/icon/pdf_icon.png',
          width: 20,
          height: 20,
          fit: BoxFit.fill,
        ),
        title: Text(title),
        trailing: TextButton(
          onPressed: () {
            // TODO: View Material PDF
          },
          child: const Text("View Material"),
        ),
      ),
    );
  }
  Widget _buildInputRow() {
    final isCompletedForUser = currentSummary != null && currentSummary!.fkIdUser == studentId;
    if (isCompletedForUser) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              // show read-only discussion result
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Discussion result'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentSummary != null) ...[
                            Text('Summary:', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(currentSummary!.content),
                            const SizedBox(height: 12),
                          ],
                          Text('Messages:', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ...messages.map((m) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('${m.role == "ai" ? "SEA Bot" : m.senderId == studentId ? "You" : "Teacher"}: ${m.content}'),
                              )),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
                  ],
                ),
              );
            },
            child: const Text('View result discussion'),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your question',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final uid = auth.user?.id;
              if (uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login required to send messages')));
                return;
              }

              await sendMessage(
                controller: _controller,
                chatRoom: chatRoom,
                messages: messages,
                setState: () {
                  if (mounted) setState(() {});
                },
                materials: materials,
                senderId: uid,
                role: 'student',
              );

              // reload persisted messages so client shows canonical history
              await _loadPersistedMessages();

              // scroll to bottom after a short delay so UI has updated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_chatScrollController.hasClients) {
                  _chatScrollController.animateTo(
                    _chatScrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const ChatBubble(this.text, {super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isUser ? Colors.green.shade100 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text),
      ),
    );
  }
}