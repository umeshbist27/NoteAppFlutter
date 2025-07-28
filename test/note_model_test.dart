import 'package:flutter_test/flutter_test.dart';
import 'package:noteappflu/note_models/note.dart';

void main() {
  group("note model", () {
    test("from json parses correctly", () {
      final json = {
        '_id': "123",
        "title": "read",
        "content": "reading book",
        "imageUrl": "https://example.com/image.jpg",
        'createdAt': '2025-07-25T10:00:00Z',
        'updatedAt': '2025-07-25T12:00:00Z',
      };

      final note = Note.fromJson(json);
      expect(note.id, '123');
      expect(note.title, "read");
      expect(note.content, "reading book");
      expect(note.imageUrl, 'https://example.com/image.jpg');
      expect(note.createdAt, DateTime.parse('2025-07-25T10:00:00Z'));
      expect(note.updatedAt, DateTime.parse('2025-07-25T12:00:00Z'));
    });

    test("copy with creates the modified copy", (){

      final original=Note(id: "1", title: "original", content: "old content",imageUrl: null,
       createdAt: DateTime(2025, 7, 25, 10), updatedAt: DateTime(2025, 7, 25, 12));

      final modified=original.copyWith(title: "new title",content: "new content",
      imageUrl: 'https://example.com/new.jpg',
      );

      expect(modified.id, '1');
      expect(modified.title,'new title');
      expect(modified.content, "new content");
      expect(modified.imageUrl,'https://example.com/new.jpg' );
      expect(modified.createdAt, original.createdAt);
      expect(modified.updatedAt, original.updatedAt);
    });
  });
}
