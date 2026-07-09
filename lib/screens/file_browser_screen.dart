import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../utils/file_utils.dart';
import '../widgets/animated_tile.dart';

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  String _currentPath = '/storage/emulated/0';
  final List<String> _history = [];
  bool _gridView = false;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final granted = await FileUtils.requestStoragePermission();
    setState(() => _permissionGranted = granted);
  }

  void _openFolder(String path) {
    setState(() {
      _history.add(_currentPath);
      _currentPath = path;
    });
  }

  bool _goBack() {
    if (_history.isNotEmpty) {
      setState(() => _currentPath = _history.removeLast());
      return true;
    }
    return false;
  }

  IconData _iconFor(FileSystemEntity entity) {
    if (entity is Directory) return Icons.folder_rounded;
    final ext = entity.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return Icons.image_rounded;
    if (['mp4', 'mkv', 'mov', 'avi'].contains(ext)) return Icons.movie_rounded;
    if (['mp3', 'wav', 'flac', 'aac'].contains(ext)) return Icons.music_note_rounded;
    if (['pdf'].contains(ext)) return Icons.picture_as_pdf_rounded;
    if (['zip', 'rar', '7z'].contains(ext)) return Icons.folder_zip_rounded;
    if (['doc', 'docx'].contains(ext)) return Icons.description_rounded;
    if (['apk'].contains(ext)) return Icons.android_rounded;
    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_permissionGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_open_rounded, size: 64, color: theme.colorScheme.secondary),
              const SizedBox(height: 16),
              const Text('Storage permission needed'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _init, child: const Text('Grant Permission')),
            ],
          ),
        ),
      );
    }

    final entries = FileUtils.listDir(_currentPath);

    return PopScope(
      canPop: _history.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            FileUtils.fileName(_currentPath).isEmpty ? 'King Manager' : FileUtils.fileName(_currentPath),
            overflow: TextOverflow.ellipsis,
          ),
          leading: _history.isNotEmpty
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack)
              : null,
          actions: [
            IconButton(
              icon: Icon(_gridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
              onPressed: () => setState(() => _gridView = !_gridView),
            ),
          ],
        ),
        body: entries.isEmpty
            ? const Center(child: Text('This folder is empty'))
            : _gridView
                ? GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, i) => _buildGridTile(entries[i], i, theme),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: entries.length,
                    itemBuilder: (context, i) => _buildListTile(entries[i], i, theme),
                  ),
      ),
    );
  }

  void _handleTap(FileSystemEntity entity) {
    if (entity is Directory) {
      _openFolder(entity.path);
    } else {
      OpenFilex.open(entity.path);
    }
  }

  Widget _buildListTile(FileSystemEntity entity, int index, ThemeData theme) {
    final isDir = entity is Directory;
    final stat = !isDir ? (entity as File).lengthSync() : 0;
    return AnimatedTile(
      index: index,
      onTap: () => _handleTap(entity),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(entity), color: theme.colorScheme.tertiary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                FileUtils.fileName(entity.path),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (!isDir) Text(FileUtils.formatBytes(stat), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(FileSystemEntity entity, int index, ThemeData theme) {
    return AnimatedTile(
      index: index,
      onTap: () => _handleTap(entity),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_iconFor(entity), size: 40, color: theme.colorScheme.tertiary),
            const SizedBox(height: 8),
            Text(
              FileUtils.fileName(entity.path),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
