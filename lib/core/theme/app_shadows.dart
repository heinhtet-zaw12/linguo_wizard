import 'package:flutter/material.dart';

/// Elevation system with themed shadows.
class AppShadows {
  AppShadows._();

  /// Level 1: Resting cards
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 2: Focused cards
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 3: Modals
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  /// Accent glow on CTAs
  static const List<BoxShadow> glowBlue = [
    BoxShadow(
      color: Color(0x4D6366F1),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];

  /// Cyan glow on badges
  static const List<BoxShadow> glowCyan = [
    BoxShadow(
      color: Color(0x4022D3EE),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];
}
