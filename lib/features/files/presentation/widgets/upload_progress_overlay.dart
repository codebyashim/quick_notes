import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_notes/features/files/providers/files_providers.dart';

class UploadProgressOverlay extends ConsumerWidget {
  const UploadProgressOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upload = ref.watch(uploadNotifierProvider);

    if (!upload.isUploading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D31),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF5865F2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_rounded,
                  color: Color(0xFF5865F2), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Uploading ${upload.currentFileName ?? 'file'}...',
                  style: const TextStyle(
                      color: Color(0xFFF2F3F5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(upload.progress * 100).toInt()}%',
                style: const TextStyle(
                    color: Color(0xFF5865F2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: upload.progress,
              backgroundColor: const Color(0xFF383A40),
              color: const Color(0xFF5865F2),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
