import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_notes/features/files/data/files_repository.dart';
import 'package:quick_notes/features/files/domain/file_model.dart';

enum FileSort { createdAt, name, size }

enum FilesViewMode { grid, list }

final filesViewModeProvider =
    StateProvider<FilesViewMode>((ref) => FilesViewMode.grid);
final filesSortProvider =
    StateProvider<FileSort>((ref) => FileSort.createdAt);
final filesSearchProvider = StateProvider<String>((ref) => '');

final filesStreamProvider = StreamProvider<List<FileModel>>((ref) {
  return ref.watch(filesRepositoryProvider).watchFiles();
});

final filteredFilesProvider =
    Provider<AsyncValue<List<FileModel>>>((ref) {
  final filesAsync = ref.watch(filesStreamProvider);
  final sort = ref.watch(filesSortProvider);
  final search = ref.watch(filesSearchProvider).toLowerCase().trim();

  return filesAsync.whenData((files) {
    var filtered = files.where((f) {
      if (search.isEmpty) return true;
      return f.name.toLowerCase().contains(search);
    }).toList();

    filtered.sort((a, b) {
      switch (sort) {
        case FileSort.createdAt:
          return b.createdAt.compareTo(a.createdAt);
        case FileSort.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case FileSort.size:
          return b.sizeBytes.compareTo(a.sizeBytes);
      }
    });

    return filtered;
  });
});

class UploadState {
  final bool isUploading;
  final double progress;
  final String? currentFileName;
  final String? error;

  const UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.currentFileName,
    this.error,
  });

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    String? currentFileName,
    String? error,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      currentFileName: currentFileName ?? this.currentFileName,
      error: error,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  final Ref _ref;
  StreamSubscription<double>? _sub;

  UploadNotifier(this._ref) : super(const UploadState());

  Future<void> uploadFile({
    required String filename,
    required Uint8List bytes,
  }) async {
    state = UploadState(
      isUploading: true,
      progress: 0,
      currentFileName: filename,
    );

    final completer = Completer<void>();

    _sub = _ref
        .read(filesRepositoryProvider)
        .uploadFile(
          filename: filename,
          bytes: bytes,
          onComplete: (file) {
            state = const UploadState(isUploading: false, progress: 1.0);
            completer.complete();
          },
          onError: (error) {
            state = UploadState(
              isUploading: false,
              error: error,
            );
            completer.completeError(error);
          },
        )
        .listen(
          (progress) => state = state.copyWith(progress: progress),
        );

    return completer.future;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, UploadState>(
  (ref) => UploadNotifier(ref),
);

class FilesNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  FilesNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> deleteFile(FileModel file) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(filesRepositoryProvider).deleteFile(file);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> renameFile(String fileId, String newName) async {
    await _ref.read(filesRepositoryProvider).renameFile(fileId, newName);
  }
}

final filesNotifierProvider =
    StateNotifierProvider<FilesNotifier, AsyncValue<void>>(
  (ref) => FilesNotifier(ref),
);
