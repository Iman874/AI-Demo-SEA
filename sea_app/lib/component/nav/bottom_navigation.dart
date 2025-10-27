import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isStudent;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isStudent,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icon/nav/home.png',
            width: 28,
            height: 28,
            color: currentIndex == 0 ? const Color(0xFF1B3C53) : const Color(0xFF819DB1),
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icon/nav/discussion.png',
            width: 28,
            height: 28,
            color: currentIndex == 1 ? const Color(0xFF1B3C53) : const Color(0xFF819DB1),
          ),
          label: "Discussion Room",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icon/nav/quiz.png',
            width: 28,
            height: 28,
            color: currentIndex == 2 ? const Color(0xFF1B3C53) : const Color(0xFF819DB1),
          ),
          label: "Quiz",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icon/nav/guide.png',
            width: 28,
            height: 28,
            color: currentIndex == 3 ? const Color(0xFF1B3C53) : const Color(0xFF819DB1),
          ),
          label: "Guide",
        ),
      ],
      selectedItemColor: const Color(0xFF1B3C53),
      unselectedItemColor: const Color(0xFF819DB1),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}
