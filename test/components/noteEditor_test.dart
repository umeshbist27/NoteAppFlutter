import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteappflu/note_models/note.dart';
import 'testable_note_editor_widget.dart';

void main() {
  late Note testNote;
  late bool saveCalled;
  late Note? savedNote;

  setUp(() {
    testNote = Note(
      id: '1',
      title: 'Original Title',
      content: 'Original Content',
      imageUrl: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    saveCalled = false;
    savedNote = null;
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: TestableNoteEditorWidget(
          note: testNote,
          username: 'umesh_bist',
          onSave: (note) {
            saveCalled = true;
            savedNote = note;
          },
        ),
      ),
    );
  }

  testWidgets('displays  title and username in the UI', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.text('Original Title'), findsOneWidget);
    expect(find.text('umesh_bist'), findsOneWidget);
  });

  testWidgets('shows saved icon when title is edited (updated)', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.enterText(find.byType(TextField), 'Updated Title');
    await tester.pump(); 
    expect(saveCalled, isTrue);
    expect(savedNote?.title, equals('Updated Title'));
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('the  upload image button exists in widget', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.text('Upload Image'), findsOneWidget);
    expect(find.byIcon(Icons.image), findsOneWidget);
  });
}
