import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:noteappflu/utilis/note_helpers.dart';
import 'package:noteappflu/pages/noteScreen.dart';
import 'package:provider/provider.dart';

import 'noteScreen_test.mocks.dart';

@GenerateMocks([NoteController])
void main() {
  late MockNoteController mockController;
  late Note testNote;

  setUp(() {
    mockController = MockNoteController();

    testNote = Note(
      id: '1',
      title: 'Test Title',
      content: 'Test Content',
      imageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    when(mockController.notes).thenReturn([testNote]);
    when(mockController.activeNote).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<NoteController>.value(
      value: mockController,
      child: MaterialApp(
        home: NoteScreen(username: 'TestUser', onLogout: (){}),
      ),
    );
  }

  testWidgets('Shows drawer and empty message when no active note',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    final scaffoldState =
        tester.firstState(find.byType(Scaffold)) as ScaffoldState;
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Open the drawer to select or add a note'), findsOneWidget);
  });

  testWidgets('Triggers addNote when add is called', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    verifyNever(mockController.addNote());
    mockController.addNote();
    verify(mockController.addNote()).called(1);
  });

  testWidgets('Triggers selectNote when note clicked', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    verifyNever(mockController.selectNote(testNote));

    mockController.selectNote(testNote);
    verify(mockController.selectNote(testNote)).called(1);
  });

  testWidgets('Triggers deleteNote when delete called', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    verifyNever(mockController.deleteNote('1'));

    mockController.deleteNote('1');
    verify(mockController.deleteNote('1')).called(1);
  });
}
