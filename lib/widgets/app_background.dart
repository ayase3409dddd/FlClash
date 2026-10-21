import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:fl_clash/providers/config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxDimStrength = 0.85;
const _maxBlurSigma = 30.0;

/// Paints the picture set in the theme settings behind [child].
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
    // Dimming and blur without a picture only darken the app.
    if (!image.existsSync()) {
      return child;
    }
    final dim = clampDouble(setting.brightness, 0, 1) * _maxDimStrength;
    final blur = clampDouble(setting.blur, 0, _maxBlurSigma);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          image,
          key: ValueKey(path),
          fit: BoxFit.cover,
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
