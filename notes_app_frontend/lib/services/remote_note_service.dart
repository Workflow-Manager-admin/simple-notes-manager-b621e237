import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';
import 'local_note_service.dart';

/// PUBLIC_INTERFACE
/// Handles cloud sync to and from Supabase.
/// Local saves always take priority; sync attempts to upsert all local notes and fetch remote changes.
/// Users must be registered in Supabase if authentication required (not required for anon mode).
class RemoteNoteService {
  static final RemoteNoteService instance = RemoteNoteService._internal();
  factory RemoteNoteService() => instance;
  RemoteNoteService._internal();

  static const supabaseUrl = 'https://mzxyorlnbfdkneiezgjz.supabase.co';
  static const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16eHlvcmxuYmZka25laWV6Z2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNDUxMDksImV4cCI6MjA2NzYyMTEwOX0.URYpbwtC2u5ORBlUzpWPNspXMWq_cLBOKWMOgGbilyQ';

  late SupabaseClient _client;

  bool _isInitialized = false;

  /// Initialize connection (safe to call multiple times).
  Future<void> init() async {
    if (!_isInitialized) {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
      _client = Supabase.instance.client;
      _isInitialized = true;
    }
  }

  /// Sync local notes to Supabase (remote update always last-write-wins by updatedAt).
  /// Then fetch all remote notes, merge with local, and update local.
  Future<void> syncWithCloud() async {
    try {
      await init();
      final localNotes = await LocalNoteService.instance.getAllNotes();

      // Push local notes to Supabase (upsert)
      for (final note in localNotes) {
        await _client
            .from('notes')
            .upsert(note.toMap(forDb: true), onConflict: 'id')
            .select();
      }

      // Pull notes from Supabase, resolve latest by updatedAt
      final dynamic response =
          await _client.from('notes').select();
      // Ensure we get a List<Map>
      final List<Map<String, dynamic>> remoteList = response is List
          ? List<Map<String, dynamic>>.from(
              response.whereType<Map<String, dynamic>>())
          : <Map<String, dynamic>>[];
      final remoteNotes = remoteList
          .map((item) => Note.fromMap(item))
          .toList();

      // Merge and select the latest between local and remote
      final Map<String, Note> noteMap = {};
      for (final note in [...localNotes, ...remoteNotes]) {
        if (!noteMap.containsKey(note.id) ||
            note.updatedAt.isAfter(noteMap[note.id]!.updatedAt)) {
          noteMap[note.id] = note;
        }
      }
      await LocalNoteService.instance
          .overwriteNotes(noteMap.values.toList());
    } catch (e) {
      // Fail gracefully if offline
    }
  }
}
