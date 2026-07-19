import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import '../../models/discussion_room.dart';
import '../../models/discussion_question.dart';
import '../../models/summary_discussion.dart';
import '../../models/result_understanding.dart';
import '../../component/card/card_answer_question_student.dart';
import '../../component/card/card_conclusion_student.dart';
import '../../component/card/card_percentage_understanding.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_spacing.dart';

class PageMenuDiscussionDetailsTeacher extends StatefulWidget {
  final String discussionId;
  const PageMenuDiscussionDetailsTeacher({super.key, required this.discussionId});

  @override
  State<PageMenuDiscussionDetailsTeacher> createState() => _PageMenuDiscussionDetailsTeacherState();
}

class _PageMenuDiscussionDetailsTeacherState extends State<PageMenuDiscussionDetailsTeacher> {
  DiscussionRoom? _discussion;
  List<DiscussionQuestion> _questions = [];
  List<SummaryDiscussion> _summaries = [];
  List<ResultUnderstanding> _understandings = [];
  bool _loading = true;
  String? _error;
  String? _className;
  int? _groupCount;
  int? _perGroup;
  int _pUnderstood = 0;
  int _pNotFully = 0;
  int _pNot = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dResp = await ApiService.getDiscussion(widget.discussionId);

      String? resolvedChatId;
      if (dResp.statusCode == 200) {
        final body = jsonDecode(dResp.body);
        final disc = body['data']?['discussion'];

        if (disc != null) {
          _discussion = DiscussionRoomJson.fromJson(disc as Map<String, dynamic>);

          try {
            final numGVal = disc['numGroups'] ?? disc['num_groups'];
            final perGVal = disc['studentsPerGroup'] ?? disc['students_per_group'];
            if (numGVal != null) {
              try {
                _groupCount = int.tryParse(numGVal.toString());
              } catch (_) {}
            }
            if (perGVal != null) {
              try {
                _perGroup = int.tryParse(perGVal.toString());
              } catch (_) {}
            }
          } catch (_) {}

          if (_groupCount == null || _perGroup == null) {
            try {
              final tag = (_discussion?.tag ?? '').toString();
              final nums = RegExp(r"(\d+)").allMatches(tag).map((m) => int.tryParse(m.group(0) ?? '')).where((e) => e != null).map((e) => e!).toList();
              if (nums.isNotEmpty) {
                _groupCount = nums.isNotEmpty ? nums[0] : null;
                _perGroup = nums.length > 1 ? nums[1] : null;
              }
            } catch (_) {}
          }

          try {
            resolvedChatId = (disc['chatroomId']?.toString()) ?? ((disc['chatroom'] != null) ? (disc['chatroom']['id_chatroomai']?.toString() ?? disc['chatroom']['id']?.toString()) : null);
          } catch (_) {}
        }
      }

      final chatId = resolvedChatId ?? _discussion?.chatroomId;
      if (chatId != null) {
        final qResp = await ApiService.getDiscussionQuestions(chatroomId: chatId);
        if (qResp.statusCode == 200) {
          final qb = jsonDecode(qResp.body);
          final items = (qb['data'] as List<dynamic>?) ?? [];
          _questions = items.map((e) => DiscussionQuestion.fromJson(e as Map<String, dynamic>)).toList();
        }

        final sResp = await ApiService.getDiscussionSummariesDb(chatroomId: chatId);
        if (sResp.statusCode == 200) {
          final sb = jsonDecode(sResp.body);
          final items = (sb['data'] as List<dynamic>?) ?? [];
          _summaries = items.map((e) => SummaryDiscussion.fromJson(e as Map<String, dynamic>)).toList();
        }
      }

      final uResp = await ApiService.getDiscussionUnderstandings(discussionId: widget.discussionId);
      if (uResp.statusCode == 200) {
        final ub = jsonDecode(uResp.body);
        final items = (ub['data'] as List<dynamic>?) ?? [];
        _understandings = items.map((e) => ResultUnderstanding.fromJson(e as Map<String, dynamic>)).toList();
        _computeUnderstandingStats();
      }

      if (_discussion != null && _discussion!.fkIdClass.isNotEmpty) {
        try {
          final cResp = await ApiService.getClasses();
          if (cResp.statusCode == 200) {
            final cb = jsonDecode(cResp.body);
            final clist = (cb['data'] as List<dynamic>?) ?? [];
            final found = clist.cast<Map<String, dynamic>>().firstWhere(
              (m) => (m['idClass']?.toString() ?? m['id']?.toString() ?? '') == _discussion!.fkIdClass,
              orElse: () => {},
            );
            if (found.isNotEmpty) {
              _className = (found['name'] ?? found['title'] ?? '')?.toString();
            }
          }
        } catch (_) {}
      }

      _computeUnderstandingStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _computeUnderstandingStats() {
    final total = _understandings.length;
    int u = 0, nf = 0, n = 0;
    for (final item in _understandings) {
      final t = item.type.toLowerCase();
      if (t.contains('not fully') || t.contains('partial') || t.contains('not_fully')) {
        nf++;
      } else if (t.contains('not') || t.contains('notunderstood') || t.contains('not_understood')) {
        n++;
      } else if (t.contains('understand') || t.contains('understood')) {
        u++;
      } else {
        nf++;
      }
    }
    if (total > 0) {
      _pUnderstood = ((u / total) * 100).round();
      _pNotFully = ((nf / total) * 100).round();
      _pNot = ((n / total) * 100).round();
    } else {
      _pUnderstood = 0;
      _pNotFully = 0;
      _pNot = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.teacherGradient))),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.chatsCircle, size: 22),
              SizedBox(width: 10),
              Text('Detail Diskusi'),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.teacherGradient))),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.chatsCircle, size: 22),
              SizedBox(width: 10),
              Text('Detail Diskusi'),
            ],
          ),
        ),
        body: Center(
          child: Padding(
            padding: AppSpacing.allLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsRegular.warningCircle, size: 64, color: isDark ? Colors.white38 : Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('Error: $_error', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      );
    }

    if (_discussion == null) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.teacherGradient))),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.chatsCircle, size: 22),
              SizedBox(width: 10),
              Text('Detail Diskusi'),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.chatsTeardrop, size: 64, color: isDark ? Colors.white38 : Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Diskusi tidak ditemukan', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.teacherGradient))),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.chatsCircle, size: 22),
            SizedBox(width: 10),
            Text('Detail Diskusi'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(context, isDark),
              AppSpacing.hXxl,
              _sectionHeader(context, 'Pertanyaan & Jawaban', PhosphorIconsRegular.question, isDark),
              AppSpacing.hSm,
              CardAnswerQuestionStudent(questions: _questions),
              AppSpacing.hXxl,
              _sectionHeader(context, 'Kesimpulan Siswa', PhosphorIconsRegular.pencilLine, isDark),
              AppSpacing.hSm,
              CardConclusionStudent(summaries: _summaries),
              AppSpacing.hXxl,
              _sectionHeader(context, 'Hasil Pemahaman', PhosphorIconsRegular.chartBar, isDark),
              AppSpacing.hSm,
              CardPercentageUnderstanding(items: _understandings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.titleMedium),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    final classLabel = _className ?? (_discussion!.fkIdClass.isNotEmpty ? 'Kelas ${_discussion!.fkIdClass}' : 'Tidak ada data');
    final name = _discussion!.title.isNotEmpty ? _discussion!.title : 'Diskusi';
    final groupCountStr = _groupCount != null ? '$_groupCount' : '—';
    final perGroupStr = _perGroup != null ? '$_perGroup' : '—';

    return Container(
      decoration: AppDecorations.elevatedCard(context),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(PhosphorIconsFill.chatsCircle, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text('Info Ruang Diskusi', style: AppTextStyles.titleMedium),
            ],
          ),
          const Divider(height: 24),
          _infoRow('Kelas', PhosphorIconsRegular.graduationCap, classLabel, isDark),
          AppSpacing.hMd,
          _infoRow('Nama Diskusi', PhosphorIconsRegular.chatsCircle, name, isDark),
          AppSpacing.hMd,
          _infoRow('Kelompok', PhosphorIconsRegular.users, '$groupCountStr grup · $perGroupStr per grup', isDark),
          AppSpacing.hLg,
          Text('Tingkat Pemahaman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : Colors.grey.shade600)),
          AppSpacing.hSm,
          _buildUnderstandingBar(isDark),
        ],
      ),
    );
  }

  Widget _infoRow(String label, IconData icon, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: isDark ? Colors.white54 : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : Colors.grey.shade500)),
          ],
        ),
        AppSpacing.hXs,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildUnderstandingBar(bool isDark) {
    final total = _pUnderstood + _pNotFully + _pNot;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.chartBar, size: 16, color: isDark ? Colors.white38 : Colors.grey.shade400),
              const SizedBox(width: 8),
              Text('Belum ada data pemahaman', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Center(child: Text('$_pUnderstood%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.green.shade600)))),
            Expanded(child: Center(child: Text('$_pNotFully%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.orange.shade700)))),
            Expanded(child: Center(child: Text('$_pNot%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.red.shade600)))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(flex: _pUnderstood, child: Container(height: 10, decoration: BoxDecoration(color: Colors.green.shade400, borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),),)),
            if (_pNotFully > 0) Expanded(flex: _pNotFully, child: Container(height: 10, color: Colors.orange.shade400)),
            if (_pNot > 0) Expanded(flex: _pNot, child: Container(height: 10, decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),),)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Paham', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Colors.green.shade600)),
            Text('Sebagian', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Colors.orange.shade700)),
            Text('Tidak Paham', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Colors.red.shade600)),
          ],
        ),
      ],
    );
  }
}
