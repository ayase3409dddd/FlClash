import 'dart:io';

import 'package:fl_clash/common/catgirl_localizations.dart';
import 'package:fl_clash/common/catgirl_text.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _kaomoji = ['(ฅ^•ﻌ•^ฅ)', '(｡•ω•｡)'];

const _longChinese = '这是一段比较长的说明文字，用来测试猫娘化之后的效果。';

bool _hasEmoji(String text) {
  return text.runes.any(
    (rune) =>
        (rune >= 0x1F000 && rune <= 0x1FAFF) ||
        (rune >= 0x2600 && rune <= 0x27BF) ||
        (rune >= 0xFE00 && rune <= 0xFE0F),
  );
}

void main() {
  group('catgirlize', () {
    test('rewrites Chinese sentences and labels', () {
      expect(catgirlize('设置', 'zh_CN'), '设置喵');
      expect(catgirlize('设置', 'zh'), '设置喵');
      expect(catgirlize('操作成功。', 'zh_CN'), '操作成功喵～');
      expect(catgirlize('出错了！', 'zh_CN'), '出错了喵！');
      expect(catgirlize('确定要删除吗？', 'zh_CN'), '确定要删除吗喵？');
      expect(catgirlize('当前没有可用的配置文件', 'zh_CN'), '当前没有可用的配置文件喵～');
    });

    test('adds one kaomoji to long Chinese copy, never an emoji', () {
      final rewritten = catgirlize(_longChinese, 'zh_CN');
      final body = _longChinese.substring(0, _longChinese.length - 1);
      expect(rewritten.startsWith('$body喵～ '), isTrue);
      expect(_kaomoji.any(rewritten.endsWith), isTrue);
      for (final sample in ['设置喵', '操作成功喵～', rewritten, 'Settings nya~']) {
        expect(_hasEmoji(sample), isFalse, reason: sample);
      }
    });

    test('never stacks a second suffix', () {
      final label = catgirlize('设置', 'zh_CN');
      expect(catgirlize(label, 'zh_CN'), label);
      final sentence = catgirlize(_longChinese, 'zh_CN');
      expect(catgirlize(sentence, 'zh_CN'), sentence);
      expect(catgirlize('Settings nya~', 'en'), 'Settings nya~');
      expect(catgirlize('好耶～', 'zh_CN'), '好耶～');
      expect(catgirlize('Hello~', 'en'), 'Hello~');
      expect(catgirlize('設定にゃ〜', 'ja'), '設定にゃ〜');
    });

    test('keeps data tokens untouched', () {
      const tokens = [
        '100%',
        '24',
        'ms',
        'dB',
        'IPv6',
        'TUN',
        'https://example.com/a?b=1',
        'cat@example.com',
        '—',
      ];
      for (final token in tokens) {
        expect(catgirlize(token, 'zh_CN'), token, reason: token);
        expect(catgirlize(token, 'en'), token, reason: token);
      }
    });

    test('keeps fragments of a larger line untouched', () {
      expect(catgirlize('Connectivity: ', 'en'), 'Connectivity: ');
      expect(catgirlize(' entries', 'en'), ' entries');
    });

    test('applies the other locale endings', () {
      expect(catgirlize('設定', 'ja'), '設定にゃ〜');
      expect(catgirlize('完了。', 'ja'), '完了にゃ〜');
      expect(catgirlize('失敗！', 'ja'), '失敗にゃ！');
      expect(catgirlize('설정', 'ko'), '설정냥~');
      expect(catgirlize('Настройки', 'ru'), 'Настройки ня~');
      expect(catgirlize('Settings', 'en'), 'Settings nya~');
      expect(catgirlize('Done.', 'en'), 'Done nya~');
      expect(catgirlize('Are you sure?', 'en'), 'Are you sure nya?');
    });

    test('keeps a non-empty string non-empty', () {
      for (final (text, locale) in const [
        ('', 'zh_CN'),
        (' ', 'zh_CN'),
        ('。', 'zh_CN'),
        ('a', 'en'),
      ]) {
        final rewritten = catgirlize(text, locale);
        expect(rewritten.isEmpty, text.isEmpty, reason: text);
      }
    });
  });

  group('CatgirlLocalizationsDelegate', () {
    tearDown(() => AppLocalizations.load(const Locale('en')));

    test('is supported exactly where the base delegate is', () {
      const delegate = CatgirlLocalizationsDelegate(enabled: true);
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('zh', 'CN')), isTrue);
      expect(delegate.isSupported(const Locale('de')), isFalse);
    });

    test('shouldReload follows the enabled flag', () {
      const on = CatgirlLocalizationsDelegate(enabled: true);
      const off = CatgirlLocalizationsDelegate();
      expect(on.shouldReload(off), isTrue);
      expect(off.shouldReload(on), isTrue);
      expect(on.shouldReload(on), isFalse);
      expect(off.shouldReload(off), isFalse);
    });

    test('disabled load returns the plain localizations', () async {
      const delegate = CatgirlLocalizationsDelegate();
      final loaded = await delegate.load(const Locale('zh', 'CN'));
      expect(loaded, isNot(isA<CatgirlAppLocalizations>()));
      expect(identical(loaded, AppLocalizations.current), isTrue);
      expect(loaded.settings, '设置');
    });

    test('enabled load wraps while keeping localeName and base', () async {
      const delegate = CatgirlLocalizationsDelegate(enabled: true);
      final loaded = await delegate.load(const Locale('zh', 'CN'));
      expect(loaded, isA<CatgirlAppLocalizations>());
      final wrapper = loaded as CatgirlAppLocalizations;
      expect(wrapper.localeName, 'zh_CN');
      expect(identical(wrapper.base, AppLocalizations.current), isTrue);
      expect(wrapper.base.settings, '设置');
      expect(wrapper.settings, catgirlize('设置', 'zh_CN'));
      expect(
        wrapper.secondsCount(30),
        catgirlize(wrapper.base.secondsCount(30), 'zh_CN'),
      );
      expect(
        wrapper.emptyTip('名称'),
        catgirlize(wrapper.base.emptyTip('名称'), 'zh_CN'),
      );
    });
  });

  test('generated overrides cover every base accessor', () {
    final source = File('lib/l10n/l10n.dart').readAsStringSync();
    final generated = File(
      'lib/common/generated/catgirl_localizations.g.dart',
    ).readAsStringSync();
    final lines = source.split('\n');
    final start = lines.indexWhere(
      (line) => line.trim() == 'class AppLocalizations {',
    );
    expect(start, isNot(-1));
    final end = lines.indexWhere((line) => line == '}', start + 1);
    final getter = RegExp(r'^  String get ([A-Za-z_][A-Za-z0-9_]*)');
    final method = RegExp(r'^  String ([A-Za-z_][A-Za-z0-9_]*)\([^)]*\)');
    final accessors = <String>[];
    for (final line in lines.sublist(start + 1, end)) {
      final name = getter.firstMatch(line)?[1] ?? method.firstMatch(line)?[1];
      if (name != null) accessors.add(name);
    }
    expect(accessors, isNotEmpty);
    for (final name in accessors) {
      expect(
        generated.contains(RegExp('base\\.$name[,(]')),
        isTrue,
        reason: name,
      );
    }
  });
}
