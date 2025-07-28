import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noteappflu/pages/signupPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNavigatorObserver mockObserver;

  setUpAll(() async {
    dotenv.testLoad(
      mergeWith: {
        'BASE_URL': 'http://dummy',
        'ANOTHER_KEY': 'value',
      },
    );
  });

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  Future<void> pumpSignupScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const SignupScreen(),
        navigatorObservers: [mockObserver],
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Page')),
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SignupScreen Widget Tests', () {
    testWidgets('renders static texts and fields', (tester) async {
      await pumpSignupScreen(tester);
      expect(find.textContaining('Create Account'), findsOneWidget);
      expect(find.textContaining('Sign up to get started'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('shows validation for empty fields', (tester) async {
      await pumpSignupScreen(tester);
      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);
      await tester.pump();
      expect(find.textContaining('Enter your name'), findsOneWidget);
      expect(find.textContaining('Enter your email'), findsOneWidget);
      expect(find.textContaining('Enter your password'), findsOneWidget);
    });

    testWidgets('invalid email shows error', (tester) async {
      await pumpSignupScreen(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'bademail');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);
      await tester.pump();
      expect(find.textContaining('Invalid email'), findsOneWidget);
    });

    testWidgets('toggles password visibility icon', (tester) async {
      await pumpSignupScreen(tester);
      final toggleIcon = find.byIcon(Icons.visibility).first;
      expect(toggleIcon, findsOneWidget);
      await tester.tap(toggleIcon);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('navigates to login screen', (tester) async {
      await pumpSignupScreen(tester);
      final loginFinder = find.textContaining('Log in');
      expect(loginFinder, findsOneWidget);
      await tester.tap(loginFinder);
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
