import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:quick_notes/core/constants/app_constants.dart';
import 'package:quick_notes/core/utils/file_utils.dart';
import 'package:quick_notes/features/files/domain/file_model.dart';

class FilesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  FilesRepository(this._firestore, this._auth, this._storage);

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _filesRef =>
      _firestore.collection(AppConstants.filesCollection);

  Stream<List<FileModel>> watchFiles() {
    return _filesRef
        .where('uid', isEqualTo: _uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => FileModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Uploads a file and returns a stream of progress (0.0–1.0).
  /// Calls [onComplete] with the created [FileModel] when done.
  Stream<double> uploadFile({
    required String filename,
    required Uint8List bytes,
    required void Function(FileModel file) onComplete,
    required void Function(String error) onError,
  }) {
    if (!FileUtils.isFileSizeValid(bytes.length)) {
      onError('File size exceeds 100 MB limit');
      return const Stream.empty();
    }

    final fileId = const Uuid().v4();
    final mimeType = FileUtils.getMimeType(filename);
    final storagePath = 'files/$_uid/$fileId/$filename';
    final ref = _storage.ref(storagePath);
    final task = ref.putData(
      bytes,
      SettableMetadata(contentType: mimeType),
    );

    final controller = StreamController<double>.broadcast();

    task.snapshotEvents.listen(
      (snap) {
        final progress = snap.bytesTransferred / snap.totalBytes;
        controller.add(progress);
      },
      onDone: () async {
        try {
          final downloadUrl = await ref.getDownloadURL();
          final now = DateTime.now();
          final file = FileModel(
            fileId: fileId,
            uid: _uid,
            name: filename,
            storagePath: storagePath,
            downloadUrl: downloadUrl,
            sizeBytes: bytes.length,
            mimeType: mimeType,
            createdAt: now,
            updatedAt: now,
          );
          await _filesRef.doc(fileId).set(file.toMap());
          onComplete(file);
        } catch (e) {
          onError(e.toString());
        } finally {
          controller.close();
        }
      },
      onError: (e) {
        onError(e.toString());
        controller.close();
      },
    );

    return controller.stream;
  }

  Future<void> deleteFile(FileModel file) async {
    try {
      await _storage.ref(file.storagePath).delete();
    } catch (_) {}
    await _filesRef.doc(file.fileId).delete();
  }

  Future<void> renameFile(String fileId, String newName) async {
    await _filesRef.doc(fileId).update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return FilesRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    FirebaseStorage.instance,
  );
});
