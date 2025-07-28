import 'package:flutter/material.dart';
import 'package:noteappflu/note_models/note.dart';

class TestableNoteEditorWidget extends StatefulWidget {
  final Note note;
  final String username;
  final void Function(Note) onSave;

  const TestableNoteEditorWidget({
    super.key,
    required this.note,
    required this.username,
    required this.onSave,
  });

  @override
  State<TestableNoteEditorWidget> createState() => _TestableNoteEditorWidgetState();
}

class _TestableNoteEditorWidgetState extends State<TestableNoteEditorWidget> {
  late TextEditingController _titleController;
  bool _showSaved = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
  }

  void _saveNote(String title) {
    final updatedNote = widget.note.copyWith(title: title);
    widget.onSave(updatedNote);

    setState(() {
      _showSaved = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showSaved = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.username),
        TextField(
          controller: _titleController,
          onChanged: _saveNote,
        ),
        if (_showSaved) const Text('Saved'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Upload Image'),
          onPressed: () {}, 
        ),
      ],
    );
  }
}
