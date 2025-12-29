import 'package:flutter/services.dart';

class Haptics {
  static void light() {
    HapticFeedback.lightImpact();
  }
}
