import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noteappflu/pages/loginPage.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNavigatorObserver mockObserver;

  setUpAll(() async {
    dotenv.testLoad(
      mergeWith: {
        'BASE_URL': 'http://dummy',
      },
    );
  });

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
        navigatorObservers: [mockObserver],
        routes: {
          '/signup': (context) => const Scaffold(body: Text('Signup Page')),
          '/notes': (context) => const Scaffold(body: Text('Notes Page')),
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders static texts and fields', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Please log in to your account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.textContaining("Don't have an account? Sign up"), findsOneWidget);
    });

    testWidgets('shows validation for empty fields', (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('invalid email shows error', (tester) async {
      await pumpLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'bademail');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('toggles password visibility icon', (tester) async {
      await pumpLoginScreen(tester);

      final visibilityIcon = find.byIcon(Icons.visibility).first;
      expect(visibilityIcon, findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('navigates to signup screen', (tester) async {
      await pumpLoginScreen(tester);

      final signUpText = find.textContaining("Don't have an account? Sign up");
      expect(signUpText, findsOneWidget);

      await tester.tap(signUpText);
      await tester.pumpAndSettle();

      expect(find.text('Signup Page'), findsOneWidget);
    });
  });
}
