import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String noteId;
  final String uid;
  final String title;
  final String content; // Quill Delta JSON string
  final String contentPlain; // plain text for search preview
  final bool isPinned;
  final String? backgroundColor; // hex color e.g. '#2B2D31'
  final String? backgroundImageUrl;
  final String backgroundType; // 'none' | 'color' | 'image'
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.noteId,
    required this.uid,
    required this.title,
    required this.content,
    required this.contentPlain,
    required this.isPinned,
    this.backgroundColor,
    this.backgroundImageUrl,
    required this.backgroundType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      noteId: id,
      uid: map['uid'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      contentPlain: map['contentPlain'] as String? ?? '',
      isPinned: map['isPinned'] as bool? ?? false,
      backgroundColor: map['backgroundColor'] as String?,
      backgroundImageUrl: map['backgroundImageUrl'] as String?,
      backgroundType: map['backgroundType'] as String? ?? 'none',
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'title': title,
    'content': content,
    'contentPlain': contentPlain,
    'isPinned': isPinned,
    'backgroundColor': backgroundColor,
    'backgroundImageUrl': backgroundImageUrl,
    'backgroundType': backgroundType,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  NoteModel copyWith({
    String? noteId,
    String? uid,
    String? title,
    String? content,
    String? contentPlain,
    bool? isPinned,
    Object? backgroundColor = _sentinel,
    Object? backgroundImageUrl = _sentinel,
    String? backgroundType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      noteId: noteId ?? this.noteId,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      content: content ?? this.content,
      contentPlain: contentPlain ?? this.contentPlain,
      isPinned: isPinned ?? this.isPinned,
      backgroundColor: backgroundColor == _sentinel
          ? this.backgroundColor
          : backgroundColor as String?,
      backgroundImageUrl: backgroundImageUrl == _sentinel
          ? this.backgroundImageUrl
          : backgroundImageUrl as String?,
      backgroundType: backgroundType ?? this.backgroundType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const _sentinel = Object();
