
import 'package:flutter/material.dart';
import 'package:noteappflu/pages/noteScreen.dart';
import 'package:noteappflu/utilis/note_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteLoader extends StatefulWidget {
  const NoteLoader({super.key});

  @override
  State<NoteLoader> createState() => _NoteLoaderState();
}

class _NoteLoaderState extends State<NoteLoader> {
  String? token;
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    username = prefs.getString('username');

    if (token == null || username == null) {
      Navigator.of(context).pushReplacementNamed('/');
      return;
    }

    setState(() => isLoading = false);
  }

  void handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => NoteController(token: token!)..fetchNotes(),
      child: NoteScreen(
        username: username!,
        onLogout: handleLogout,
      ),
    );
  }
}
