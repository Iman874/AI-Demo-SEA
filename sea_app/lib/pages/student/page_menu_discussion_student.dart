import 'package:flutter/material.dart';
import '../../component/card/card_discussion.dart';
import '../../models/discussion_room.dart';
import '../../models/class.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'page_menu_discussion_detail_student.dart';
import '../../component/state/skeleton_loading.dart';

class PageMenuDiscussionStudent extends StatefulWidget {
  const PageMenuDiscussionStudent({super.key});

  @override
  State<PageMenuDiscussionStudent> createState() => _PageMenuDiscussionStudentState();
}

class _PageMenuDiscussionStudentState extends State<PageMenuDiscussionStudent> {
  late List<ClassModel> studentClasses;
  late String selectedClassId;
  // removed local/all-classes cache; we fetch classes as needed from API
  List<DiscussionRoom> _discussions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Ambil kelas yang diikuti oleh studentUser (handled in _loadAll)
    studentClasses = [];
    selectedClassId = '';
    _loadAll();
    // register listener after first frame to avoid context issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.addListener(_authListener);
    });
  }

  void _authListener() {
    // reload classes when auth signals change
    if (mounted) _loadAll();
  }

  @override
  void dispose() {
    // remove listener
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      auth.removeListener(_authListener);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Prefer explicit user_id API call (server-side user_class) to ensure we return classes related to the student
      String? userId = auth.user?.id;
      final idResp = await ApiService.getUserClassIds(token: auth.token, userId: userId);
      if (idResp.statusCode == 200) {
        final idBody = jsonDecode(idResp.body);
        final ids = ((idBody['data'] as List<dynamic>?) ?? []).map((e) => e.toString()).toSet();
        if (ids.isNotEmpty) {
          final classesResp = await ApiService.getClasses();
          if (classesResp.statusCode == 200) {
            final clsBody = jsonDecode(classesResp.body);
            final itemsAll = clsBody['data'] as List<dynamic>? ?? [];
            final all = itemsAll.map((e) => ClassModelJson.fromJson(e as Map<String, dynamic>)).toList();
            studentClasses = all.where((c) => ids.contains(c.idClass)).toList();
            selectedClassId = studentClasses.isNotEmpty ? studentClasses.first.idClass : '';
            if (selectedClassId.isNotEmpty) await _loadDiscussions();
          }
        } else {
          // no classes for this user
          studentClasses = [];
          selectedClassId = '';
        }
      } else {
        // failed to fetch ids: clear
        studentClasses = [];
        selectedClassId = '';
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadDiscussions() async {
    if (selectedClassId.isEmpty) return;
    try {
      final resp = await ApiService.getDiscussions(classId: selectedClassId);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _discussions = items.map((e) => DiscussionRoomJson.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SkeletonListContent();
  if (_error != null) return Center(child: Text('Error: $_error'));

  // Filter diskusi sesuai kelas yang dipilih
  // Only show active discussions that also have an AI chatroom active
  final activeDiscussions = _discussions.where((d) => d.status == "open" && d.chatroomActive == true).toList();
  final completedDiscussions = _discussions.where((d) => d.status == "closed").toList();

    final hasClass = studentClasses.isNotEmpty;
    final dropdownValue = hasClass && studentClasses.any((c) => c.idClass == selectedClassId)
        ? selectedClassId
        : (hasClass ? studentClasses.first.idClass : null);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown kelas yang diikuti student
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(
                  "Pilih Kelas",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.school_rounded,
                          color: isDark ? Colors.white38 : const Color(0xFF64748B),
                        ),
                      ),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      items: hasClass
                          ? studentClasses.map((c) {
                              return DropdownMenuItem(
                                value: c.idClass,
                                child: Text(c.name),
                              );
                            }).toList()
                          : [],
                      onChanged: hasClass
                          ? (val) async {
                              if (val != null) {
                                setState(() => selectedClassId = val);
                                await _loadDiscussions();
                              }
                            }
                          : null,
                      hint: const Text("Tidak ada kelas tersedia", style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Active Discussions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Text(
                  "Diskusi Aktif",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              CardDiscussionList(
                discussions: activeDiscussions,
                onViewDetails: (d) async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiscussionDetailStudentPage(discussion: d)));
                  if (!mounted) return;
                  await _loadDiscussions();
                },
                buttonLabel: "Masuk Diskusi",
              ),
              const SizedBox(height: 12),

              // Completed Discussions
              if (completedDiscussions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  child: Text(
                    "Riwayat Diskusi Selesai",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                CardDiscussionList(
                  discussions: completedDiscussions,
                  onViewDetails: (d) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiscussionDetailStudentPage(discussion: d)));
                  },
                  buttonLabel: "Detail Diskusi",
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}