import 'package:flutter/services.dart';

class Haptic {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void selection() => HapticFeedback.selectionClick();
}
