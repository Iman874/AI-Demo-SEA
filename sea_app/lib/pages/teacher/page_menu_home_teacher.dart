import 'package:flutter/material.dart';
import '../../component/nav/bottom_navigation.dart';
import '../../component/header/top.dart';
import '../../component/card/card_class.dart';
import '../../component/card/card_discussion.dart';
import '../../models/class.dart';
import '../../models/discussion_room.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'page_menu_discussion_teacher.dart';
import 'page_menu_quiz_teacher.dart';
import '../page_guide.dart';
import '../../theme/light_theme.dart';
import 'page_menu_discussion_editor_teacher.dart';
import '../../component/window/window_add_class.dart';
import 'page_menu_discussion_details_teacher.dart';

class MenuHomeTeacher extends StatefulWidget {
  const MenuHomeTeacher({super.key});

  @override
  State<MenuHomeTeacher> createState() => _MenuHomeTeacherState();
}

class _MenuHomeTeacherState extends State<MenuHomeTeacher> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    "Home",
    "Discussion Room",
    "Quiz",
    "Guide",
  ];

  final List<Widget> _pages = [
    _HomeTeacherContent(),
    PageMenuDiscussionTeacher(),
    PageMenuQuizTeacher(),
    const PageGuide(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopHeader(
              title: _titles[_currentIndex],
              backgroundColor: backgroundColorTeacher,
            ),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        isStudent: false,
      ),
    );
  }
}

class _HomeTeacherContent extends StatefulWidget {
  @override
  State<_HomeTeacherContent> createState() => _HomeTeacherContentState();
}

class _HomeTeacherContentState extends State<_HomeTeacherContent> {
  bool _loading = true;
  String? _error;
  List<ClassModel> _classes = [];
  List<DiscussionRoom> _discussions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final classesResp = await ApiService.getClasses();
      if (classesResp.statusCode == 200) {
        final body = jsonDecode(classesResp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _classes = items.map((e) => ClassModelJson.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load classes (${classesResp.statusCode})');
      }

      final discResp = await ApiService.getDiscussions();
      if (discResp.statusCode == 200) {
        final body = jsonDecode(discResp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _discussions = items.map((e) => DiscussionRoomJson.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load discussions (${discResp.statusCode})');
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

  final active = _discussions.where((d) => d.status == 'open').toList();
  final completed = _discussions.where((d) => d.status == 'closed').toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                'Class',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            CardClassList(classes: _classes),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    // local add for UI; backend create endpoint not implemented
                    await showDialog(
                      context: context,
                      builder: (context) => WindowAddClass(
                        onAdd: (newClass) {
                          setState(() {
                            _classes.add(newClass);
                          });
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Create Class',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                'Recent Discussions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            CardDiscussionList(
              discussions: [...active, ...completed],
              onEdit: (d) {
                // only active discussions should reach this handler (CardDiscussionList shows Edit only for status == 'open')
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
              },
              onDetails: (d) {
                // For closed discussions, open the details view
                if (d.status == 'closed') {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionDetailsTeacher(discussionId: d.idDiscussionRoom)));
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PageMenuDiscussionEditorTeacher(),
                        ),
                      );
                  },
                  child: Text(
                    'Start Discussion',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
