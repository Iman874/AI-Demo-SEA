import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  ModernBottomNavigation  (aliased as BottomNavigation for backward compat)
//
//  Architecture
//  ────────────
//  BottomNavigation  (StatefulWidget)
//   └─ Stack
//       ├─ CustomPaint          ← bar background + animated concave notch
//       ├─ Row (items)          ← icon + label with animated color
//       └─ AnimatedPositioned   ← floating active circle
//           └─ AnimatedContainer  (decoration, shadow)
//               └─ AnimatedSwitcher (icon cross-fade)
//
//  How the "merge" illusion works
//  ──────────────────────────────
//  The bar has a CONCAVE notch (dips down) at the active position.
//  The floating circle (same white color) sits above/inside this notch,
//  partially embedded rather than perfectly centered on the bar's edge.
//  Because both are the same color, and the notch is wider than the
//  circle (it "breathes"), the eye reads a single soft organic shape
//  instead of two mathematically-fitted primitives.
//
//  Notch geometry (v3 — single cubic per side, tuned via interactive
//  playground, values locked in after visual iteration)
//  ──────────────────────────────────────────────────────────────────
//  Circle radius R = 28.
//    • notch half-width = R * 1.89  (R + breathe, breathe = R * 0.89)
//    • cut depth         = R * 0.93
//  Each side is ONE cubic Bézier from the flat edge straight to the
//  notch floor, with horizontal tangents at both ends (curveFrac = 0.5,
//  the max that keeps both control points inside their own half —
//  this is what avoids the seam/kink the old two-curve-per-side
//  version had: no matter how wide "breathe" gets, there's no joint
//  for the eye to catch).
//
//  Corner handling — DELIBERATE trade-off
//  ───────────────────────────────────────
//  The notch is clamped directly to `cornerRadius`, with NO extra
//  buffer gap. On the leftmost/rightmost tabs this means the notch can
//  touch or slightly overlap the rounded corner. This was chosen over
//  adding a safety gap (which compressed/distorted the notch shape on
//  edge tabs) — a small overlap at the very edges reads better than a
//  visibly squashed notch there.
//
//  Key constants
//  ─────────────
//  Bar height   72 px      Corner radius  18 px   (was 24)
//  Circle ⌀     56 px      H margin       16 px (pill floating inside bar)
//  Circle offset −7 px     (was −21 — circle now sits 21px deep / embedded)
//  Animation    300 ms, easeInOut
// ══════════════════════════════════════════════════════════════════════════════

class BottomNavigation extends StatefulWidget {
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
  State<BottomNavigation> createState() => _BottomNavigationState();
}

// ─────────────────────────────────────────────────────────────────────────────

class _BottomNavigationState extends State<BottomNavigation>
    with SingleTickerProviderStateMixin {
  // ── Tab definitions ────────────────────────────────────────────────────────
  static const List<_NavItem> _kTabs = [
    _NavItem(PhosphorIconsRegular.chatsCircle, PhosphorIconsFill.chatsCircle, 'Diskusi'),
    _NavItem(PhosphorIconsRegular.notePencil, PhosphorIconsFill.notePencil, 'Quiz'),
    _NavItem(PhosphorIconsRegular.house, PhosphorIconsFill.house, 'Home'),
    _NavItem(PhosphorIconsRegular.bookOpenText, PhosphorIconsFill.bookOpenText, 'Panduan'),
    _NavItem(PhosphorIconsRegular.gearSix, PhosphorIconsFill.gearSix, 'Setelan'),
  ];

  // ── Geometry ───────────────────────────────────────────────────────────────
  static const double _barH   = 72.0;  // bar height
  static const double _circD  = 56.0;  // circle diameter
  static const double _circR  = _circD / 2; // 28 — also used as notch reference radius
  static const double _embed  = 1.0;  // how far the circle sinks into the bar
  static const double _offset = -(_circR - _embed); // -7 — was -21
  static const double _cr     = 18.0;  // corner radius (was 24)
  static const double _hm     = 16.0;  // horizontal margin (pill inset)

  /// Circle protrudes [_circR] above bar top at most (now less, since embedded).
  /// Widget top = circle top.  Bar top = _circR from widget top.
  static const double _barTop = _circR; // 28 px from widget top

  // ── Animation ──────────────────────────────────────────────────────────────
  /// Drives notch position in CustomPainter (0.0 – 1.0 fraction of pill width)
  late AnimationController _ctrl;
  late Animation<double>   _notchFrac;

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color get _accent =>
      widget.isStudent ? AppColors.studentAccent : AppColors.teacherAccent;

  /// Returns the normalised fraction (0–1) for tab [i] along the pill.
  double _frac(int i) => (i + 0.5) / _kTabs.length;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final f = _frac(widget.currentIndex);
    _notchFrac = Tween<double>(begin: f, end: f).animate(_ctrl);
  }

  @override
  void didUpdateWidget(BottomNavigation old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      // Capture current animated value so there's no jump
      final from = _notchFrac.value;
      final to   = _frac(widget.currentIndex);
      _notchFrac = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      );
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final safeBottom   = MediaQuery.of(context).padding.bottom;
    final extraBottom  = safeBottom > 0 ? safeBottom : 8.0;
    final totalHeight  = _barTop + _barH + extraBottom;

    return SizedBox(
      height: totalHeight,
      // LayoutBuilder provides the real pixel width — no hardcoding.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalW = constraints.maxWidth;
          final pillW  = totalW - _hm * 2; // pill width (inside margins)

          // ── Target circle center X in widget coords ──────────────────
          // Used directly by AnimatedPositioned — it handles its own tween.
          final targetCx = _hm + pillW * _frac(widget.currentIndex);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── 1. Bar background + concave notch (CustomPainter) ─────
              //       AnimatedBuilder re-draws notch on every frame of _ctrl.
              AnimatedBuilder(
                animation: _notchFrac,
                builder: (ctx, _) {
                  // Notch center X in pill-local coordinates
                  final notchCx = pillW * _notchFrac.value;
                  return Positioned(
                    left:   _hm,
                    right:  _hm,
                    top:    _barTop,
                    bottom: 0,
                    child: CustomPaint(
                      painter: _NotchBarPainter(
                        notchCx:      notchCx,
                        circleRadius: _circR,
                        cornerRadius: _cr,
                        color:  isDark ? AppColors.cardDark : Colors.white,
                        isDark: isDark,
                      ),
                    ),
                  );
                },
              ),

              // ── 2. Navigation items row ───────────────────────────────
              Positioned(
                left:   _hm,
                right:  _hm,
                top:    _barTop,
                bottom: 0,
                child: Row(
                  children: [
                    for (var i = 0; i < _kTabs.length; i++)
                      _buildItem(i, isDark),
                  ],
                ),
              ),

              // ── 3. Floating active circle ─────────────────────────────
              //       AnimatedPositioned tweens `left` automatically.
              //       top = _barTop + _offset = _barTop − (R − embed).
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve:    Curves.easeInOut,
                left: targetCx - _circR,
                top:  _barTop + _offset, // = 28 − 7 = 21
                child: _buildCircle(isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Floating circle ────────────────────────────────────────────────────────
  // Outer bounding box stays exactly _circD x _circD (so the AnimatedPositioned
  // math in build() — left: targetCx - _circR — still centers it correctly).
  // The halo ring is painted OUTSIDE that box via a negative-inset Positioned,
  // which is safe because both this Stack and the parent Stack use
  // clipBehavior: Clip.none.
  Widget _buildCircle(bool isDark) {
    return SizedBox(
      width:  _circD,
      height: _circD,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Soft accent halo — a visibly-colored ring (not just a shadow
          // blur) that blends the white circle into the bar's surface,
          // matching the glow seen around the active tab in the reference.
          // Inset of 6px == "halo inset" tuned in the playground.
          Positioned(
            left: -6, right: -6, top: -6, bottom: -6,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve:    Curves.easeInOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.14),
              ),
            ),
          ),
          // AnimatedContainer animates decoration changes (e.g. shadow color on role change).
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve:    Curves.easeInOut,
            width:  _circD,
            height: _circD,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.surfaceDark : Colors.white,
              boxShadow: [
                // Single soft Material-3-style shadow. Previously two
                // layered shadows (blur 18/alpha .32 + blur 8/alpha .10)
                // read as heavy; one gentle shadow reads as "premium".
                BoxShadow(
                  color:      Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                // Faint accent tint kept, greatly reduced, purely for warmth.
                BoxShadow(
                  color:      _accent.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            // AnimatedSwitcher cross-fades the icon when active tab changes.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: 0.60, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
              child: Icon(
                _kTabs[widget.currentIndex].activeIcon,
                key:   ValueKey(widget.currentIndex), // triggers switcher
                color: _accent,
                size:  24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Individual nav item (icon + label) ─────────────────────────────────────
  Widget _buildItem(int index, bool isDark) {
    final isActive = index == widget.currentIndex;
    final tab      = _kTabs[index];
    final inactive = isDark ? const Color(0xFF6B7A8D) : const Color(0xFF9AA5B4);

    return Expanded(
      child: GestureDetector(
        onTap:     () => widget.onTap(index),
        behavior:  HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Icon fades out when active (its counterpart lives in the circle).
            // Animate icon color via opacity (active = transparent, shown in circle).
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve:    Curves.easeInOut,
              opacity:  isActive ? 0.0 : 1.0,
              child: Icon(tab.icon, color: inactive, size: 18),
            ),
            // Extra breathing room under the circle for the ACTIVE label only,
            // so it doesn't feel cramped right beneath the floating circle.
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve:    Curves.easeInOut,
              height: isActive ? 7.0 : 3.0,
            ),
            // Animate label color and weight.
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve:    Curves.easeInOut,
              style: TextStyle(
                fontSize:    9.5,
                fontWeight:  isActive ? FontWeight.w700 : FontWeight.w400,
                color:       isActive ? _accent : inactive,
                letterSpacing: isActive ? 0.2 : 0,
              ),
              child: Text(tab.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  _NavItem — immutable tab data holder
// ══════════════════════════════════════════════════════════════════════════════

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

// ══════════════════════════════════════════════════════════════════════════════
//  _NotchBarPainter
//
//  Draws the pill-shaped navigation bar with a smooth, "breathing" concave
//  notch at [notchCx]. Each side is a SINGLE cubic Bézier — no seam, no
//  kink — from the flat top edge straight down to the notch floor at
//  (notchCx, depth), with horizontal tangents at both ends.
//
//  Notch algorithm (pill-local coordinates, origin = top-left of pill):
//  ─────────────────────────────────────────────────────────────────────
//    • cut depth        = R * 0.93
//    • notch half-width = R * 1.89   (R + breathe, breathe = R * 0.89 —
//                                      wide enough that the bar visibly
//                                      "breathes" around the floating
//                                      circle instead of hugging it)
//    • curveFrac        = 0.5        (the cap that keeps both control
//                                      points inside their own half of
//                                      the curve — never crosses over,
//                                      so it can't self-intersect no
//                                      matter how wide the notch is)
//
//  Corner handling — clamp only, no buffer gap
//  ─────────────────────────────────────────────
//  The notch's outer edge is clamped to `cornerRadius` directly. When
//  the active tab sits at the far left/right, this can make the notch
//  touch or slightly overlap the rounded corner — an accepted trade-off,
//  chosen over adding a safety buffer that visibly compressed/distorted
//  the notch shape on those edge tabs.
// ══════════════════════════════════════════════════════════════════════════════

class _NotchBarPainter extends CustomPainter {
  /// Notch center X in pill-local coordinates.
  final double notchCx;
  final double circleRadius;  // = 28
  final double cornerRadius;  // = 18
  final Color  color;
  final bool   isDark;

  const _NotchBarPainter({
    required this.notchCx,
    required this.circleRadius,
    required this.cornerRadius,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    // ── Wide soft shadow (ambient elevation, barely-there) ─────────────
    canvas.drawPath(
      path,
      Paint()
        ..color      = Colors.black.withValues(alpha: isDark ? 0.18 : 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // ── Tight contact shadow ────────────────────────────────────────────
    // Without this, the bar's silhouette (the notch wave) is nearly
    // unreadable against a light page background — the wide blur above
    // is too diffuse to trace an edge. This shorter, slightly stronger
    // shadow hugs the shape closely so the eye can actually follow the
    // wave, regardless of what's behind the bar.
    canvas.drawPath(
      path,
      Paint()
        ..color      = Colors.black.withValues(alpha: isDark ? 0.22 : 0.09)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // ── Bar fill ──────────────────────────────────────────────────────
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);

    // ── Traced outline ──────────────────────────────────────────────────
    // A hairline stroke that follows the exact notch path. This is what
    // actually makes the notch legible on a white-on-white layout —
    // shadows alone can't guarantee enough contrast on every background,
    // but a drawn edge always reads.
    canvas.drawPath(
      path,
      Paint()
        ..color       = isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.07)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  Path _buildPath(Size size) {
    final w  = size.width;
    final h  = size.height;
    final cr = cornerRadius < h / 2 ? cornerRadius : h / 2;
    final R  = circleRadius; // 28
    final cx = notchCx < 0 ? 0.0 : notchCx > w ? w : notchCx;

    // ── Notch geometry (single cubic per side) ─────────────────────────
    final double breathe    = R * 0.89;     // notch half-width extra
    final double notchHalfW = R + breathe;  // ~52.9px
    final double depth      = R * 0.93;     // cut depth
    const double curveFrac  = 0.5;          // capped ≤ 0.5, see class doc

    final rawOuterL = cx - notchHalfW;
    final rawOuterR = cx + notchHalfW;

    // Clamp directly to the corner radius — no extra buffer (deliberate;
    // see class doc). Then clamp to cx itself so spans never go negative.
    double outerL = rawOuterL < cr ? cr : rawOuterL;
    double outerR = rawOuterR > w - cr ? w - cr : rawOuterR;
    outerL = outerL > cx ? cx : outerL;
    outerR = outerR < cx ? cx : outerR;

    final spanL = (cx - outerL) < 0 ? 0.0 : (cx - outerL);
    final spanR = (outerR - cx) < 0 ? 0.0 : (outerR - cx);

    final path = Path();

    // 1. Start after top-left corner, flat edge out to the notch's start
    path.moveTo(cr, 0);
    if (outerL > cr) path.lineTo(outerL, 0);

    // 2. Left notch arm: single cubic from (outerL, 0) to (cx, depth).
    //    Both control points sit at the horizontal midpoint of the span
    //    (curveFrac = 0.5), which is what gives the smooth, seamless
    //    "S" transition — no matter how wide the span, they never cross.
    if (spanL > 0) {
      final c1x = outerL + spanL * curveFrac;
      final c2x = cx     - spanL * curveFrac;
      path.cubicTo(c1x, 0, c2x, depth, cx, depth);
    } else {
      // Notch center flush against the corner — go straight to depth.
      path.lineTo(cx, depth);
    }

    // 3. Right notch arm: mirror of step 2.
    if (spanR > 0) {
      final c1x = cx     + spanR * curveFrac;
      final c2x = outerR - spanR * curveFrac;
      path.cubicTo(c1x, depth, c2x, 0, outerR, 0);
    } else {
      path.lineTo(outerR, 0);
    }

    // 4. Flat edge → top-right corner
    if (outerR < w - cr) path.lineTo(w - cr, 0);
    path.arcToPoint(Offset(w, cr), radius: Radius.circular(cr));

    // 5. Right side → bottom (flat, unchanged) → left side
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.lineTo(0, cr);

    // 6. Top-left rounded corner arc
    path.arcToPoint(Offset(cr, 0), radius: Radius.circular(cr));

    path.close();
    return path;
  }

  // Only repaint when notch moves or theme changes.
  @override
  bool shouldRepaint(_NotchBarPainter old) =>
      old.notchCx != notchCx ||
      old.color   != color   ||
      old.isDark  != isDark;
}