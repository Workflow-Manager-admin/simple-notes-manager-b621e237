import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// PUBLIC_INTERFACE
/// LocalNoteService handles local storage of notes via SharedPreferences.
class LocalNoteService {
  static final LocalNoteService instance = LocalNoteService._internal();
  factory LocalNoteService() => instance;
  LocalNoteService._internal();

  static const String _notesKey = 'user_notes';

  late SharedPreferences _prefs;

  /// Initialize local persistence (must be awaited before using the service).
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Returns all notes sorted by update time desc.
  Future<List<Note>> getAllNotes() async {
    final listJson = _prefs.getStringList(_notesKey) ?? [];
    List<Note> notes = [];
    for (final n in listJson) {
      try {
        notes.add(Note.fromMap(jsonDecode(n)));
      } catch (_) {}
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// Adds or updates a note.
  Future<void> saveNote(Note note) async {
    final notes = await getAllNotes();
    int idx = notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      notes[idx] = note..updatedAt = DateTime.now();
    } else {
      notes.add(note..updatedAt = DateTime.now());
    }
    await _saveNotesList(notes);
  }

  /// Delete a note by id.
  Future<void> deleteNote(String noteId) async {
    final notes = await getAllNotes();
    notes.removeWhere((n) => n.id == noteId);
    await _saveNotesList(notes);
  }

  /// Save whole list to local storage (private).
  Future<void> _saveNotesList(List<Note> notes) async {
    await _prefs.setStringList(
        _notesKey, notes.map((e) => jsonEncode(e.toMap())).toList());
  }

  // PUBLIC_INTERFACE
  /// Overwrites stored notes with provided notes list (used for full resyncs/cloud sync).
  Future<void> overwriteNotes(List<Note> notes) async {
    await _saveNotesList(notes);
  }

  /// Clear all notes (generally used for debugging).
  Future<void> clear() async {
    await _prefs.remove(_notesKey);
  }
}
