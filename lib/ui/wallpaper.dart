import 'package:flutter/widgets.dart';

/// Lets page-level surfaces clear their fill while a background picture is
/// shown, so the picture reaches the pages while cards and sheets stay solid.
class Wallpaper extends InheritedWidget {
  const Wallpaper({super.key, required this.visible, required super.child});

  final bool visible;

  static bool visibleOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Wallpaper>()?.visible ?? false;

  @override
  bool updateShouldNotify(Wallpaper oldWidget) => visible != oldWidget.visible;
}
