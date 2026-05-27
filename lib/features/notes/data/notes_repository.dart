import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:quick_notes/core/constants/app_constants.dart';
import 'package:quick_notes/features/notes/domain/note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  NotesRepository(this._firestore, this._auth, this._storage);

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _notesRef =>
      _firestore.collection(AppConstants.notesCollection);

  Stream<List<NoteModel>> watchNotes() {
    return _notesRef
        .where('uid', isEqualTo: _uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<NoteModel?> watchNote(String noteId) {
    return _notesRef.doc(noteId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return NoteModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<NoteModel> createNote() async {
    final noteId = const Uuid().v4();
    final now = DateTime.now();
    final note = NoteModel(
      noteId: noteId,
      uid: _uid,
      title: '',
      content: '',
      contentPlain: '',
      isPinned: false,
      backgroundType: 'none',
      createdAt: now,
      updatedAt: now,
    );
    await _notesRef.doc(noteId).set(note.toMap());
    return note;
  }

  Future<void> updateNote(
      String noteId, Map<String, dynamic> updates) async {
    await _notesRef.doc(noteId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String noteId) async {
    final doc = await _notesRef.doc(noteId).get();
    if (doc.exists && doc.data() != null) {
      final note = NoteModel.fromMap(doc.id, doc.data()!);
      if (note.backgroundType == 'image' &&
          note.backgroundImageUrl != null) {
        try {
          await _storage.refFromURL(note.backgroundImageUrl!).delete();
        } catch (_) {}
      }
    }
    await _notesRef.doc(noteId).delete();
  }

  Future<void> togglePin(String noteId, bool isPinned) async {
    await _notesRef.doc(noteId).update({
      'isPinned': isPinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadBackgroundImage(
      String noteId, Uint8List bytes, String mimeType) async {
    final ref = _storage.ref('notes/$_uid/$noteId/background');
    await ref.putData(bytes, SettableMetadata(contentType: mimeType));
    return await ref.getDownloadURL();
  }
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    FirebaseStorage.instance,
  );
});
