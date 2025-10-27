import 'package:flutter/material.dart';
import '../../component/card/card_discussion.dart';
import '../../models/discussion_room.dart';
import '../../models/class.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'page_menu_discussion_detail_student.dart';

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
  if (_loading) return const Center(child: CircularProgressIndicator());
  if (_error != null) return Center(child: Text('Error: $_error'));

  // Filter diskusi sesuai kelas yang dipilih
  // Only show active discussions that also have an AI chatroom active
  final activeDiscussions = _discussions.where((d) => d.status == "open" && d.chatroomActive == true).toList();
  final completedDiscussions = _discussions.where((d) => d.status == "closed").toList();

    final hasClass = studentClasses.isNotEmpty;
    final dropdownValue = hasClass && studentClasses.any((c) => c.idClass == selectedClassId)
        ? selectedClassId
        : (hasClass ? studentClasses.first.idClass : null);

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
                  "Select Class",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // gunakan warna dari theme
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      borderRadius: BorderRadius.circular(14),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                      hint: const Text("No class available"),
                    ),
                  ),
                ),
              ),
              // Active Discussions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Text(
                  "Active Discussions",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              CardDiscussionList(
                discussions: activeDiscussions,
                onViewDetails: (d) async {
                  // navigate to discussion detail page for student; chatroom is accessed from there
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiscussionDetailStudentPage(discussion: d)));
                  if (!mounted) return;
                  // reload discussions after return (in case materials/summary changed)
                  await _loadDiscussions();
                },
                buttonLabel: "Join Discussion",
              ),
              // Completed Discussions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Text(
                  "Completed Discussions",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              CardDiscussionList(
                discussions: completedDiscussions,
                onViewDetails: (d) {
                  // View details (open discussion detail page)
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiscussionDetailStudentPage(discussion: d)));
                },
                buttonLabel: "View Details",
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}