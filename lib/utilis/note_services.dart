import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:noteappflu/note_models/note.dart';

class NoteService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static http.Client client = http.Client();

  static Future<List<Note>> fetchNotes(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/notes/note'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notes');
    }
  }

  static Future<void> deleteNote(String id, String token) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/notes/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete note');
    }
  }

  static Future<void> saveNote(Note note, String token) async {
    final body = {
      "title": note.title,
      "content": note.content,
      "imageUrl": note.imageUrl,
    };

    final bool isNew = note.id == 'null' || note.id.isEmpty;

    final uri = isNew
        ? Uri.parse('$baseUrl/api/notes/create')
        : Uri.parse('$baseUrl/api/notes/edit/${note.id}'); 

    final response = await (isNew
        ? client.post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
        : client.put(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          ));

    if (!(response.statusCode == 200 || response.statusCode == 201)) {
      throw Exception('Failed to save note');
    }
  }
}
