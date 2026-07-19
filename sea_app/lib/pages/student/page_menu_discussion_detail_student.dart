import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../models/discussion_room.dart';
import '../../models/material.dart';
import '../../models/class.dart';
import '../../services/api_service.dart';
import 'page_menu_discussion_chatroom_student.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_spacing.dart';
import '../../component/state/skeleton_loading.dart';

class DiscussionDetailStudentPage extends StatefulWidget {
  final DiscussionRoom discussion;
  const DiscussionDetailStudentPage({super.key, required this.discussion});

  @override
  State<DiscussionDetailStudentPage> createState() => _DiscussionDetailStudentPageState();
}

class _DiscussionDetailStudentPageState extends State<DiscussionDetailStudentPage> {
  List<MaterialPdf> materials = [];
  bool _loading = false;
  bool _loadingClass = false;
  bool _loadingMembers = false;
  List<Map<String, dynamic>> _members = [];
  String? _className;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
    _loadClassName();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;
      final resp = await ApiService.getDiscussionMembers(
        discussionId: widget.discussion.idDiscussionRoom,
        userId: userId,
      );
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        _members = list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingMembers = false);
    }
  }

  Future<void> _loadClassName() async {
    setState(() => _loadingClass = true);
    try {
      final resp = await ApiService.getClasses();
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        final classes = list.map((c) => ClassModelJson.fromJson(c as Map<String, dynamic>)).toList();
        final match = classes.firstWhere(
          (c) => (c.idClass == widget.discussion.fkIdClass) || (c.codeClass == widget.discussion.fkIdClass),
          orElse: () => ClassModelJson.fromJson(<String, dynamic>{}),
        );
        _className = (match.idClass.isNotEmpty) ? match.name : null;
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingClass = false);
    }
  }

  Future<void> _loadMaterials() async {
    setState(() => _loading = true);
    try {
      final resp = await ApiService.getMaterialsForDiscussion(discussionId: widget.discussion.idDiscussionRoom);
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        materials = list.map((m) => MaterialPdfJson.fromJson(m as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInitialLoading = _loading || _loadingClass || _loadingMembers;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.studentGradient))),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.chatsCircle, size: 22),
            SizedBox(width: 10),
            Text('Detail Diskusi'),
          ],
        ),
      ),
      body: isInitialLoading
          ? const SkeletonDiscussionDetailContent()
          : SingleChildScrollView(
              padding: AppSpacing.allLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(context, isDark),
                  AppSpacing.hLg,
                  _buildMembersSection(context, isDark),
                  AppSpacing.hLg,
                  _buildMaterialsSection(context, isDark),
                  AppSpacing.hXl,
                  _buildAiButton(context, isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
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
          _infoRow('Kelas', PhosphorIconsRegular.graduationCap, _className ?? widget.discussion.fkIdClass, isDark, _loadingClass),
          AppSpacing.hMd,
          _infoRow('Nama Diskusi', PhosphorIconsRegular.chatsCircle, widget.discussion.title, isDark, false),
          AppSpacing.hMd,
          _infoRow('ID Diskusi', PhosphorIconsRegular.identificationCard, widget.discussion.idDiscussionRoom, isDark, false),
        ],
      ),
    );
  }

  Widget _infoRow(String label, IconData icon, String value, bool isDark, bool loading) {
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
          child: Row(
            children: [
              Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
              if (loading) const SizedBox(width: 8),
              if (loading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection(BuildContext context, bool isDark) {
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
                child: const Icon(PhosphorIconsRegular.users, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text('Anggota Diskusi', style: AppTextStyles.titleMedium),
              const Spacer(),
              Text('${_members.length}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade500)),
            ],
          ),
          const Divider(height: 20),
          if (_loadingMembers)
            const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
          if (!_loadingMembers && _members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsRegular.userMinus, size: 16, color: isDark ? Colors.white38 : Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text('Belum ada anggota', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13)),
                  ],
                ),
              ),
            ),
          if (!_loadingMembers && _members.isNotEmpty)
            ..._members.map((m) => _buildMemberTile(m, isDark)),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                (member['name']?.toString() ?? '?')[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member['name'] ?? 'Unknown', style: AppTextStyles.bodyMedium),
                if (member['email'] != null)
                  Text(member['email'], style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(BuildContext context, bool isDark) {
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
                child: const Icon(PhosphorIconsRegular.fileText, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text('Materi Diskusi', style: AppTextStyles.titleMedium),
              const Spacer(),
              Text('${materials.length}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade500)),
            ],
          ),
          const Divider(height: 20),
          if (_loading)
            const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
          if (!_loading && materials.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsRegular.fileX, size: 16, color: isDark ? Colors.white38 : Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text('Belum ada materi', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13)),
                  ],
                ),
              ),
            ),
          if (!_loading && materials.isNotEmpty)
            ...materials.map((m) => _buildMaterialTile(m, isDark)),
        ],
      ),
    );
  }

  Widget _buildMaterialTile(MaterialPdf material, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(PhosphorIconsRegular.filePdf, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(material.title, style: AppTextStyles.bodyMedium),
                ),
                Icon(PhosphorIconsRegular.eye, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiscussionPageChatRoomStudent(discussion: widget.discussion)));
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.studentGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(PhosphorIconsRegular.sparkle, size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Tanya AI tentang Materi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 8),
              const Icon(PhosphorIconsRegular.arrowRight, size: 18, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
