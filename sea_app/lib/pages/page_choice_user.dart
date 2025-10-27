import 'package:flutter/material.dart';
import 'page_login_user.dart' as login;

// Tambahkan ini di atas _ChoiceCard agar enum UserType selalu tersedia
typedef UserType = login.UserType;

class ChoiceUserPage extends StatefulWidget {
  const ChoiceUserPage({super.key});

  @override
  State<ChoiceUserPage> createState() => _ChoiceUserPageState();
}

class _ChoiceUserPageState extends State<ChoiceUserPage> {
  int selected = 1; // 0: teacher, 1: student

  void _navigateToLogin(UserType userType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => login.LoginUserPage(userType: userType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Teacher
              _ChoiceCard(
                label: "Choose Teacher",
                isSelected: selected == 0,
                icon: _buildTeacherIcon(),
                onTap: () {
                  setState(() => selected = 0);
                  _navigateToLogin(login.UserType.teacher);
                },
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 24),
              // Student
              _ChoiceCard(
                label: "Choose Student",
                isSelected: selected == 1,
                icon: _buildStudentIcon(),
                onTap: () {
                  setState(() => selected = 1);
                  _navigateToLogin(login.UserType.student);
                },
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherIcon() {
    // Gunakan icon asset jika tidak ada di library
    return SizedBox(
      width: 56,
      height: 56,
      child: Image.asset(
        'assets/icon/teacher.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildStudentIcon() {
    // Gunakan icon asset jika tidak ada di library
    return SizedBox(
      width: 56,
      height: 56,
      child: Image.asset(
        'assets/icon/student.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Widget icon;
  final VoidCallback onTap;
  final Color color;

  const _ChoiceCard({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: isSelected
                  ? Border.all(color: color, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: icon),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
