import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noteappflu/components/note_loader.dart';
import 'package:noteappflu/pages/home.dart';
import 'package:noteappflu/pages/loginPage.dart';
import 'package:noteappflu/pages/signupPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NoteTaking app",
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/notes': (context) => NoteLoader(),
      },
    );
  }
}


