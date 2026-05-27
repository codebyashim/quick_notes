import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quick_notes/core/utils/date_utils.dart';
import 'package:quick_notes/features/notes/domain/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
  });

  String _getPreview() {
    if (note.contentPlain.isNotEmpty) {
      final text = note.contentPlain.replaceAll('\n', ' ').trim();
      return text.length > 120 ? '${text.substring(0, 120)}...' : text;
    }
    if (note.content.isEmpty) return '';
    try {
      final ops = jsonDecode(note.content) as List;
      final buf = StringBuffer();
      for (final op in ops) {
        if (op is Map && op['insert'] is String) {
          buf.write(op['insert'] as String);
        }
      }
      final text = buf.toString().replaceAll('\n', ' ').trim();
      return text.length > 120 ? '${text.substring(0, 120)}...' : text;
    } catch (_) {
      return '';
    }
  }

  Color? _bgColor() {
    if (note.backgroundType != 'color' || note.backgroundColor == null) {
      return null;
    }
    final hex = note.backgroundColor!.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _bgColor();
    final hasBgImage =
        note.backgroundType == 'image' && note.backgroundImageUrl != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor ?? const Color(0xFF2B2D31),
          borderRadius: BorderRadius.circular(8),
          image: hasBgImage
              ? DecorationImage(
                  image: NetworkImage(note.backgroundImageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.45),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: const Color(0xFFF2F3F5)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onTogglePin,
                    child: Icon(
                      note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      size: 17,
                      color: note.isPinned
                          ? const Color(0xFF5865F2)
                          : const Color(0xFF80848E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _getPreview(),
                style: const TextStyle(
                    color: Color(0xFFB5BAC1), fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                AppDateUtils.formatRelative(note.updatedAt),
                style: const TextStyle(
                    color: Color(0xFF80848E), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
