import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:noteappflu/utilis/note_services.dart';

void main() {
  const testToken = 'token';
  group("Note services test", () {
    setUp(() {
      NoteService.baseUrl = "http://fakeapi.com";
    });
    test("fetch notes returns 200 on success", () async {
      NoteService.client = MockClient((request) async {
        if (request.url.path == "/api/notes/note") {
          return http.Response(
            jsonEncode([
              {
                '_id': '1',
                'title': 'Note1',
                'content': 'Content1',
                'imageUrl': null,
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              },
            ]),
            200
          );
        }
        return http.Response("not found", 404);
      });
      final notes = await NoteService.fetchNotes(testToken);
      expect(notes.length, 1);
      expect(notes[0].id, '1');
    });

    test('fetchNotes throws on error', () {
      NoteService.client = MockClient((request) async {
        return http.Response('Error', 500);
      });

      expect(() => NoteService.fetchNotes(testToken), throwsException);
    });

    test('deleteNote on 200 status', () async {
      NoteService.client = MockClient((request) async {
        if (request.method == 'DELETE' &&
            request.url.path == '/api/notes/123') {
          return http.Response('', 200);
        }
        return http.Response('Error', 400);
      });

      await NoteService.deleteNote('123', testToken);
    });
    test('deleteNote throws exception on failure', () {
      NoteService.client = MockClient((request) async {
        return http.Response('Error', 500);
      });

      expect(() => NoteService.deleteNote('123', testToken), throwsException);
    });
    test('saveNote uses POST for new note and completes on 201', () async {
      final newNote = Note(
        id: 'null',
        title: 'New Note',
        content: 'New content',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      NoteService.client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/api/notes/create') {
          return http.Response('', 201);
        }
        return http.Response('Error', 400);
      });

      await NoteService.saveNote(newNote, testToken);
    });

    test('saveNote uses PUT for existing note and completes on 200', () async {
      final existingNote = Note(
        id: '123',
        title: 'Existing Note',
        content: 'Existing content',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      NoteService.client = MockClient((request) async {
        if (request.method == 'PUT' &&
            request.url.path == '/api/notes/edit/123') {
          return http.Response('', 200);
        }
        return http.Response('Error', 400);
      });

      await NoteService.saveNote(existingNote, testToken);
    });

    test('saveNote throws on failure', () {
      final note = Note(
        id: 'null',
        title: 'Bad Note',
        content: 'Bad content',
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      NoteService.client = MockClient((request) async {
        return http.Response('Error', 400);
      });
      expect(() => NoteService.saveNote(note, testToken), throwsException);
    });
  });
}
