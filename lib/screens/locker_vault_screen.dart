import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/animated_tile.dart';

/// Files moved here live inside the app's private sandbox storage,
/// which other apps and the normal file browser cannot see.
class LockerVaultScreen extends StatefulWidget {
  const LockerVaultScreen({super.key});

  @override
  State<LockerVaultScreen> createState() => _LockerVaultScreenState();
}

class _LockerVaultScreenState extends State<LockerVaultScreen> {
  List<FileSystemEntity> _files = [];
  String? _vaultPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appDir = await getApplicationSupportDirectory();
    final vault = Directory('${appDir.path}/king_vault');
    if (!await vault.exists()) await vault.create(recursive: true);
    setState(() {
      _vaultPath = vault.path;
      _files = FileUtils.listDir(vault.path);
    });
  }

  Future<void> _addFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || _vaultPath == null) return;
    for (final f in result.files) {
      if (f.path == null) continue;
      final src = File(f.path!);
      final dest = File('$_vaultPath/${f.name}');
      await src.copy(dest.path);
    }
    _load();
  }

  Future<void> _deleteFile(FileSystemEntity entity) async {
    await entity.delete();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Vault')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFile,
        icon: const Icon(Icons.add),
        label: const Text('Add File'),
      ),
      body: _files.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.enhanced_encryption_rounded, size: 64, color: theme.colorScheme.tertiary),
                  const SizedBox(height: 12),
                  const Text('Your vault is empty and private.'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, i) {
                final f = _files[i];
                return AnimatedTile(
                  index: i,
                  onTap: () => OpenFilex.open(f.path),
                  onLongPress: () => _deleteFile(f),
                  child: ListTile(
                    leading: Icon(Icons.insert_drive_file_rounded, color: theme.colorScheme.tertiary),
                    title: Text(FileUtils.fileName(f.path)),
                    subtitle: const Text('Long-press to delete'),
                  ),
                );
              },
            ),
    );
  }
}
