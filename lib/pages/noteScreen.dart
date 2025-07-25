
import 'package:flutter/material.dart';
import 'package:noteappflu/components/noteEditorWidget.dart';
import 'package:noteappflu/components/sideBar.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:noteappflu/utilis/note_helpers.dart';
import 'package:provider/provider.dart';

class NoteScreen extends StatefulWidget {
  final String username;
  final VoidCallback onLogout;

  const NoteScreen({
    Key? key,
    required this.username,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late NoteController noteController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    noteController = Provider.of<NoteController>(context);
  }

  void handleNoteSelected(Note note) {
    noteController.selectNote(note);
    Navigator.of(context).pop(); 
  }

  void handleAddNote() {
    noteController.addNote();
    Navigator.of(context).pop(); 
  }

  void handleDelete(String id) {
    noteController.deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    final notes = noteController.notes;
    final activeNote = noteController.activeNote;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      drawer: Drawer(
        child: SidebarWidget(
          username: widget.username,
          onLogout: widget.onLogout,
          notes: notes,
          activeNote: activeNote,
          onDelete: handleDelete,
          onAddClick: handleAddNote,
          onNoteClick: handleNoteSelected,
        ),
      ),
      body: activeNote == null
          ? const Center(
              child: Text('Open the drawer to select or add a note'),
            )
          : NoteEditorWidget(
              note: activeNote,
              onSave: (note) {
                noteController.saveNote(note);
              }, username: '',
            ),
    );
  }
}
