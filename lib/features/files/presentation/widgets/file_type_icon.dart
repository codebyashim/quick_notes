import 'package:flutter/material.dart';
import 'package:quick_notes/core/utils/file_utils.dart';

class FileTypeIcon extends StatelessWidget {
  final String mimeType;
  final double size;

  const FileTypeIcon({super.key, required this.mimeType, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final category = FileUtils.getFileTypeCategory(mimeType);
    final (icon, color) = _iconAndColor(category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: size * 0.55),
    );
  }

  (IconData, Color) _iconAndColor(String category) {
    switch (category) {
      case 'image':
        return (Icons.image_rounded, const Color(0xFF57F287));
      case 'video':
        return (Icons.videocam_rounded, const Color(0xFFFAA61A));
      case 'audio':
        return (Icons.audiotrack_rounded, const Color(0xFF5865F2));
      case 'pdf':
        return (Icons.picture_as_pdf_rounded, const Color(0xFFED4245));
      case 'apk':
        return (Icons.android_rounded, const Color(0xFF57F287));
      case 'archive':
        return (Icons.folder_zip_rounded, const Color(0xFFFAA61A));
      case 'document':
        return (Icons.description_rounded, const Color(0xFF5865F2));
      case 'spreadsheet':
        return (Icons.table_chart_rounded, const Color(0xFF57F287));
      case 'presentation':
        return (Icons.slideshow_rounded, const Color(0xFFFAA61A));
      case 'text':
        return (Icons.article_rounded, const Color(0xFFB5BAC1));
      default:
        return (Icons.insert_drive_file_rounded, const Color(0xFF80848E));
    }
  }
}
