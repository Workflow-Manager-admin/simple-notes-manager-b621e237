import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app_frontend/models/note.dart';
import 'package:notes_app_frontend/services/local_note_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalNoteService', () {
    setUp(() async {
      await LocalNoteService.instance.init();
      await LocalNoteService.instance.clear();
    });

    test('Save and get notes', () async {
      final note1 = Note(title: 'First', content: 'Hello');
      final note2 = Note(title: 'Second', content: 'World');

      await LocalNoteService.instance.saveNote(note1);
      await LocalNoteService.instance.saveNote(note2);

      final allNotes = await LocalNoteService.instance.getAllNotes();
      expect(allNotes.length, 2);
      expect(allNotes.any((n) => n.title == 'First'), isTrue);
      expect(allNotes.any((n) => n.title == 'Second'), isTrue);
    });

    test('Edit note', () async {
      final note = Note(title: 'E1', content: 'C1');
      await LocalNoteService.instance.saveNote(note);

      final updated = note.copyWith(title: 'E2');
      await LocalNoteService.instance.saveNote(updated);

      final allNotes = await LocalNoteService.instance.getAllNotes();
      expect(allNotes.length, 1);
      expect(allNotes.first.title, 'E2');
    });

    test('Delete notes', () async {
      final note = Note(title: 'DeleteMe', content: 'Bye');
      await LocalNoteService.instance.saveNote(note);
      await LocalNoteService.instance.deleteNote(note.id);

      final allNotes = await LocalNoteService.instance.getAllNotes();
      expect(allNotes, isEmpty);
    });
  });
}
