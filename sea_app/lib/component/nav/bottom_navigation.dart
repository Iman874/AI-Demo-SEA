import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_colors.dart';

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

  /// Warna aksen berdasarkan role
  Color _accentColor() =>
      isStudent ? AppColors.studentAccent : AppColors.teacherAccent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 72,
          padding: EdgeInsets.only(
            top: 8,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: PhosphorIconsRegular.house,
                  activeIcon: PhosphorIconsFill.house,
                  label: 'Home',
                  index: 0,
                  currentIndex: currentIndex,
                  accentColor: _accentColor(),
                  isDark: isDark,
                  onTap: onTap,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: PhosphorIconsRegular.chatsCircle,
                  activeIcon: PhosphorIconsFill.chatsCircle,
                  label: 'Diskusi',
                  index: 1,
                  currentIndex: currentIndex,
                  accentColor: _accentColor(),
                  isDark: isDark,
                  onTap: onTap,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: PhosphorIconsRegular.notePencil,
                  activeIcon: PhosphorIconsFill.notePencil,
                  label: 'Quiz',
                  index: 2,
                  currentIndex: currentIndex,
                  accentColor: _accentColor(),
                  isDark: isDark,
                  onTap: onTap,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: PhosphorIconsRegular.bookOpenText,
                  activeIcon: PhosphorIconsFill.bookOpenText,
                  label: 'Panduan',
                  index: 3,
                  currentIndex: currentIndex,
                  accentColor: _accentColor(),
                  isDark: isDark,
                  onTap: onTap,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: PhosphorIconsRegular.gearSix,
                  activeIcon: PhosphorIconsFill.gearSix,
                  label: 'Setelan',
                  index: 4,
                  currentIndex: currentIndex,
                  accentColor: _accentColor(),
                  isDark: isDark,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final Color accentColor;
  final bool isDark;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    final unselectedColor = isDark
        ? const Color(0xFF6B7A8D)
        : const Color(0xFF8B95A7);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 12 : 4,
            vertical: isSelected ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: accentColor.withValues(alpha: 0.25), width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? accentColor : unselectedColor,
                  size: 18,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? accentColor : unselectedColor,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
