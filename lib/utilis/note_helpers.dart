import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:noteappflu/utilis/note_services.dart';


class NoteController extends ChangeNotifier {
  List<Note> _notes = [];
  Note? _activeNote;
  String _searchTitle = '';
  final String token;

  NoteController({required this.token});

  List<Note> get notes {
    if (_searchTitle.isEmpty) return _notes;
    return _notes
        .where((note) => note.title.toLowerCase().contains(_searchTitle.toLowerCase()))
        .toList();
  }

  Note? get activeNote => _activeNote;

  set searchTitle(String value) {
    _searchTitle = value;
    notifyListeners();
  }

  Future<void> fetchNotes() async {
    try {
      final fetchedNotes = await NoteService.fetchNotes(token);
      _notes = fetchedNotes..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      if (_activeNote == null && _notes.isNotEmpty) {
        _activeNote = _notes[0];
      } else if (_activeNote != null) {
        _activeNote = _notes.firstWhere(
          (n) => n.id == _activeNote!.id,
          orElse: () => _notes[0],
        );
      }
      notifyListeners();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching notes:");
    }
  }

  void selectNote(Note note) {
    _activeNote = note;
    notifyListeners();
  }

  Future<void> addNote() async {
    final newNote = Note(
      id: 'null',
      title: '',
      content: '',
      imageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _activeNote = newNote;
    notifyListeners();
  }

  Future<void> saveNote(Note note) async {
    if (note.title.trim().isEmpty && note.content.trim().isEmpty) {
      return;
    }
    try {
      await NoteService.saveNote(note, token);
      await fetchNotes();
    } catch (e) {
    Fluttertoast.showToast(msg: "Error saving notes:");
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await NoteService.deleteNote(id, token);
      if (_activeNote != null && _activeNote!.id == id) {
        _activeNote = null;
      }
      await fetchNotes();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting notes:");
    }
  }
}