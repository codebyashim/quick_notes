import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:quick_notes/core/constants/app_constants.dart';
import 'package:quick_notes/features/notes/domain/note_model.dart';

class NoteBackgroundPicker extends StatelessWidget {
  final String noteId;
  final NoteModel currentNote;
  final void Function(String color) onColorSelected;
  final void Function(Uint8List bytes, String mimeType) onImageSelected;
  final VoidCallback onClearBackground;

  const NoteBackgroundPicker({
    super.key,
    required this.noteId,
    required this.currentNote,
    required this.onColorSelected,
    required this.onImageSelected,
    required this.onClearBackground,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Note Background',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Colors',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppConstants.noteBackgroundColors.map((hex) {
                final colorHex = hex.replaceAll('#', '');
                final color = Color(int.parse('FF$colorHex', radix: 16));
                final isSelected =
                    currentNote.backgroundColor == hex &&
                        currentNote.backgroundType == 'color';
                return GestureDetector(
                  onTap: () => onColorSelected(hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5865F2)
                            : const Color(0xFF3F4147),
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('Upload Image'),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (file != null) {
                        final bytes = await file.readAsBytes();
                        final mime =
                            lookupMimeType(file.path) ?? 'image/jpeg';
                        onImageSelected(bytes, mime);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.format_color_reset,
                        size: 18),
                    label: const Text('Clear'),
                    onPressed: onClearBackground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
