import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // ── Scale ──
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double xXxl = xxl;

  // ── Convention ──
  static const double horizontalPadding = xl;
  static const double sectionSpacing = xxl;
  static const double cardPadding = lg;
  static const double cardSpacing = md;
  static const double safeAreaBottom = 100;

  // ── Edge Insets helpers ──
  static EdgeInsets get allXs => EdgeInsets.all(xs);
  static EdgeInsets get allSm => EdgeInsets.all(sm);
  static EdgeInsets get allMd => EdgeInsets.all(md);
  static EdgeInsets get allLg => EdgeInsets.all(lg);
  static EdgeInsets get allXl => EdgeInsets.all(xl);

  static EdgeInsets get horzSm => EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get horzMd => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get horzLg => EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get horzXl => EdgeInsets.symmetric(horizontal: xl);

  static EdgeInsets get vertSm => EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get vertMd => EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get vertLg => EdgeInsets.symmetric(vertical: lg);

  static EdgeInsets get page =>
      EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: md);

  // ── SizedBox helpers ──
  static Widget get hXs => SizedBox(height: xs);
  static Widget get hSm => SizedBox(height: sm);
  static Widget get hMd => SizedBox(height: md);
  static Widget get hLg => SizedBox(height: lg);
  static Widget get hXl => SizedBox(height: xl);
  static Widget get hXxl => SizedBox(height: xxl);
  static Widget get hXxxl => SizedBox(height: xxxl);

  static Widget get wXs => SizedBox(width: xs);
  static Widget get wSm => SizedBox(width: sm);
  static Widget get wMd => SizedBox(width: md);
  static Widget get wLg => SizedBox(width: lg);
  static Widget get wXl => SizedBox(width: xl);

  static Widget get hHuge => SizedBox(height: huge);
}
