import 'package:flutter/material.dart';

/// Global theme controller. Use [ThemeController.instance] everywhere.
/// Call [toggle()] from ProfileScreen's dark-mode switch.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.dark);

  static final ThemeController instance = ThemeController._();

  bool get isDark => value == ThemeMode.dark;

  void toggle() {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  void setDark() => value = ThemeMode.dark;
  void setLight() => value = ThemeMode.light;
}
