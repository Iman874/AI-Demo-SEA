import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../theme/app_colors.dart';

class WindowDevSwitchUser extends StatefulWidget {
  const WindowDevSwitchUser({super.key});

  @override
  State<WindowDevSwitchUser> createState() => _WindowDevSwitchUserState();
}

class _WindowDevSwitchUserState extends State<WindowDevSwitchUser> {
  bool _loading = false;
  String? _selectedEmail;

  final List<Map<String, String>> _demoAccounts = [
    {
      'name': 'Budi Santoso, M.Pd',
      'role': 'teacher',
      'roleLabel': 'Guru Demo',
      'email': 'guru@demo.com',
      'password': 'password123',
      'token': 'dev-token-guru-demo-12345',
    },
    {
      'name': 'Ani Wijaya',
      'role': 'student',
      'roleLabel': 'Siswa Demo 1',
      'email': 'siswa1@demo.com',
      'password': 'password123',
      'token': 'dev-token-siswa1-demo-12345',
    },
    {
      'name': 'Budi Pratama',
      'role': 'student',
      'roleLabel': 'Siswa Demo 2',
      'email': 'siswa2@demo.com',
      'password': 'password123',
      'token': 'dev-token-siswa2-demo-12345',
    },
    {
      'name': 'Citra Dewi',
      'role': 'student',
      'roleLabel': 'Siswa Demo 3',
      'email': 'siswa3@demo.com',
      'password': 'password123',
      'token': 'dev-token-siswa3-demo-12345',
    },
  ];

  Future<void> _switchAccount(Map<String, String> acc) async {
    setState(() {
      _loading = true;
      _selectedEmail = acc['email'];
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Coba login via API terlebih dahulu
    final ok = await auth.login(email: acc['email']!, password: acc['password']!);

    if (!ok) {
      // Fallback offline login untuk Dev Mode jika API backend belum nyala
      final fallbackUser = User(
        id: 'user_dev_${acc['email']}',
        name: acc['name']!,
        email: acc['email']!,
        role: acc['role']!,
      );
      await auth.setDevModeUser(fallbackUser, acc['token']!);
    }

    if (mounted) {
      setState(() => _loading = false);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentAuth = Provider.of<AuthProvider>(context);
    final currentUserEmail = currentAuth.user?.email;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.teacherAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.userSwitch,
                    color: AppColors.teacherAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pindah Akun (Dev Mode)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih akun seeder backend untuk langsung masuk',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Accounts List
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: _demoAccounts.map((acc) {
                    final isCurrent = currentUserEmail == acc['email'];
                    final isTeacher = acc['role'] == 'teacher';
                    final isThisLoading = _loading && _selectedEmail == acc['email'];

                    final badgeColor = isTeacher ? AppColors.teacherAccent : AppColors.studentAccent;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: isThisLoading ? null : () => _switchAccount(acc),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? badgeColor.withValues(alpha: isDark ? 0.20 : 0.10)
                                : (isDark ? AppColors.backgroundDark : Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCurrent
                                  ? badgeColor
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: badgeColor.withValues(alpha: 0.15),
                                child: Icon(
                                  isTeacher ? PhosphorIconsRegular.userSquare : PhosphorIconsRegular.student,
                                  color: badgeColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          acc['name']!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: badgeColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            acc['roleLabel']!,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: badgeColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      acc['email']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isThisLoading)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else if (isCurrent)
                                Icon(Icons.check_circle_rounded, color: badgeColor, size: 22)
                              else
                                const Icon(Icons.chevron_right_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
