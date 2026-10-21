import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _TestAppSetting extends AppSetting {
  @override
  AppSettingProps build() => const AppSettingProps();
}

void main() {
  testWidgets('the page turns translucent only for a background picture', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [appSettingProvider.overrideWith(_TestAppSetting.new)],
    );
    addTearDown(container.dispose);
    late ThemeData theme;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, ref, _) {
            theme = watchAppTheme(ref, Brightness.light);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(theme.colorScheme.surface.a, 1.0);
    expect(theme.scaffoldBackgroundColor.a, 1.0);

    container.read(appSettingProvider.notifier).value = const AppSettingProps(
      backgroundEnabled: true,
    );
    await tester.pump();
    // Enabled without a picture paints nothing behind the page.
    expect(theme.scaffoldBackgroundColor.a, 1.0);

    container.read(appSettingProvider.notifier).value = const AppSettingProps(
      backgroundEnabled: true,
      backgroundImagePath: '/background.png',
    );
    await tester.pump();

    expect(theme.colorScheme.surface.a, lessThan(1.0));
    expect(theme.colorScheme.surfaceContainer.a, lessThan(1.0));
    expect(theme.scaffoldBackgroundColor.a, lessThan(1.0));

    container.read(appSettingProvider.notifier).value = const AppSettingProps();
    await tester.pump();

    expect(theme.scaffoldBackgroundColor.a, 1.0);
  });
}
