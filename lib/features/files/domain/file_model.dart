import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  final String fileId;
  final String uid;
  final String name; // user-visible, renameable
  final String storagePath; // Firebase Storage path
  final String downloadUrl;
  final int sizeBytes;
  final String mimeType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FileModel({
    required this.fileId,
    required this.uid,
    required this.name,
    required this.storagePath,
    required this.downloadUrl,
    required this.sizeBytes,
    required this.mimeType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FileModel.fromMap(String id, Map<String, dynamic> map) {
    return FileModel(
      fileId: id,
      uid: map['uid'] as String,
      name: map['name'] as String,
      storagePath: map['storagePath'] as String,
      downloadUrl: map['downloadUrl'] as String,
      sizeBytes: (map['sizeBytes'] as num).toInt(),
      mimeType: map['mimeType'] as String? ?? 'application/octet-stream',
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'storagePath': storagePath,
    'downloadUrl': downloadUrl,
    'sizeBytes': sizeBytes,
    'mimeType': mimeType,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  FileModel copyWith({
    String? fileId,
    String? uid,
    String? name,
    String? storagePath,
    String? downloadUrl,
    int? sizeBytes,
    String? mimeType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileModel(
      fileId: fileId ?? this.fileId,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
