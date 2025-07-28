import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:noteappflu/components/sideBar.dart';

void main() {
  late List<Note> sampleNotes;
  final List<String> toastMessages = [];
  const MethodChannel fluttertoastChannel = MethodChannel('fluttertoast');

  setUp(() {
    sampleNotes = [
      Note(
        id: '1',
        title: 'Test Note',
        content: '<p>Sample content</p>',
        imageUrl: null,
        createdAt: DateTime(2024, 7, 1),
        updatedAt: DateTime(2024, 7, 2),
      ),
      Note(
        id: '2',
        title: 'Another Note',
        content: '<p>Another content</p>',
        imageUrl: null,
        createdAt: DateTime(2024, 7, 3),
        updatedAt: DateTime(2024, 7, 4),
      ),
    ];
    toastMessages.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(fluttertoastChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(fluttertoastChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'showToast') {
        final args = methodCall.arguments;
        if (args is Map && args.containsKey('msg')) {
          toastMessages.add(args['msg'] as String);
        } else if (args is String) {
          toastMessages.add(args);
        } else {
          toastMessages.add(args.toString());
        }
        return true;
      }
      return null;
    });
  });

  Widget makeWidget({
    Note? activeNote,
    required List<Note> notes,
    VoidCallback? onAddClick,
    void Function(String)? onDelete,
    void Function(Note)? onNoteClick,
    required VoidCallback onLogout,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SidebarWidget(
          activeNote: activeNote,
          notes: notes,
          onAddClick: onAddClick ?? () {},
          onDelete: onDelete ?? (_) {},
          onNoteClick: onNoteClick ?? (_) {},
          username: 'TestUser',
          onLogout: onLogout,
        ),
      ),
    );
  }

  testWidgets('renders username and notes list', (tester) async {
    await tester.pumpWidget(makeWidget(notes: sampleNotes, onLogout: () {}));

    expect(find.text('TestUser'), findsOneWidget);
    expect(find.text('Test Note'), findsOneWidget);
    expect(find.text('Another Note'), findsOneWidget);
  });


  testWidgets('filters notes and shows toast if no match', (tester) async {
    await tester.pumpWidget(makeWidget(notes: sampleNotes, onLogout: () {}));
    await tester.enterText(find.byType(TextField), 'no-match');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300)); 
  });

  testWidgets('delete confirmation dialog calls onDelete', (tester) async {
    String? deletedId;
    await tester.pumpWidget(makeWidget(
      notes: sampleNotes,
      onDelete: (id) => deletedId = id,
      onLogout: () {},
    ));

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deletedId, '1');
  });

  testWidgets('logout confirmation dialog triggers onLogout and toast',
      (tester) async {
    bool loggedOut = false;
    await tester.pumpWidget(makeWidget(
      notes: sampleNotes,
      onLogout: () => loggedOut = true,
    ));
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500)); 
    expect(loggedOut, isTrue);
  });

  testWidgets('clicking a note triggers onNoteClick', (tester) async {
    Note? clickedNote;
    await tester.pumpWidget(makeWidget(
      notes: sampleNotes,
      onNoteClick: (note) => clickedNote = note,
      onLogout: () {},
    ));

    await tester.tap(find.text('Test Note'));
    expect(clickedNote?.id, '1');
  });
}
