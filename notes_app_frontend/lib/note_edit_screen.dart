import 'package:flutter/material.dart';
import 'models/note.dart';

/// PUBLIC_INTERFACE
/// Screen for editing or creating a note.
class NoteEditScreen extends StatefulWidget {
  final Note? existingNote;
  const NoteEditScreen({super.key, this.existingNote});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context); // Nothing to save
      return;
    }

    setState(() => _saving = true);

    final now = DateTime.now();
    final note = widget.existingNote == null
        ? Note(
            title: title.isEmpty ? 'Untitled' : title,
            content: content,
            createdAt: now,
            updatedAt: now,
          )
        : widget.existingNote!.copyWith(
            title: title.isEmpty ? 'Untitled' : title, content: content, updatedAt: now);

    await Future.delayed(const Duration(milliseconds: 100)); // For UI smoothness
    if (mounted) {
      Navigator.pop(context, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(widget.existingNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _saving ? null : _saveNote,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
            onPressed: _saving ? null : () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              enabled: !_saving,
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 21),
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 21,
              ),
              textInputAction: TextInputAction.next,
              autofocus: widget.existingNote == null,
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                enabled: !_saving,
                minLines: 8,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Start writing your note here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _saving
          ? const Padding(
              padding: EdgeInsets.only(bottom: 32.0),
              child: CircularProgressIndicator(),
            )
          : null,
    );
  }
}
