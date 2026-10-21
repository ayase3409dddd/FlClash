import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/common.dart';
import 'package:path/path.dart' as p;

const _backgroundDirectoryName = 'background';
const _backgroundFileStem = 'background';
const _fallbackExtension = 'image';

final _extensionPattern = RegExp(r'^[a-z0-9]{1,5}$');

Future<Directory> _backgroundDirectory() async {
  final directory = Directory(
    p.join(await appPath.homeDirPath, _backgroundDirectoryName),
  );
  await directory.create(recursive: true);
  return directory;
}

String _extensionOf(PlatformFile picked) {
  final extension = picked.extension?.toLowerCase();
  if (extension == null || !_extensionPattern.hasMatch(extension)) {
    return _fallbackExtension;
  }
  return extension;
}

Future<void> _clear(Directory directory) async {
  await for (final entity in directory.list()) {
    if (entity is File) {
      await entity.safeDelete();
    }
  }
}

/// Picks a picture and stores it in the app's private directory; null when
/// the picker was dismissed.
Future<String?> pickBackgroundImage() async {
  final picked = await FilePicker.pickFile(
    type: FileType.image,
    initialDirectory: await appPath.downloadDirPath,
  );
  if (picked == null) {
    return null;
  }
  final bytes = await picked.readAsBytes();
  final directory = await _backgroundDirectory();
  final target = File(
    p.join(directory.path, '$_backgroundFileStem.${_extensionOf(picked)}'),
  );
  await _clear(directory);
  await target.safeWriteAsBytes(bytes);
  return target.path;
}

/// Deletes [path] only while it is inside the app's background directory.
Future<void> deleteBackgroundImage(String? path) async {
  if (path == null || path.isEmpty) {
    return;
  }
  final directory = p.normalize(
    p.absolute(p.join(await appPath.homeDirPath, _backgroundDirectoryName)),
  );
  final target = p.normalize(p.absolute(path));
  if (!p.isWithin(directory, target)) {
    return;
  }
  await File(target).safeDelete();
}
