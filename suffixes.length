import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class FileUtils {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) return true;
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    return true;
  }

  static List<FileSystemEntity> listDir(String path) {
    try {
      final dir = Directory(path);
      final entries = dir.listSync(followLinks: false);
      entries.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });
      return entries;
    } catch (_) {
      return [];
    }
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.bitLength - 1) ~/ 10;
    if (i >= suffixes.length) i = suffixes.length - 1;
    final value = bytes / (1 << (i * 10));
    return '${value.toStringAsFixed(value < 10 ? 1 : 0)} ${suffixes[i]}';
  }

  static String fileName(String path) => path.split(Platform.pathSeparator).last;
}
