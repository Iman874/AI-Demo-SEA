import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';
import 'connection_config_page.dart';
import 'page_choice_user.dart';
import 'page_showcase_cards.dart';
import 'dev/page_showcase_work_quiz.dart';
import '../component/window/window_dev_switch_user.dart';
import 'teacher/page_menu_home_teacher.dart';
import 'student/page_menu_home_student.dart';
import 'student/page_menu_quiz_result_student.dart';
import 'student/page_menu_discussion_chatroom_student.dart';
import 'teacher/page_menu_quiz_result_teacher.dart';
import '../models/discussion_room.dart';

import '../component/window/window_view_list_class.dart';
import '../component/window/window_add_class.dart';
import '../component/window/window_join_class.dart';
import '../component/window/window_add_material.dart';
import '../component/window/window_confirmation.dart';
import '../component/window/window_message.dart';
import '../component/window/window_add_summary.dart';
import '../component/window/window_add_question.dart';
import '../component/window/window_edit_question.dart';
import '../utils/app_notification.dart';
import '../models/question.dart';
import '../models/answer_question.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({super.key});

  @override
  State<PageSettings> createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  bool _isDeveloperMode = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.safeAreaBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section: Tampilan ──
            _SectionTitle(title: 'Tampilan'),
            AppSpacing.hSm,
            _ThemeCard(themeProvider: themeProvider, isDark: isDark),

            AppSpacing.hXxl,

            // ── Section: Koneksi ──
            _SectionTitle(title: 'Koneksi API'),
            AppSpacing.hSm,
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: PhosphorIconsRegular.hardDrives,
                  title: 'Konfigurasi Server',
                  subtitle: 'Ubah host, port, dan skema koneksi',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConnectionConfigPage(
                          onConfigured: () => Navigator.of(context).pop(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            AppSpacing.hXxl,

            // ── Section: Mode Pengembang ──
            _SectionTitle(title: 'Pengembang'),
            AppSpacing.hSm,
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: PhosphorIconsRegular.code,
                  title: 'Mode Pengembang',
                  subtitle: 'Aktifkan pemicu notifikasi & showcase UI pop-up',
                  value: _isDeveloperMode,
                  onChanged: (val) {
                    setState(() => _isDeveloperMode = val);
                  },
                ),
              ],
            ),

            if (_isDeveloperMode) ...[
              AppSpacing.hXxl,
              _SectionTitle(title: 'Uji Notifikasi (Toast / SnackBar)'),
              AppSpacing.hSm,
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: PhosphorIconsRegular.checkCircle,
                    iconColor: const Color(0xFF10B981),
                    title: 'Notifikasi Sukses',
                    subtitle: 'Uji floating snackbar pesan sukses',
                    onTap: () {
                      AppNotification.show(
                        context,
                        'Berhasil! Ini adalah contoh pesan notifikasi sukses.',
                        isError: false,
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.warningCircle,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Notifikasi Gagal / Error',
                    subtitle: 'Uji floating snackbar pesan error',
                    onTap: () {
                      AppNotification.show(
                        context,
                        'Gagal! Terjadi kesalahan sistem pada sampel demo.',
                        isError: true,
                      );
                    },
                  ),
                ],
              ),

              AppSpacing.hXxl,
              _SectionTitle(title: 'Fitur Pengembang & Showcase UI'),
              AppSpacing.hSm,
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: PhosphorIconsRegular.userSwitch,
                    iconColor: AppColors.teacherAccent,
                    title: 'Pindah Akun Instant (Dev Switch User)',
                    subtitle: 'Beralih peran Guru/Siswa seeder backend instan',
                    onTap: () async {
                      final didSwitch = await showDialog<bool>(
                        context: context,
                        builder: (_) => const WindowDevSwitchUser(),
                      );
                      if (didSwitch == true) {
                        if (!context.mounted) return;
                        AppNotification.show(
                          context,
                          'Berhasil beralih akun!',
                          isError: false,
                        );
                        
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final role = auth.user?.role ?? 'student';
                        
                        if (role == 'teacher') {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MenuHomeTeacher()),
                            (route) => false,
                          );
                        } else {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MenuHomeStudent()),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.cards,
                    title: 'Showcase Komponen Card (UI Gallery)',
                    subtitle: 'Uji & lihat galeri seluruh 9 komponen Card',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PageShowcaseCards(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.exam,
                    iconColor: AppColors.studentAccent,
                    title: 'Showcase Pengerjaan Kuis (Siswa)',
                    subtitle: 'Pratinjau tampilan & alur pengerjaan kuis siswa',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PageShowcaseWorkQuiz(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.chartBar,
                    iconColor: AppColors.studentAccent,
                    title: 'Showcase Hasil Kuis (Siswa)',
                    subtitle: 'Pratinjau tampilan evaluasi & pembahasan kuis siswa',
                    onTap: () {
                      final mockQuestions = [
                        Question(
                          idQuestion: 'q1',
                          number: 1,
                          question: 'Manakah dari berikut ini yang merupakan bahasa pemrograman strongly-typed?',
                          poin: 50,
                          fkIdQuiz: 'mock_quiz_id',
                          answerChoices: [
                            AnswerQuestion(idAnswerChoice: 'c1', content: 'JavaScript', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
                            AnswerQuestion(idAnswerChoice: 'c2', content: 'Python', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
                            AnswerQuestion(idAnswerChoice: 'c3', content: 'Dart', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
                            AnswerQuestion(idAnswerChoice: 'c4', content: 'PHP', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
                          ],
                          createAt: DateTime.now(),
                          updateAt: DateTime.now(),
                        ),
                        Question(
                          idQuestion: 'q2',
                          number: 2,
                          question: 'Di Flutter, widget apa yang digunakan untuk membuat layout baris secara horizontal?',
                          poin: 50,
                          fkIdQuiz: 'mock_quiz_id',
                          answerChoices: [
                            AnswerQuestion(idAnswerChoice: 'c5', content: 'Column', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
                            AnswerQuestion(idAnswerChoice: 'c6', content: 'Row', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
                            AnswerQuestion(idAnswerChoice: 'c7', content: 'Stack', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
                            AnswerQuestion(idAnswerChoice: 'c8', content: 'ListView', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
                          ],
                          createAt: DateTime.now(),
                          updateAt: DateTime.now(),
                        ),
                      ];
                      final mockAnswers = {
                        'q1': 'c3', // Benar
                        'q2': 'c5', // Salah
                      };
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PageMenuQuizResultStudent(
                            questions: mockQuestions,
                            answers: mockAnswers,
                            score: 50,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.chartLineUp,
                    iconColor: AppColors.teacherAccent,
                    title: 'Showcase Rekap Nilai Kuis (Guru)',
                    subtitle: 'Pratinjau rekapitulasi nilai kuis kelas guru',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PageMenuQuizResultTeacher(
                            quizId: 'mock_quiz_1',
                            title: 'Kuis Evaluasi Pemrograman Dart',
                            classId: 'mock_class_1',
                          ),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.robot,
                    iconColor: AppColors.studentAccent,
                    title: 'Showcase Chat Room & AI Summary (Siswa)',
                    subtitle: 'Pratinjau ruang obrolan diskusi kelompok & AI assistant',
                    onTap: () {
                      final mockDiscussion = DiscussionRoom(
                        idDiscussionRoom: 'mock_disc_1',
                        title: 'Diskusi Arsitektur Flutter & State Management',
                        description: 'Membahas penggunaan Provider, Riverpod, dan Bloc pada aplikasi skala besar.',
                        tag: 'Pemrograman',
                        status: 'active',
                        createdBy: 'teacher_1',
                        fkIdClass: 'class_1',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        chatroomActive: true,
                        chatroomId: 'mock_chat_1',
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiscussionPageChatRoomStudent(
                            discussion: mockDiscussion,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              AppSpacing.hXxl,
              _SectionTitle(title: 'Showcase Pop-up & Dialog UI'),
              AppSpacing.hSm,
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: PhosphorIconsRegular.plusCircle,
                    title: 'Window Add Class',
                    subtitle: 'Uji dialog buat kelas baru',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => WindowAddClass(onAdd: (c) {}),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.userPlus,
                    title: 'Window Join Class',
                    subtitle: 'Uji dialog gabung kelas dengan kode',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => WindowJoinClass(onJoin: (code) {}),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.filePdf,
                    title: 'Window Add Material',
                    subtitle: 'Uji dialog tambah/upload materi PDF & teks',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const WindowAddMaterial(saveImmediately: false),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.question,
                    title: 'Window Add Question',
                    subtitle: 'Uji dialog tambah butir soal kuis',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => WindowAddQuestion(
                          nextNumber: 1,
                          fkIdQuiz: 'demo',
                          onAdd: (q) {},
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.pencilLine,
                    title: 'Window Edit Question',
                    subtitle: 'Uji dialog edit butir soal kuis',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => WindowEditQuestion(
                          question: Question(
                            idQuestion: 'demo',
                            number: 1,
                            question: 'Berapakah hasil dari 2 + 2?',
                            poin: 10,
                            fkIdQuiz: 'demo',
                            createAt: DateTime.now(),
                            updateAt: DateTime.now(),
                            answerChoices: [
                              AnswerQuestion(
                                idAnswerChoice: '1',
                                content: '4',
                                isCorrect: true,
                                createAt: DateTime.now(),
                                updateAt: DateTime.now(),
                              ),
                              AnswerQuestion(
                                idAnswerChoice: '2',
                                content: '5',
                                isCorrect: false,
                                createAt: DateTime.now(),
                                updateAt: DateTime.now(),
                              ),
                            ],
                          ),
                          onSave: (q) {},
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.sparkle,
                    title: 'Window Add Summary',
                    subtitle: 'Uji dialog simpan ringkasan AI',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const WindowAddSummary(
                          summaries: [],
                          chatRoomId: 'demo',
                          userId: 'demo',
                          initialContent: 'Ringkasan pembelajaran demo AI.',
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.warning,
                    title: 'Window Confirmation',
                    subtitle: 'Uji dialog konfirmasi tindakan',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => WindowConfirmation(
                          message: 'Apakah kamu yakin ingin melanjutkan tindakan demo ini?',
                          onConfirm: () => Navigator.pop(context),
                          onCancel: () => Navigator.pop(context),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.info,
                    title: 'Window Message',
                    subtitle: 'Uji dialog pesan informasi umum',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => WindowMessage(
                          message: 'Ini adalah contoh pesan dialog informasi.',
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: PhosphorIconsRegular.list,
                    title: 'Window View List Class',
                    subtitle: 'Uji dialog daftar semua kelas terdaftar',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const WindowViewListClass(
                          classes: [],
                          isTeacher: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],

            AppSpacing.hXxl,

            // ── Section: Akun ──
            _SectionTitle(title: 'Akun'),
            AppSpacing.hSm,
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: PhosphorIconsRegular.signOut,
                  title: 'Keluar',
                  subtitle: 'Logout dari akun saat ini',
                  iconColor: AppColors.error,
                  titleColor: AppColors.error,
                  onTap: () => _showLogoutDialog(context, auth),
                ),
              ],
            ),

            AppSpacing.hXxl,

            // ── Section: Tentang ──
            _SectionTitle(title: 'Tentang'),
            AppSpacing.hSm,
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: PhosphorIconsRegular.graduationCap,
                  title: 'SEA App',
                  subtitle: 'Smart Education Assistant',
                  onTap: null,
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _SettingsTile(
                  icon: PhosphorIconsRegular.info,
                  title: 'Versi',
                  subtitle: '1.0.2+3',
                  onTap: null,
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _SettingsTile(
                  icon: PhosphorIconsRegular.code,
                  title: 'Framework',
                  subtitle: 'Flutter + Laravel 11 API',
                  onTap: null,
                ),
              ],
            ),

            AppSpacing.hXxl,
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar', style: AppTextStyles.titleLg(ctx)),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun?',
          style: AppTextStyles.bodyMd(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              auth.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ChoiceUserPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widget: Theme Picker Card
// ─────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  final ThemeProvider themeProvider;
  final bool isDark;

  const _ThemeCard({required this.themeProvider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ThemeOption(
            icon: PhosphorIconsRegular.sun,
            title: 'Mode Terang',
            subtitle: 'Gunakan tema terang',
            isSelected: themeProvider.isLight,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
            isDark: isDark,
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          _ThemeOption(
            icon: PhosphorIconsRegular.moon,
            title: 'Mode Gelap',
            subtitle: 'Gunakan tema gelap',
            isSelected: themeProvider.isDark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
            isDark: isDark,
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          _ThemeOption(
            icon: PhosphorIconsRegular.circle,
            title: 'Ikuti Sistem',
            subtitle: 'Sesuaikan dengan pengaturan perangkat',
            isSelected: themeProvider.isSystem,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? accent : Theme.of(context).iconTheme.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMd(context).copyWith(
                      color: isSelected ? accent : null,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm(context),
                  ),
                ],
              ),
            ),
            // Indikator terpilih
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accent : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? accent : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(PhosphorIconsRegular.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widget: Settings Card Container
// ─────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────
// Widget: Settings Tile
// ─────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? defaultIconColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? defaultIconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMd(context).copyWith(
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySm(context)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                PhosphorIconsRegular.caretRight,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widget: Section Title
// ─────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleMd(context).copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widget: Switch Tile
// ─────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: defaultIconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: defaultIconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMd(context),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySm(context)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: defaultIconColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

