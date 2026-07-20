import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/chat_room_ai.dart';
import '../../models/all_message.dart';
import '../../models/material.dart';
import '../../models/summary_discussion.dart';
import '../../models/discussion_room.dart';
import '../../component/window/window_add_summary.dart';
import '../../controller/controller_message_ai.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

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
  final ScrollController _chatScrollController = ScrollController();

  late ChatRoomAI chatRoom;
  String? studentId;
  String? studentName;

  List<MessageModel> messages = List.from(sampleMessages);
  List<MaterialPdf> materials = [];
  List<SummaryDiscussion> summaries = [];
  String? understandingResult;
  bool _isSending = false;
  bool _showMaterials = false;

  SummaryDiscussion? get currentSummary {
    final idx = summaries.indexWhere((s) => s.fkIdChatroomAi == chatRoom.id);
    return idx >= 0 ? summaries[idx] : null;
  }

  @override
  void initState() {
    super.initState();
    chatRoom = ChatRoomAI(
      id: widget.discussion.idDiscussionRoom,
      title: widget.discussion.title,
      description: widget.discussion.description,
      createdBy: widget.discussion.createdBy,
      aiModel: 'gemini-2.0-flash',
      createdAt: widget.discussion.createdAt,
    );

    _loadMaterials();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPersistedMessages();
      await _loadPersistedSummaries();
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
      final resp = await ApiService.getMaterialsForDiscussion(
          discussionId: widget.discussion.idDiscussionRoom);
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty
            ? jsonDecode(resp.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        materials = list
            .map((m) => MaterialPdfJson.fromJson(m as Map<String, dynamic>))
            .toList();
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _loadPersistedMessages() async {
    try {
      final rawResp =
          await ApiService.getDiscussionMessages(chatroomId: chatRoom.id);
      if (rawResp.statusCode == 200) {
        final decoded = rawResp.body.isNotEmpty
            ? jsonDecode(rawResp.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        final persisted = list.map((m) {
          return MessageModel(
            id: (m['id_message'] ?? DateTime.now().millisecondsSinceEpoch)
                .toString(),
            chatRoomId: (m['fk_id_chatroomai'] ?? chatRoom.id).toString(),
            senderId: (m['fk_id_user'] != null)
                ? m['fk_id_user'].toString()
                : (m['role'] == 'ai' ? 'ai' : 'unknown'),
            role: m['role'] ?? (m['fk_id_user'] == null ? 'ai' : 'student'),
            content: m['content'] ?? '',
            contentType: m['content_type'] ?? 'text',
            createdAt:
                DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
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
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _loadPersistedSummaries() async {
    try {
      final resp =
          await ApiService.getDiscussionSummariesDb(chatroomId: chatRoom.id);
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty
            ? jsonDecode(resp.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        summaries = list
            .map((s) => SummaryDiscussion.fromJson(s as Map<String, dynamic>))
            .toList();
        if (!mounted) return;
        setState(() {});
        if (currentSummary != null) {
          await _ensureUnderstandingForCurrentSummary();
        }
      }
    } catch (_) {}
  }

  Future<void> _ensureUnderstandingForCurrentSummary() async {
    final sum = currentSummary;
    if (sum == null) return;
    if (understandingResult != null && understandingResult!.trim().isNotEmpty) {
      return;
    }

    try {
      final resp =
          await ApiService.getDiscussionUnderstandings(summaryId: sum.id);
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty
            ? jsonDecode(resp.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        if (list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final type = (first['type'] ?? '').toString();
          if (type.isNotEmpty) {
            if (!mounted) return;
            setState(() {
              understandingResult = type;
            });
            return;
          }
        }
      }

      final result = await checkUnderstanding(
        messages: messages,
        materials: materials,
        summary: sum.content,
        chatroomId: chatRoom.id,
        summaryId: sum.id,
      );
      if (!mounted) return;
      setState(() {
        understandingResult = result;
      });
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.user?.id ?? studentId ?? 'user_dev';

    setState(() => _isSending = true);

    try {
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
      await _loadPersistedMessages();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const gradient = AppColors.studentGradient;
    const accent = AppColors.studentAccent;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.robot,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.discussion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Gemini AI Assistant Aktif',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showMaterials
                  ? PhosphorIconsRegular.filePdf
                  : PhosphorIconsRegular.files,
              color: accent,
            ),
            tooltip: 'Materi Pembelajaran',
            onPressed: () => setState(() => _showMaterials = !_showMaterials),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // ── Top Header Banner & Panel Materials ──────────────────────
              _buildTopBanner(isDark, accent),

              const SizedBox(height: 10),

              // ── Ringkasan Diskusi & Evaluasi Pemahaman AI Card ───────────
              _buildSummaryAndUnderstandingCard(isDark, accent),

              const SizedBox(height: 14),

              // ── MAIN AI CHATBOT PANEL CARD CONTAINER ─────────────────────
              _buildChatbotPanelCard(isDark, accent, gradient),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner(bool isDark, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.info, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.discussion.description.isNotEmpty
                      ? widget.discussion.description
                      : 'Diskusi kelompok interaktif dengan bantuan AI Gemini.',
                  maxLines: _showMaterials ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _showMaterials = !_showMaterials),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${materials.length} Materi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                      Icon(
                        _showMaterials
                            ? PhosphorIconsRegular.caretUp
                            : PhosphorIconsRegular.caretDown,
                        size: 14,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showMaterials && materials.isNotEmpty) ...[
            const Divider(height: 16),
            Column(
              children: materials.map((m) => _buildMaterialTile(m, isDark, accent)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaterialTile(MaterialPdf mat, bool isDark, Color accent) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            mat.type.toLowerCase() == 'pdf'
                ? PhosphorIconsRegular.filePdf
                : PhosphorIconsRegular.fileText,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mat.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              mat.type.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryAndUnderstandingCard(bool isDark, Color accent) {
    final sum = currentSummary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sum != null
              ? accent.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
          width: sum != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.fileText,
                    size: 16,
                    color: accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ringkasan & Evaluasi AI',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => WindowAddSummary(
                      summaries: summaries,
                      chatRoomId: chatRoom.id,
                      userId: studentId ?? '',
                      initialContent: currentSummary?.content,
                    ),
                  );
                  if (!mounted) return;
                  await _loadPersistedSummaries();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sum == null
                            ? PhosphorIconsRegular.plus
                            : PhosphorIconsRegular.pencilSimple,
                        size: 12,
                        color: accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sum == null ? 'Buat Ringkasan' : 'Edit Ringkasan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (sum != null) ...[
            const SizedBox(height: 8),
            Text(
              sum.content,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (understandingResult != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    PhosphorIconsRegular.checkCircle,
                    color: AppColors.success,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tingkat Pemahaman AI: ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Text(
                    understandingResult!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── MAIN CHATBOT PANEL CARD WRAPPER CONTAINER ──────────────────────────
  Widget _buildChatbotPanelCard(
      bool isDark, Color accent, List<Color> gradient) {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── 1. Inner Card Header Bar ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.robot,
                    color: accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Chatbot Assistant',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Tanyakan materi & ajukan diskusi ke AI',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Gemini 2.0 Flash',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Inner Scrollable Message Area ──────────────────────────
          Expanded(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : const Color(0xFFF1F5F9).withValues(alpha: 0.5),
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsRegular.chatsTeardrop,
                            size: 40,
                            color: accent.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Belum ada obrolan.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tanyakan materi pembelajaran pada AI Assistant.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Scrollbar(
                      controller: _chatScrollController,
                      child: ListView.builder(
                        controller: _chatScrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isAi = msg.role == 'ai';
                          final isUser =
                              msg.senderId == studentId || msg.role == 'student';

                          return _buildModernChatBubble(
                              msg, isAi, isUser, isDark, accent);
                        },
                      ),
                    ),
            ),
          ),

          // ── 3. Inner Quick Prompt Chips ──────────────────────────────
          if (messages.length < 5)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: isDark ? AppColors.cardDark : Colors.white,
              child: _buildQuickPromptChips(isDark, accent),
            ),

          // ── 4. Embedded Bottom Input Bar ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan sesuatu pada AI...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isSending ? null : _handleSend,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              PhosphorIconsFill.paperPlaneRight,
                              color: Colors.white,
                              size: 16,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernChatBubble(
      MessageModel msg, bool isAi, bool isUser, bool isDark, Color accent) {
    final senderName = isAi
        ? 'SEA Bot AI'
        : (isUser ? (studentName ?? 'Saya') : 'Anggota');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 6, top: 2),
              decoration: BoxDecoration(
                color: isAi ? AppColors.primary : accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAi
                    ? PhosphorIconsRegular.robot
                    : PhosphorIconsRegular.user,
                color: isAi ? Colors.white : accent,
                size: 14,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser
                    ? accent
                    : (isAi
                        ? (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEFF6FF))
                        : (isDark ? AppColors.cardDark : Colors.white)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 14),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : (isAi
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : (isDark
                              ? AppColors.borderDark
                              : const Color(0xFFE2E8F0))),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          senderName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAi
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                        if (isAi) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    msg.content,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: isUser
                          ? Colors.white
                          : (isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(left: 6, top: 2),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.user,
                color: accent,
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickPromptChips(bool isDark, Color accent) {
    final prompts = [
      'Jelaskan kesimpulan materi',
      'Berikan contoh kasus',
      'Buat kuis singkat',
    ];

    return SizedBox(
      height: 30,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          return InkWell(
            onTap: () {
              _controller.text = prompts[i];
              _handleSend();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.sparkle,
                    size: 11,
                    color: accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    prompts[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}