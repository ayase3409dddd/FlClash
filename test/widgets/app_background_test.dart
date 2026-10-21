import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/app_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _childKey = ValueKey('app_background_child');

// A 1x1 transparent PNG, enough for Image.file to have real bytes to decode.
final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

Widget _app(AppSettingProps setting) {
  return ProviderScope(
    overrides: [appSettingProvider.overrideWithBuild((_, _) => setting)],
    child: const MaterialApp(
      home: AppBackground(child: SizedBox.expand(key: _childKey)),
    ),
  );
}

void main() {
  late Directory tempDirectory;
  late String picturePath;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('app_background_');
    final picture = File('${tempDirectory.path}/background.png');
    await picture.writeAsBytes(_pngBytes);
    picturePath = picture.path;
  });

  tearDown(() async {
    await tempDirectory.delete(recursive: true).then((_) {}, onError: (_) {});
  });

  testWidgets('renders only the child while the background is off', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AppSettingProps(
          backgroundEnabled: false,
          backgroundImagePath: picturePath,
        ),
      ),
    );

    expect(find.byKey(_childKey), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('renders the child when the picture is gone', (tester) async {
    await tester.pumpWidget(
      _app(
        AppSettingProps(
          backgroundEnabled: true,
          backgroundImagePath: '${tempDirectory.path}/missing.png',
          backgroundBlur: 10,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(_childKey), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('draws the picture and its blur behind the child', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AppSettingProps(
          backgroundEnabled: true,
          backgroundImagePath: picturePath,
          backgroundBrightness: 0.5,
          backgroundBlur: 8,
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.cover);
    expect(image.gaplessPlayback, isTrue);
    expect(image.key, ValueKey(picturePath));
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byKey(_childKey), findsOneWidget);
  });

  testWidgets('draws no blur while the blur setting is zero', (tester) async {
    await tester.pumpWidget(
      _app(
        AppSettingProps(
          backgroundEnabled: true,
          backgroundImagePath: picturePath,
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
