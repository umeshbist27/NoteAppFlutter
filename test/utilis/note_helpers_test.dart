import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:noteappflu/utilis/note_helpers.dart';
import 'package:noteappflu/utilis/note_services.dart';

void main() {
  const token = 'fake-token';

  final noteJson1 = {
    '_id': '1',
    'title': 'Test Note',
    'content': 'Some content',
    'imageUrl': null,
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  final noteJson2 = {
    '_id': '2',
    'title': 'Another Note',
    'content': 'Other content',
    'imageUrl': null,
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  group('NoteController Tests', () {
    late NoteController controller;

    setUp(() {
      NoteService.baseUrl = 'http://fakeapi.com';
      controller = NoteController(token: token);
    });

    test('searchTitle filters notes correctly by title', () async {
      NoteService.client = MockClient((request) async {
        return http.Response(jsonEncode([noteJson1, noteJson2]), 200);
      });

      await controller.fetchNotes();
      controller.searchTitle = 'another';

      expect(controller.notes.length, 1);
      expect(controller.notes.first.id, '2');
    });

    test('once selectNote then updates activeNote', () async {
      final note = Note.fromJson(noteJson1);
      controller.selectNote(note);
      expect(controller.activeNote, equals(note));
    });

    test('addNote creates a new blank note', () async {
      await controller.addNote();
      expect(controller.activeNote!.id, 'null');
      expect(controller.activeNote!.title, '');
    });

    test('fetchNotes returns  notes to UI and sets it as activeNote', () async {
      NoteService.client = MockClient((request) async {
        return http.Response(jsonEncode([noteJson1]), 200);
      });

      await controller.fetchNotes();

      expect(controller.notes.length, 1);
      expect(controller.activeNote, isNotNull);
      expect(controller.notes.first.id, '1');
    });

    test('saveNote skips saving if title and content are empty', () async {
      final note = Note(
        id: '1',
        title: ' ',
        content: ' ',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await controller.saveNote(note);
      expect(controller.notes.isEmpty, true);
    });

    test('saveNote triggers POST and refetch for new note with in ms', () async {
      final newNote = Note(
        id: 'null',
        title: 'New Note',
        content: 'New content',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool postCalled = false;
      bool getCalled = false;

      NoteService.client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/api/notes/create') {
          postCalled = true;
          return http.Response('', 201);
        }
        if (request.method == 'GET' && request.url.path == '/api/notes/note') {
          getCalled = true;
          return http.Response(jsonEncode([noteJson1]), 200);
        }
        return http.Response('Error', 400);
      });

      await controller.saveNote(newNote);

      expect(postCalled, isTrue);
      expect(getCalled, isTrue);
    });

    test('deleteNote triggers DELETE and refetch after deletion', () async {
      controller.selectNote(Note.fromJson(noteJson1));

      bool deleteCalled = false;
      bool getCalled = false;

      NoteService.client = MockClient((request) async {
        if (request.method == 'DELETE' && request.url.path == '/api/notes/1') {
          deleteCalled = true;
          return http.Response('', 200);
        }
        if (request.method == 'GET' && request.url.path == '/api/notes/note') {
          getCalled = true;
          return http.Response('[]', 200);
        }
        return http.Response('Error', 400);
      });

      await controller.deleteNote('1');

      expect(deleteCalled, isTrue);
      expect(getCalled, isTrue);
      expect(controller.activeNote, isNull);
    });
  });
}
