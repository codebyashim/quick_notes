import 'package:flutter/material.dart';
import 'package:quick_notes/core/utils/date_utils.dart';
import 'package:quick_notes/features/files/domain/file_model.dart';
import 'package:quick_notes/features/files/presentation/widgets/file_type_icon.dart';

class FileGridTile extends StatelessWidget {
  final FileModel file;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const FileGridTile({
    super.key,
    required this.file,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FileTypeIcon(mimeType: file.mimeType, size: 40),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    icon: const Icon(Icons.more_vert,
                        color: Color(0xFF80848E), size: 18),
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
                                style:
                                    TextStyle(color: Color(0xFFED4245))),
                          ])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  file.name,
                  style: const TextStyle(
                      color: Color(0xFFF2F3F5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppDateUtils.formatFileSize(file.sizeBytes),
                  style: const TextStyle(
                      color: Color(0xFF80848E), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
