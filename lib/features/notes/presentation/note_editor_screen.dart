import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_notes/features/notes/data/notes_repository.dart';
import 'package:quick_notes/features/notes/providers/notes_providers.dart';
import 'package:quick_notes/features/notes/presentation/widgets/note_background_picker.dart';
import 'package:quick_notes/shared/widgets/confirm_dialog.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() =>
      _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late QuillController _quillController;
  late TextEditingController _titleCtrl;
  Timer? _debounce;
  bool _isSaving = false;
  bool _initialized = false;
  bool _localUpdate = false;
  String? _currentNoteId;
  String _lastSavedContent = '';
  String _lastSavedTitle = '';

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _titleCtrl = TextEditingController();
    _currentNoteId = widget.noteId;
    if (_currentNoteId == null) _createNote();
  }

  Future<void> _createNote() async {
    final id =
        await ref.read(notesNotifierProvider.notifier).createNote();
    if (mounted) setState(() => _currentNoteId = id);
  }

  void _onChanged() {
    if (!_initialized) return;
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 800), _autosave);
  }

  Future<void> _autosave() async {
    if (_currentNoteId == null) return;
    final title = _titleCtrl.text.trim();
    final delta = _quillController.document.toDelta().toJson();
    final contentJson = jsonEncode(delta);
    final plainText =
        _quillController.document.toPlainText().trim();

    if (contentJson == _lastSavedContent && title == _lastSavedTitle) {
      return;
    }

    _localUpdate = true;
    if (mounted) setState(() => _isSaving = true);
    try {
      await ref.read(notesRepositoryProvider).updateNote(
        _currentNoteId!,
        {
          'title': title,
          'content': contentJson,
          'contentPlain': plainText,
        },
      );
      _lastSavedContent = contentJson;
      _lastSavedTitle = title;
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSaving = false);
      _localUpdate = false;
    }
  }

  Future<void> _saveAndPop() async {
    _debounce?.cancel();
    await _autosave();
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _quillController.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNoteId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final noteAsync = ref.watch(noteStreamProvider(_currentNoteId!));

    return noteAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: Center(child: Text('Error: $e')),
      ),
      data: (note) {
        if (note == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
            ),
            body: const Center(child: Text('Note not found')),
          );
        }

        // One-time initialization of editor content
        if (!_initialized) {
          _titleCtrl.text = note.title;
          if (note.content.isNotEmpty) {
            try {
              final delta = jsonDecode(note.content) as List;
              _quillController = QuillController(
                document: Document.fromJson(delta),
                selection:
                    const TextSelection.collapsed(offset: 0),
              );
            } catch (_) {}
          }
          _quillController.addListener(_onChanged);
          _titleCtrl.addListener(_onChanged);
          _lastSavedContent = note.content;
          _lastSavedTitle = note.title;
          _initialized = true;
        }

        // Apply remote changes without overwriting local edits
        if (_initialized && !_localUpdate && !_isSaving) {
          if (note.content != _lastSavedContent) {
            try {
              final delta = jsonDecode(note.content) as List;
              _quillController.document = Document.fromJson(delta);
              _lastSavedContent = note.content;
            } catch (_) {}
          }
        }

        BoxDecoration? bgDecoration;
        Color scaffoldBg = const Color(0xFF313338);
        if (note.backgroundType == 'color' &&
            note.backgroundColor != null) {
          final hex = note.backgroundColor!.replaceAll('#', '');
          scaffoldBg = Color(int.parse('FF$hex', radix: 16));
        } else if (note.backgroundType == 'image' &&
            note.backgroundImageUrl != null) {
          bgDecoration = BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(note.backgroundImageUrl!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5),
                BlendMode.darken,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1F22),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _saveAndPop,
            ),
            title: TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Note title...',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                  color: Color(0xFFF2F3F5),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            actions: [
              // Save indicator
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isSaving
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFB5BAC1)),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.check_circle_outline,
                            color: Color(0xFF57F287), size: 20),
                      ),
              ),
              // Pin toggle
              IconButton(
                icon: Icon(
                  note.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  color: note.isPinned
                      ? const Color(0xFF5865F2)
                      : const Color(0xFFB5BAC1),
                ),
                tooltip:
                    note.isPinned ? 'Unpin note' : 'Pin note',
                onPressed: () => ref
                    .read(notesNotifierProvider.notifier)
                    .togglePin(_currentNoteId!, !note.isPinned),
              ),
              // Background picker
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                tooltip: 'Change background',
                onPressed: () => _showBgPicker(context, note),
              ),
              // Delete
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFFED4245)),
                tooltip: 'Delete note',
                onPressed: () async {
                  final ok = await showConfirmDialog(
                    context,
                    title: 'Delete Note',
                    message:
                        'This note will be permanently deleted.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );
                  if (ok && context.mounted) {
                    await ref
                        .read(notesNotifierProvider.notifier)
                        .deleteNote(_currentNoteId!);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: Container(
            decoration: bgDecoration,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: QuillEditor.basic(
                      controller: _quillController,
                      configurations: const QuillEditorConfigurations(
                        placeholder: 'Start writing...',
                        expands: true,
                        padding: EdgeInsets.zero,
                        autoFocus: false,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B2D31),
                    border: Border(
                      top: BorderSide(
                          color: Color(0xFF3F4147), width: 1),
                    ),
                  ),
                  child: QuillSimpleToolbar(
                    controller: _quillController,
                    configurations: const QuillSimpleToolbarConfigurations(
                      showFontFamily: false,
                      showFontSize: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showInlineCode: true,
                      showCodeBlock: true,
                      showQuote: true,
                      showClipboardCopy: false,
                      showClipboardCut: false,
                      showClipboardPaste: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBgPicker(BuildContext context, note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NoteBackgroundPicker(
        noteId: _currentNoteId!,
        currentNote: note,
        onColorSelected: (color) async {
          Navigator.pop(context);
          await ref.read(notesRepositoryProvider).updateNote(
            _currentNoteId!,
            {
              'backgroundColor': color,
              'backgroundType': 'color',
              'backgroundImageUrl': null,
            },
          );
        },
        onImageSelected: (Uint8List bytes, String mime) async {
          Navigator.pop(context);
          final url = await ref
              .read(notesRepositoryProvider)
              .uploadBackgroundImage(_currentNoteId!, bytes, mime);
          await ref.read(notesRepositoryProvider).updateNote(
            _currentNoteId!,
            {
              'backgroundImageUrl': url,
              'backgroundType': 'image',
              'backgroundColor': null,
            },
          );
        },
        onClearBackground: () async {
          Navigator.pop(context);
          await ref.read(notesRepositoryProvider).updateNote(
            _currentNoteId!,
            {
              'backgroundColor': null,
              'backgroundImageUrl': null,
              'backgroundType': 'none',
            },
          );
        },
      ),
    );
  }
}
