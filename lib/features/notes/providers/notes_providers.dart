import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_notes/features/notes/data/notes_repository.dart';
import 'package:quick_notes/features/notes/domain/note_model.dart';

enum NoteSort { updatedAt, createdAt, title }

final notesSortProvider =
    StateProvider<NoteSort>((ref) => NoteSort.updatedAt);
final notesSearchProvider = StateProvider<String>((ref) => '');

final notesStreamProvider = StreamProvider<List<NoteModel>>((ref) {
  return ref.watch(notesRepositoryProvider).watchNotes();
});

final filteredNotesProvider =
    Provider<AsyncValue<List<NoteModel>>>((ref) {
  final notesAsync = ref.watch(notesStreamProvider);
  final sort = ref.watch(notesSortProvider);
  final search = ref.watch(notesSearchProvider).toLowerCase().trim();

  return notesAsync.whenData((notes) {
    var filtered = notes.where((n) {
      if (search.isEmpty) return true;
      return n.title.toLowerCase().contains(search) ||
          n.contentPlain.toLowerCase().contains(search);
    }).toList();

    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      switch (sort) {
        case NoteSort.updatedAt:
          return b.updatedAt.compareTo(a.updatedAt);
        case NoteSort.createdAt:
          return b.createdAt.compareTo(a.createdAt);
        case NoteSort.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return filtered;
  });
});

final noteStreamProvider =
    StreamProvider.family<NoteModel?, String>((ref, noteId) {
  return ref.watch(notesRepositoryProvider).watchNote(noteId);
});

class NotesNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  NotesNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<String> createNote() async {
    final note = await _ref.read(notesRepositoryProvider).createNote();
    return note.noteId;
  }

  Future<void> deleteNote(String noteId) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(notesRepositoryProvider).deleteNote(noteId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> togglePin(String noteId, bool isPinned) async {
    await _ref
        .read(notesRepositoryProvider)
        .togglePin(noteId, isPinned);
  }
}

final notesNotifierProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<void>>(
  (ref) => NotesNotifier(ref),
);
