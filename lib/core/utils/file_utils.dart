import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:quick_notes/core/constants/app_constants.dart';

class FileUtils {
  static String getMimeType(String filename) {
    return lookupMimeType(filename) ?? 'application/octet-stream';
  }

  static String getExtension(String filename) {
    return p.extension(filename).toLowerCase();
  }

  static String getFileTypeCategory(String mimeType) {
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'audio';
    if (mimeType == 'application/pdf') return 'pdf';
    if (mimeType == 'application/vnd.android.package-archive') return 'apk';
    if (mimeType == 'application/x-msdownload' ||
        (mimeType == 'application/octet-stream' &&
            mimeType.contains('.exe'))) {
      return 'exe';
    }
    if (mimeType == 'application/zip' ||
        mimeType == 'application/x-rar-compressed' ||
        mimeType == 'application/x-7z-compressed' ||
        mimeType == 'application/x-tar' ||
        mimeType == 'application/gzip') {
      return 'archive';
    }
    if (mimeType.contains('word') ||
        mimeType.contains('document') ||
        mimeType == 'application/msword' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return 'document';
    }
    if (mimeType.contains('excel') ||
        mimeType.contains('spreadsheet') ||
        mimeType == 'application/vnd.ms-excel') {
      return 'spreadsheet';
    }
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) {
      return 'presentation';
    }
    if (mimeType.startsWith('text/')) return 'text';
    return 'file';
  }

  static bool isFileSizeValid(int bytes) {
    return bytes <= AppConstants.maxFileSizeBytes;
  }

  static String sanitizeFilename(String filename) {
    return filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }
}
