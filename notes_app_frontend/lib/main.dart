import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app_frontend/note_edit_screen.dart';
import 'package:notes_app_frontend/services/local_note_service.dart';
import 'package:notes_app_frontend/services/remote_note_service.dart';
import 'package:notes_app_frontend/models/note.dart';
import 'package:notes_app_frontend/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ensure local storage is initialized before app starts
  await LocalNoteService.instance.init();

  // Try connecting to Supabase, but app is usable offline
  await RemoteNoteService.instance.init();

  runApp(const NotesApp());
}

// PUBLIC_INTERFACE
class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  List<Note> _notes = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _syncNotesWithCloud();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    _notes = await LocalNoteService.instance.getAllNotes();
    setState(() => _isLoading = false);
  }

  Future<void> _syncNotesWithCloud() async {
    setState(() => _isSyncing = true);
    await RemoteNoteService.instance.syncWithCloud();
    _notes = await LocalNoteService.instance.getAllNotes();
    setState(() => _isSyncing = false);
  }

  Future<void> _addOrEditNote({Note? note}) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(existingNote: note),
      ),
    );
    if (result != null) {
      await LocalNoteService.instance.saveNote(result);
      await _syncNotesWithCloud();
      await _loadNotes();
    }
  }

  Future<void> _deleteNote(Note note) async {
    await LocalNoteService.instance.deleteNote(note.id);
    await _syncNotesWithCloud();
    await _loadNotes();
  }

  List<Note> get _filteredNotes {
    if (_searchQuery.trim().isEmpty) return _notes;
    final query = _searchQuery.trim().toLowerCase();
    return _notes
        .where((n) =>
            n.title.toLowerCase().contains(query) ||
            n.content.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 2,
        elevation: 0,
        title: const Text('My Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _SearchBar(
              searchQuery: _searchQuery,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
        actions: [
          if (_isSyncing)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync with Cloud',
            onPressed: _isSyncing ? null : _syncNotesWithCloud,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredNotes.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  itemCount: _filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = _filteredNotes[index];
                    return Dismissible(
                      key: ValueKey(note.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteNote(note),
                      child: GestureDetector(
                        onTap: () => _addOrEditNote(note: note),
                        child: Card(
                          elevation: 2,
                          color: Colors.white,
                          shadowColor: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  note.content.length > 110
                                      ? '${note.content.substring(0, 108)}...'
                                      : note.content,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 9),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    note.fmtDateShort,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'No notes yet.\nTap + to add a new note!'
                        : 'No results for "$_searchQuery"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 18),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        tooltip: 'Add Note',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;
  const _SearchBar({
    required this.searchQuery,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Search notes',
      child: TextField(
        onChanged: onChanged,
        autocorrect: true,
        cursorColor: Theme.of(context).colorScheme.primary,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.3,
            ),
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
