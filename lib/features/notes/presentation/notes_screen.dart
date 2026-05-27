import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_notes/features/notes/domain/note_model.dart';
import 'package:quick_notes/features/notes/providers/notes_providers.dart';
import 'package:quick_notes/features/notes/presentation/widgets/note_card.dart';
import 'package:quick_notes/shared/widgets/loading_shimmer.dart';
import 'package:quick_notes/shared/widgets/app_empty_state.dart';
import 'package:quick_notes/shared/widgets/app_error_widget.dart';
import 'package:quick_notes/shared/widgets/confirm_dialog.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredNotesProvider);
    final sort = ref.watch(notesSortProvider);
    final search = ref.watch(notesSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          PopupMenuButton<NoteSort>(
            initialValue: sort,
            tooltip: 'Sort',
            onSelected: (s) =>
                ref.read(notesSortProvider.notifier).state = s,
            icon: const Icon(Icons.sort_rounded),
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: NoteSort.updatedAt,
                  child: Text('Last Updated')),
              PopupMenuItem(
                  value: NoteSort.createdAt,
                  child: Text('Date Created')),
              PopupMenuItem(
                  value: NoteSort.title, child: Text('Title (A–Z)')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) =>
                  ref.read(notesSearchProvider.notifier).state = v,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: 6,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: NoteCardShimmer(),
                ),
              ),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(notesStreamProvider),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.note_alt_outlined,
                    title: search.isNotEmpty
                        ? 'No results found'
                        : 'No notes yet',
                    subtitle: search.isNotEmpty
                        ? 'Try a different search term'
                        : 'Tap + to create your first note',
                  );
                }

                final pinned =
                    notes.where((n) => n.isPinned).toList();
                final unpinned =
                    notes.where((n) => !n.isPinned).toList();

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(notesStreamProvider),
                  child: ListView(
                    padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        _SectionLabel(label: 'PINNED'),
                        ...pinned.map(
                          (note) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _DismissibleNote(note: note),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (unpinned.isNotEmpty) ...[
                        if (pinned.isNotEmpty)
                          _SectionLabel(label: 'ALL NOTES'),
                        ...unpinned.map(
                          (note) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _DismissibleNote(note: note),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New note',
        onPressed: () async {
          final noteId =
              await ref.read(notesNotifierProvider.notifier).createNote();
          if (context.mounted) context.push('/notes/$noteId');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: const Color(0xFF80848E),
            ),
      ),
    );
  }
}

class _DismissibleNote extends ConsumerWidget {
  final NoteModel note;
  const _DismissibleNote({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(note.noteId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFED4245),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showConfirmDialog(
        context,
        title: 'Delete Note',
        message:
            '"${note.title.isEmpty ? 'Untitled' : note.title}" will be permanently deleted.',
        confirmLabel: 'Delete',
        destructive: true,
      ),
      onDismissed: (_) =>
          ref.read(notesNotifierProvider.notifier).deleteNote(note.noteId),
      child: NoteCard(
        note: note,
        onTap: () => context.push('/notes/${note.noteId}'),
        onTogglePin: () => ref
            .read(notesNotifierProvider.notifier)
            .togglePin(note.noteId, !note.isPinned),
      ),
    );
  }
}
