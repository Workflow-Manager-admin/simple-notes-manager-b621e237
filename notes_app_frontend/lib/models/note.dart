import 'package:uuid/uuid.dart';

/// PUBLIC_INTERFACE
/// A Note object representing a user's note.
/// Includes title, content, timestamps, and an id.
class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get fmtDateShort {
    final date = updatedAt;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$month/$day ${hour}:${min}';
  }

  /// Creates a Note from a map, supporting both camelCase (local)
  /// and snake_case (Supabase) field name variants.
  /// Always prefers snake_case if present (for Supabase compatibility).
  /// This method ensures that notes loaded from Supabase DB are correctly mapped.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: 
        // Prefer snake_case if present, fallback to camelCase, fallback to now().
        DateTime.tryParse(
          map['created_at']?.toString() ?? map['createdAt']?.toString() ?? ''
        ) ?? DateTime.now(),
      updatedAt:
        DateTime.tryParse(
          map['updated_at']?.toString() ?? map['updatedAt']?.toString() ?? ''
        ) ?? DateTime.now(),
    );
  }

  /// Converts to a map for local storage (camelCase) or database (snake_case).
  /// Set [forDb] to true to use Supabase-compatible snake_case keys.
  Map<String, dynamic> toMap({bool forDb = false}) {
    if (forDb) {
      return {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
    } else {
      return {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
    }
  }
}
