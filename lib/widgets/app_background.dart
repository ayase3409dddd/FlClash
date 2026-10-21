import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxDimStrength = 0.85;
const _maxBlurSigma = 30.0;

BoxFit _fitOf(BackgroundFitMode mode) => switch (mode) {
  BackgroundFitMode.fill => BoxFit.cover,
  BackgroundFitMode.stretch => BoxFit.fill,
  BackgroundFitMode.fit => BoxFit.contain,
};

/// Paints the picture set in the theme settings behind [child].
///
/// Page surfaces clear their fill through [Wallpaper], so the picture shows
/// through them in one layer rather than through stacked translucent fills.
class AppBackground extends ConsumerWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(
      appSettingProvider.select(
        (state) => (
          enabled: state.backgroundEnabled,
          path: state.backgroundImagePath,
          fit: state.backgroundFitMode,
          brightness: state.backgroundBrightness,
          blur: state.backgroundBlur,
        ),
      ),
    );
    final path = setting.path;
    if (!setting.enabled || path == null || path.isEmpty) {
      return child;
    }
    final image = File(path);
    final scheme = Theme.of(context).colorScheme;
    if (!image.existsSync()) {
      // Keep a missing picture from opening a hole to the window behind the
      // app while the pages clear their fill.
      return Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: scheme.surface),
          child,
        ],
      );
    }
    final dim = clampDouble(setting.brightness, 0, 1) * _maxDimStrength;
    final blur = clampDouble(setting.blur, 0, _maxBlurSigma);
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: scheme.surface),
        Image.file(
          image,
          key: ValueKey(path),
          fit: _fitOf(setting.fit),
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
        ColoredBox(color: Colors.black.withValues(alpha: dim)),
        if (blur > 0)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: const SizedBox.expand(),
            ),
          ),
        child,
      ],
    );
  }
}
