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

class PageSettings extends StatelessWidget {
  const PageSettings({super.key});

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
