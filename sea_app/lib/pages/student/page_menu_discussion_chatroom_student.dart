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

  List<MessageModel> messages = [];
  List<MaterialPdf> materials = [];
  List<SummaryDiscussion> summaries = [];
  String? understandingResult;
  bool _isSending = false;
  bool _showMaterials = false;
  bool _showProgressCard = false;

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

  Future<void> _handleSend([String? customText]) async {
    final text = customText ?? _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    if (customText != null) {
      _controller.text = customText;
    }

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
    const accent = AppColors.studentAccent;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ── Top Background Glow Gradient ───────────────────────────────
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.15 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top Header Navigation Bar ───────────────────────────────
                _buildTopAppBar(isDark, accent),

                // ── Sub-Header Floating Bar (Left Progress Icon & Right Student Summary Button)
                _buildSubHeaderFloatingActions(isDark, accent),

                // ── Main Scrollable Body Content ────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Column(
                      children: [
                        // Collapsible Progress Card (Opens when Left Progress Icon is tapped)
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _showProgressCard
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Column(
                            children: [
                              _buildProgressMateriCard(isDark, accent),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),

                        // Card Utama: Main AI Chatbot Assistant Container
                        _buildMainChatbotContainer(isDark, accent),

                        const SizedBox(height: 80), // Extra space for floating input
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Floating Input Bar ────────────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildFloatingInputBar(isDark, accent),
          ),
        ],
      ),
    );
  }

  // ── Top Navigation Bar Widget ───────────────────────────────────────────
  Widget _buildTopAppBar(bool isDark, Color accent) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (canPop)
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  PhosphorIconsRegular.arrowLeft,
                  size: 20,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ),
          if (canPop) const SizedBox(width: 10),

          // Discussion Briefcase Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.studentGradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              PhosphorIconsRegular.briefcase,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Title & Subtitle
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.discussion.tag.isNotEmpty
                            ? widget.discussion.tag
                            : 'Provider & State Management',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'AI Aktif',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Toggle Materials PDF Button Icon Top Right
          InkWell(
            onTap: () => setState(() => _showMaterials = !_showMaterials),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.fileText,
                    color: accent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${materials.length}',
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
    );
  }

  // ── Sub-Header Floating Action Bar (Left Progress Icon & Right Student Summary Button)
  Widget _buildSubHeaderFloatingActions(bool isDark, Color accent) {
    final total = materials.isNotEmpty ? materials.length : 12;
    final done = messages.isNotEmpty ? (messages.length > total ? total : (messages.length ~/ 2)) : 0;
    final sum = currentSummary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 📙 Floating Icon Progress Materi (Sebelah Kiri)
              InkWell(
                onTap: () =>
                    setState(() => _showProgressCard = !_showProgressCard),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _showProgressCard
                        ? const Color(0xFFEA580C)
                        : (isDark
                            ? const Color(0xFF431407)
                            : const Color(0xFFFFF7ED)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFDBA74).withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.bookOpen,
                        size: 15,
                        color: _showProgressCard
                            ? Colors.white
                            : const Color(0xFFEA580C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Progress ($done/$total)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _showProgressCard
                              ? Colors.white
                              : const Color(0xFFEA580C),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showProgressCard
                            ? PhosphorIconsRegular.caretUp
                            : PhosphorIconsRegular.caretDown,
                        size: 12,
                        color: _showProgressCard
                            ? Colors.white
                            : const Color(0xFFEA580C),
                      ),
                    ],
                  ),
                ),
              ),

              // ✏️ Floating Tombol Ringkasan Siswa (Sebelah Kanan - Lebih di Atas!)
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
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9333EA), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        PhosphorIconsRegular.pencilSimple,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sum != null ? 'Edit Evaluasi Saya' : '+ Isi Evaluasi Saya',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_showMaterials && materials.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: materials
                    .map((m) => Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(PhosphorIconsRegular.filePdf,
                                  color: Color(0xFFEA580C), size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  m.title,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Card Progress Materi (Ditampilkan saat Icon Progress Kiri Ditekan) ─────
  Widget _buildProgressMateriCard(bool isDark, Color accent) {
    final total = materials.isNotEmpty ? materials.length : 12;
    final done = messages.isNotEmpty ? (messages.length > total ? total : (messages.length ~/ 2)) : 0;
    final progress = total > 0 ? (done / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              PhosphorIconsRegular.bookOpen,
              color: Color(0xFFEA580C),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Materi Pembelajaran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  done == 0
                      ? 'Belum ada materi yang dibahas'
                      : '$done dari $total materi telah dibahas',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFF1F5F9),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$done ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                    TextSpan(
                      text: '/ $total',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Materi selesai',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card Utama: Main AI Chatbot Container ──────────────────────────────────
  Widget _buildMainChatbotContainer(bool isDark, Color accent) {
    final sum = currentSummary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Inside Chatbot Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.robot,
                    color: Color(0xFFEA580C),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'AI Chatbot Assistant',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Gemini 2.0 Flash',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
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
              ],
            ),
          ),

          // Optional Student Evaluation Summary Banner inside Chatbot Panel (if student filled it)
          if (sum != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF).withValues(alpha: isDark ? 0.2 : 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD8B4FE).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.pencilSimple,
                      size: 14, color: Color(0xFF9333EA)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evaluasi Siswa: ${sum.content}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (understandingResult != null)
                          Text(
                            'Tingkat Pemahaman AI: $understandingResult',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),
          if (messages.isEmpty)
            _buildEmptyStateContent(isDark, accent)
          else
            _buildMessageListContent(isDark, accent),
        ],
      ),
    );
  }

  // ── Empty State View matching Reference ─────────────────────────────────
  Widget _buildEmptyStateContent(bool isDark, Color accent) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        PhosphorIconsRegular.robot,
                        size: 52,
                        color: const Color(0xFFEA580C).withValues(alpha: 0.8),
                      ),
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(PhosphorIconsRegular.bookOpen,
                                  size: 10, color: Color(0xFFEA580C)),
                              SizedBox(width: 4),
                              Text(
                                'SEA AI',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada percakapan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mulai diskusi mengenai materi untuk mendapatkan bantuan AI yang lebih personal.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletItem(
                          PhosphorIconsRegular.bookOpen,
                          'Menjelaskan konsep dengan mudah',
                          const Color(0xFFEA580C),
                          const Color(0xFFFFF7ED),
                          isDark),
                      const SizedBox(height: 4),
                      _buildBulletItem(
                          PhosphorIconsRegular.lightbulb,
                          'Memberikan contoh & studi kasus',
                          const Color(0xFFD97706),
                          const Color(0xFFFEF3C7),
                          isDark),
                      const SizedBox(height: 4),
                      _buildBulletItem(
                          PhosphorIconsRegular.clipboardText,
                          'Membuat latihan & evaluasi',
                          const Color(0xFFEA580C),
                          const Color(0xFFFFF7ED),
                          isDark),
                      const SizedBox(height: 4),
                      _buildBulletItem(
                          PhosphorIconsRegular.question,
                          'Menjawab pertanyaan Anda',
                          const Color(0xFFD97706),
                          const Color(0xFFFEF3C7),
                          isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Mulai dengan quick action',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: PhosphorIconsRegular.fileText,
                  iconColor: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                  title: 'Ringkas Materi',
                  subtitle: 'Dapatkan ringkasan materi ini',
                  prompt: 'Tolong buatkan ringkasan dari materi pembelajaran ini.',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildQuickActionCard(
                  icon: PhosphorIconsRegular.lightbulb,
                  iconColor: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                  title: 'Berikan Contoh',
                  subtitle: 'Minta contoh nyata atau studi kasus',
                  prompt: 'Berikan contoh nyata dan studi kasus terkait materi ini.',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildQuickActionCard(
                  icon: PhosphorIconsRegular.brain,
                  iconColor: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                  title: 'Buat Latihan',
                  subtitle: 'Buat soal latihan atau kuis',
                  prompt: 'Buatkan 3 soal latihan singkat untuk menguji pemahaman saya.',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildQuickActionCard(
                  icon: PhosphorIconsRegular.question,
                  iconColor: const Color(0xFF9333EA),
                  bgColor: const Color(0xFFF3E8FF),
                  title: 'Jelaskan Konsep',
                  subtitle: 'Minta penjelasan konsep tertentu',
                  prompt: 'Tolong jelaskan konsep utama dari materi ini secara rinci.',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(IconData icon, String text, Color iconColor,
      Color bgCircle, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: bgCircle,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 10, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String prompt,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _handleSend(prompt),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Message Stream View ──────────────────────────────────────────────────
  Widget _buildMessageListContent(bool isDark, Color accent) {
    return Container(
      height: 380,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: ListView.builder(
        controller: _chatScrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isAi = msg.role == 'ai';
          final isUser = msg.senderId == studentId || msg.role == 'student';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
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
                      color: isAi
                          ? const Color(0xFFEA580C)
                          : accent.withValues(alpha: 0.2),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFEA580C)
                          : (isAi
                              ? (isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFFFF7ED))
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
                                ? const Color(0xFFFDBA74).withValues(alpha: 0.4)
                                : (isDark
                                    ? AppColors.borderDark
                                    : const Color(0xFFE2E8F0))),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Text(
                            isAi ? 'SEA Bot AI' : 'Member',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                          const SizedBox(height: 2),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFFED7AA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.user,
                      color: Color(0xFFEA580C),
                      size: 14,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Bottom Floating Input Bar Widget ─────────────────────────────────────
  Widget _buildFloatingInputBar(bool isDark, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          const Icon(
            PhosphorIconsRegular.sparkle,
            size: 18,
            color: Color(0xFFCBD5E1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Tanyakan sesuatu pada AI...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.microphone,
                color: Color(0xFF64748B),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: _isSending ? null : () => _handleSend(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.studentGradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
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
                        size: 18,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}