import 'package:flutter/material.dart';
import 'package:quick_notes/core/utils/date_utils.dart';
import 'package:quick_notes/features/files/domain/file_model.dart';
import 'package:quick_notes/features/files/presentation/widgets/file_type_icon.dart';

class FileListTileWidget extends StatelessWidget {
  final FileModel file;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const FileListTileWidget({
    super.key,
    required this.file,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          child: Row(
            children: [
              FileTypeIcon(mimeType: file.mimeType, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                          color: Color(0xFFF2F3F5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${AppDateUtils.formatFileSize(file.sizeBytes)} · ${AppDateUtils.formatRelative(file.createdAt)}',
                      style: const TextStyle(
                          color: Color(0xFF80848E), fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: Color(0xFF80848E), size: 20),
                onSelected: (v) {
                  if (v == 'rename') onRename();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'rename',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ])),
                  PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 16, color: Color(0xFFED4245)),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(
                                color: Color(0xFFED4245))),
                      ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
