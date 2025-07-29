import 'dart:async';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:noteappflu/components/upload_image_button.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:noteappflu/utilis/date_formatter.dart';
import 'package:noteappflu/utilis/debouncer.dart';

class NoteEditorWidget extends StatefulWidget {
  final Note note;
  final Function(Note) onSave;
  final String username;

  const NoteEditorWidget({
    super.key,
    required this.note,
    required this.onSave,
    required this.username,
  });

  @override
  State<NoteEditorWidget> createState() => _NoteEditorWidgetState();
}

class _NoteEditorWidgetState extends State<NoteEditorWidget> {
  late TextEditingController _titleController;
  late HtmlEditorController _htmlController;
  late Debouncer _debouncer;
  late FocusNode _titleFocusNode;

  bool _showSavedIcon = false;
  late Note _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: widget.note.title);
    _htmlController = HtmlEditorController();
    _titleFocusNode = FocusNode();
    _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
    _titleController.addListener(() {
      _debouncer.run(() => _saveNote());
    });
  }

  @override
  void didUpdateWidget(NoteEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note.id != oldWidget.note.id) {
      _currentNote = widget.note;
      _titleController.text = widget.note.title;
      _htmlController.setText(widget.note.content);
    }
  }

  Future<void> _saveNote({String? contentOverride}) async {
    final newTitle = _titleController.text.trim();
    final newContent = contentOverride ?? await _htmlController.getText();

    if ((newTitle != _currentNote.title || newContent != _currentNote.content) &&
        !(newTitle.isEmpty && newContent.trim().isEmpty)) {
      final updatedNote = _currentNote.copyWith(
        title: newTitle,
        content: newContent,
        updatedAt: DateTime.now(),
      );

      _currentNote = updatedNote;
      widget.onSave(updatedNote);
      _showSaveIndicator();
    }
  }

  void _showSaveIndicator() {
    setState(() => _showSavedIcon = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showSavedIcon = false);
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Note title...',
                border: InputBorder.none,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(widget.username,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(width: 10),
                  Text(
                    "Last modified: ${DateFormatter.format(widget.note.updatedAt)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  if (_showSavedIcon) ...[
                    const Icon(Icons.check, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    const Text('Saved', style: TextStyle(color: Colors.green)),
                  ],
                ],
              ),
            ),

            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: UploadImageButton(
                onImageUploaded: (url) {
                  _htmlController.insertNetworkImage(url);
                },
              ),
            ),

            const SizedBox(height: 6),
            Expanded(
              child: HtmlEditor(
                controller: _htmlController,
                htmlEditorOptions: HtmlEditorOptions(
                  hint: 'Write your note here...',
                  initialText: widget.note.content,
                  shouldEnsureVisible: false,
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  defaultToolbarButtons: [
                    FontButtons(),
                    ListButtons(),
                    InsertButtons(picture: true, table: true),
                  ],
                ),
                otherOptions: OtherOptions(
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
                callbacks: Callbacks(
                  onFocus: () => _titleFocusNode.unfocus(),
                  onChangeContent: (html) =>
                      _debouncer.run(() => _saveNote(contentOverride: html ?? '')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
