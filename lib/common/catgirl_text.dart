final class _CatgirlTone {
  const _CatgirlTone({
    required this.joiner,
    required this.end,
    required this.exclamation,
    required this.question,
  });

  final String joiner;

  final String end;

  final String exclamation;

  final String question;
}

const _jaTone = _CatgirlTone(
  joiner: '',
  end: 'にゃ〜',
  exclamation: 'にゃ！',
  question: 'にゃ？',
);

const _koTone = _CatgirlTone(
  joiner: '',
  end: '냥~',
  exclamation: '냥!',
  question: '냥?',
);

const _ruTone = _CatgirlTone(
  joiner: ' ',
  end: 'ня~',
  exclamation: 'ня!',
  question: 'ня?',
);

const _latinTone = _CatgirlTone(
  joiner: ' ',
  end: 'nya~',
  exclamation: 'nya!',
  question: 'nya?',
);

/// Kaomoji added to long Chinese copy. Emoji are not allowed here.
const _zhKaomoji = ['(ฅ^•ﻌ•^ฅ)', '(｡•ω•｡)'];

const _zhSentenceLength = 10;

const _zhKaomojiLength = 20;

const _tokensKeptAsIs = {
  '%',
  'ms',
  'dB',
  'MB',
  'GB',
  'KB',
  'TB',
  'B',
  'MB/s',
  'KB/s',
  'seconds',
  'minutes',
  'hours',
  'days',
  'IPv4',
  'IPv6',
  'IP',
  'URL',
  'URLs',
  'API',
  'TUN',
  'VPN',
  'N/A',
};

final _letterPattern = RegExp(
  r'[A-Za-z\u00C0-\u024F\u0400-\u04FF\u3040-\u30FF\u4E00-\u9FFF\uAC00-\uD7AF]',
);

final _catgirlMarkPattern = RegExp(
  r'(?:喵|にゃ|냥|ня|nya)?[~〜～]$|(?:喵|にゃ|냥|ня|nya)$',
  caseSensitive: false,
);

final _urlPattern = RegExp(r'^(?:[A-Za-z][A-Za-z0-9+.\-]*://|www\.)\S+$');

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

final _domainPattern = RegExp(
  r'^(?:[A-Za-z0-9](?:[A-Za-z0-9\-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$',
);

final _acronymPattern = RegExp(r'^[A-Z][A-Z0-9]*(?:[-_/][A-Z0-9]+)*$');

/// Copy that ends in a separator is a fragment of a larger line, not a line.
final _fragmentEndingPattern = RegExp(r'[:：/>（(—–\-]$');

enum _CatgirlLanguage { zh, ja, ko, ru, latin }

/// Rewrites [text] in the catgirl style of [locale].
///
/// Data-only tokens, fragments of a larger line and copy that already ends in
/// an ending are returned unchanged, so at most one ending is ever added.
String catgirlize(String text, String locale) {
  if (text.isEmpty) return text;
  final trimmed = text.trim();
  if (trimmed.isEmpty) return text;
  if (trimmed != text) return text;
  if (_isKeptAsIs(trimmed)) return text;
  return switch (_languageOf(locale)) {
    _CatgirlLanguage.zh => _catgirlizeZh(trimmed),
    _CatgirlLanguage.ja => _catgirlizeTone(trimmed, _jaTone),
    _CatgirlLanguage.ko => _catgirlizeTone(trimmed, _koTone),
    _CatgirlLanguage.ru => _catgirlizeTone(trimmed, _ruTone),
    _CatgirlLanguage.latin => _catgirlizeTone(trimmed, _latinTone),
  };
}

bool _isKeptAsIs(String text) {
  if (_fragmentEndingPattern.hasMatch(text)) return true;
  if (_catgirlMarkPattern.hasMatch(text)) return true;
  if (_zhKaomoji.any(text.endsWith)) return true;
  if (text.runes.length <= 1) return true;
  if (_tokensKeptAsIs.contains(text)) return true;
  if (!_letterPattern.hasMatch(text)) return true;
  if (_urlPattern.hasMatch(text)) return true;
  if (_emailPattern.hasMatch(text)) return true;
  if (_domainPattern.hasMatch(text)) return true;
  if (_acronymPattern.hasMatch(text)) return true;
  return false;
}

_CatgirlLanguage _languageOf(String locale) {
  final code = locale.replaceAll('-', '_').split('_').first.toLowerCase();
  return switch (code) {
    'zh' => _CatgirlLanguage.zh,
    'ja' => _CatgirlLanguage.ja,
    'ko' => _CatgirlLanguage.ko,
    'ru' => _CatgirlLanguage.ru,
    _ => _CatgirlLanguage.latin,
  };
}

String _catgirlizeZh(String text) {
  final body = text.substring(0, text.length - 1);
  final marked = switch (text[text.length - 1]) {
    '。' => '$body喵～',
    '！' => '$body喵！',
    '？' => '$body喵？',
    _ => text.runes.length >= _zhSentenceLength ? '$text喵～' : '$text喵',
  };
  if (text.runes.length < _zhKaomojiLength) return marked;
  return '$marked ${_kaomojiFor(text)}';
}

String _catgirlizeTone(String text, _CatgirlTone tone) {
  final body = text.substring(0, text.length - 1);
  return switch (text[text.length - 1]) {
    '。' || '.' => '$body${tone.joiner}${tone.end}',
    '！' || '!' => '$body${tone.joiner}${tone.exclamation}',
    '？' || '?' => '$body${tone.joiner}${tone.question}',
    _ => '$text${tone.joiner}${tone.end}',
  };
}

String _kaomojiFor(String text) {
  var index = 0;
  for (final rune in text.runes) {
    index = (index + rune) % _zhKaomoji.length;
  }
  return _zhKaomoji[index];
}
