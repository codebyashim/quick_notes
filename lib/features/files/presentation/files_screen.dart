import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quick_notes/features/files/domain/file_model.dart';
import 'package:quick_notes/features/files/providers/files_providers.dart';
import 'package:quick_notes/features/files/presentation/widgets/file_grid_tile.dart';
import 'package:quick_notes/features/files/presentation/widgets/file_list_tile_widget.dart';
import 'package:quick_notes/features/files/presentation/widgets/upload_progress_overlay.dart';
import 'package:quick_notes/shared/widgets/loading_shimmer.dart';
import 'package:quick_notes/shared/widgets/app_empty_state.dart';
import 'package:quick_notes/shared/widgets/app_error_widget.dart';
import 'package:quick_notes/shared/widgets/confirm_dialog.dart';

class FilesScreen extends ConsumerWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(filesViewModeProvider);
    final sort = ref.watch(filesSortProvider);
    final search = ref.watch(filesSearchProvider);
    final filteredAsync = ref.watch(filteredFilesProvider);
    final upload = ref.watch(uploadNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          // Sort menu
          PopupMenuButton<FileSort>(
            initialValue: sort,
            tooltip: 'Sort',
            onSelected: (s) =>
                ref.read(filesSortProvider.notifier).state = s,
            icon: const Icon(Icons.sort_rounded),
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: FileSort.createdAt,
                  child: Text('Date Added')),
              PopupMenuItem(
                  value: FileSort.name, child: Text('Name (A–Z)')),
              PopupMenuItem(
                  value: FileSort.size, child: Text('File Size')),
            ],
          ),
          // View mode toggle
          IconButton(
            icon: Icon(viewMode == FilesViewMode.grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded),
            tooltip: viewMode == FilesViewMode.grid
                ? 'List view'
                : 'Grid view',
            onPressed: () {
              ref.read(filesViewModeProvider.notifier).state =
                  viewMode == FilesViewMode.grid
                      ? FilesViewMode.list
                      : FilesViewMode.grid;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search files...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(filesSearchProvider.notifier).state = v,
            ),
          ),
          const SizedBox(height: 8),
          // Upload progress
          const UploadProgressOverlay(),
          // Upload error snackbar
          if (upload.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D1515),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFED4245), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upload failed: ${upload.error}',
                        style: const TextStyle(
                            color: Color(0xFFED4245), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // File list
          Expanded(
            child: filteredAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: 6,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: FileItemShimmer(),
                ),
              ),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(filesStreamProvider),
              ),
              data: (files) {
                if (files.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.folder_outlined,
                    title: search.isNotEmpty
                        ? 'No files found'
                        : 'No files yet',
                    subtitle: search.isNotEmpty
                        ? 'Try a different search term'
                        : 'Tap + to upload your first file',
                  );
                }

                if (viewMode == FilesViewMode.grid) {
                  return GridView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: files.length,
                    itemBuilder: (_, i) => FileGridTile(
                      file: files[i],
                      onTap: () => _download(context, files[i]),
                      onDelete: () =>
                          _confirmDelete(context, ref, files[i]),
                      onRename: () =>
                          _showRenameDialog(context, ref, files[i]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: files.length,
                  itemBuilder: (_, i) => FileListTileWidget(
                    file: files[i],
                    onTap: () => _download(context, files[i]),
                    onDelete: () =>
                        _confirmDelete(context, ref, files[i]),
                    onRename: () =>
                        _showRenameDialog(context, ref, files[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Upload file',
        onPressed: upload.isUploading ? null : () => _pickAndUpload(context, ref),
        child: upload.isUploading
            ? const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2)
            : const Icon(Icons.upload_rounded),
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not read file data'),
          backgroundColor: Color(0xFFED4245),
        ));
      }
      return;
    }

    try {
      await ref.read(uploadNotifierProvider.notifier).uploadFile(
            filename: file.name,
            bytes: Uint8List.fromList(file.bytes!),
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: const Color(0xFFED4245),
        ));
      }
    }
  }

  Future<void> _download(BuildContext context, FileModel file) async {
    final uri = Uri.parse(file.downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot open this file'),
          backgroundColor: Color(0xFFED4245),
        ));
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, FileModel file) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete File',
      message: '"${file.name}" will be permanently deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed) {
      try {
        await ref.read(filesNotifierProvider.notifier).deleteFile(file);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: const Color(0xFFED4245),
          ));
        }
      }
    }
  }

  Future<void> _showRenameDialog(
      BuildContext context, WidgetRef ref, FileModel file) async {
    final ctrl = TextEditingController(text: file.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(labelText: 'File name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final n = ctrl.text.trim();
              if (n.isNotEmpty) Navigator.pop(ctx, n);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (newName != null && newName != file.name) {
      await ref
          .read(filesNotifierProvider.notifier)
          .renameFile(file.fileId, newName);
    }
  }
}
