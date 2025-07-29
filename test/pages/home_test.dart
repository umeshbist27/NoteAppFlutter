import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteappflu/pages/home.dart';

void main() {
  testWidgets('HomeScreen renders all expected widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Note App'), findsOneWidget);
    expect(find.text('Note Taking App'), findsOneWidget);
    expect(find.textContaining('Sign up'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
  testWidgets('Tapping Sign Up navigates to /signup route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        routes: {
          '/signup': (context) => const Scaffold(body: Text('Signup Screen')),
        },
      ),
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Signup Screen'), findsOneWidget);
  });

  testWidgets('Tapping Login navigates to /login route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
      ),
    );
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Login Screen'), findsOneWidget);
  });
}