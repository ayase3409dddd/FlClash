import 'package:fl_clash/manager/app_manager.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    globalState.appEnv = 'stable';
  });

  Future<void> pump(WidgetTester tester, {required bool safeMode}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [safeModeProvider.overrideWithValue(safeMode)],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: AppEnvManager(child: SizedBox(key: Key('child'))),
        ),
      ),
    );
  }

  testWidgets('a stable build carries no banner', (tester) async {
    await pump(tester, safeMode: false);

    expect(find.byKey(const Key('child')), findsOneWidget);
    expect(find.byType(Banner), findsNothing);
  });

  testWidgets('a safe mode build is bannered on any channel', (tester) async {
    await pump(tester, safeMode: true);

    final banner = tester.widget<Banner>(find.byType(Banner));
    expect(banner.message, 'SAFE MODE');
    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  testWidgets('a pre channel debug build is bannered debug', (tester) async {
    final env = globalState.appEnv;
    globalState.appEnv = 'pre';
    addTearDown(() => globalState.appEnv = env);
    await pump(tester, safeMode: false);

    final banner = tester.widget<Banner>(find.byType(Banner));
    expect(banner.message, 'DEBUG');
    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  test('release builds banner only a dev channel', () {
    expect(
      AppEnvManager.bannerFor(safeMode: true, isDebug: false, appEnv: 'pre'),
      'SAFE MODE',
    );
    expect(
      AppEnvManager.bannerFor(safeMode: false, isDebug: true, appEnv: 'pre'),
      'DEBUG',
    );
    expect(
      AppEnvManager.bannerFor(safeMode: false, isDebug: false, appEnv: 'pre'),
      isNull,
    );
    expect(
      AppEnvManager.bannerFor(
        safeMode: false,
        isDebug: false,
        appEnv: 'stable',
      ),
      isNull,
    );
    expect(
      AppEnvManager.bannerFor(safeMode: false, isDebug: true, appEnv: 'stable'),
      isNull,
    );
    expect(
      AppEnvManager.bannerFor(safeMode: false, isDebug: false, appEnv: 'dev'),
      'DEV',
    );
  });
}
