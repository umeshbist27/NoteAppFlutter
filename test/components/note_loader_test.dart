import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteappflu/components/note_loader.dart';

void main() {
  Widget makeTestableWidget() {
    return const MaterialApp(
      home: NoteLoader(),
    );
  }

  testWidgets('the note loader needs to render it without crashing', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });
}
