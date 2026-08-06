import 'package:flutter/material.dart';

/// Spacing scale (4px base unit).
class AppSpacing {
  AppSpacing._();

  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;

  // Convenience EdgeInsets
  static const EdgeInsets all1 = EdgeInsets.all(s1);
  static const EdgeInsets all2 = EdgeInsets.all(s2);
  static const EdgeInsets all3 = EdgeInsets.all(s3);
  static const EdgeInsets all4 = EdgeInsets.all(s4);
  static const EdgeInsets all5 = EdgeInsets.all(s5);
  static const EdgeInsets all6 = EdgeInsets.all(s6);

  static const EdgeInsets horizontal2 = EdgeInsets.symmetric(horizontal: s2);
  static const EdgeInsets horizontal3 = EdgeInsets.symmetric(horizontal: s3);
  static const EdgeInsets horizontal4 = EdgeInsets.symmetric(horizontal: s4);
  static const EdgeInsets horizontal5 = EdgeInsets.symmetric(horizontal: s5);
  static const EdgeInsets horizontal6 = EdgeInsets.symmetric(horizontal: s6);
  static const EdgeInsets horizontal8 = EdgeInsets.symmetric(horizontal: s8);
  static const EdgeInsets horizontal10 = EdgeInsets.symmetric(horizontal: s10);

  static const EdgeInsets vertical2 = EdgeInsets.symmetric(vertical: s2);
  static const EdgeInsets vertical3 = EdgeInsets.symmetric(vertical: s3);
  static const EdgeInsets vertical4 = EdgeInsets.symmetric(vertical: s4);
  static const EdgeInsets vertical5 = EdgeInsets.symmetric(vertical: s5);
}

/// Border radius tokens.
class AppRadius {
  AppRadius._();

  static const BorderRadius xxs = BorderRadius.all(Radius.circular(2));
  static const BorderRadius xs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius sm6 = BorderRadius.all(Radius.circular(6));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius md10 = BorderRadius.all(Radius.circular(10));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(20));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(24));
  static const BorderRadius xxl28 = BorderRadius.all(Radius.circular(28));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(9999));

  // Legacy aliases
  static const BorderRadius sm12 = sm; // 12px → AppRadius.sm

  // Mixed radii (for message bubbles with tail effect)
  static const BorderRadius bubbleUser = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
    bottomLeft: Radius.circular(24),
    bottomRight: Radius.circular(4),
  );

  static const BorderRadius bubbleAi = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
    bottomLeft: Radius.circular(4),
    bottomRight: Radius.circular(24),
  );
}

/// Sizing tokens.
class AppSizing {
  AppSizing._();

  static const double buttonHeight = 52;
  static const double buttonHeightSm = 40;
  static const double inputHeight = 48;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double avatarSm = 36;
  static const double avatarMd = 48;
  static const double avatarLg = 72;
  static const double micButtonSize = 72;
  static const double chipHeight = 36;
  static const double navBarHeight = 80;
}
