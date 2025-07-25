import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noteappflu/note_models/note.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteEditorWidget extends StatefulWidget {
  final Note note;
  final Function(Note) onSave;
  final String username;

  const NoteEditorWidget({
    super.key,
    required this.note,
    required this.onSave,
    required this.username,
  });

  @override
  State<NoteEditorWidget> createState() => _NoteEditorWidgetState();
}

class _NoteEditorWidgetState extends State<NoteEditorWidget> {
  late TextEditingController _titleController;
  late HtmlEditorController _htmlController;

  Timer? _debounceTimer;
  bool _showSavedIcon = false;
  late Note _currentNote;
  late FocusNode _titleFocusNode;

  @override
  void initState() {
    super.initState();

    _currentNote = widget.note;
    _titleController = TextEditingController(text: widget.note.title);
    _htmlController = HtmlEditorController();
    _titleFocusNode = FocusNode();
    _titleController.addListener(() {
      _triggerSave();
    });
  }

  @override
  void didUpdateWidget(NoteEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note.id != oldWidget.note.id) {
      _currentNote = widget.note;
      _titleController.text = widget.note.title;
      _htmlController.setText(widget.note.content);
    }
  }

  void _triggerSave({String? contentOverride}) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final newTitle = _titleController.text.trim();
      final newContent = contentOverride ?? await _htmlController.getText();

      bool hasChanges =
          newTitle != _currentNote.title || newContent != _currentNote.content;
      bool isEffectivelyEmpty = newTitle.isEmpty && newContent.trim().isEmpty;

      if (hasChanges && !isEffectivelyEmpty) {
        Note updatedNote = Note(
          id: _currentNote.id,
          title: newTitle,
          content: newContent,
          imageUrl: _currentNote.imageUrl,
          createdAt: _currentNote.createdAt,
          updatedAt: DateTime.now(),
        );

        _currentNote = updatedNote;
        widget.onSave(updatedNote);

        setState(() {
          _showSavedIcon = true;
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showSavedIcon = false;
            });
          }
        });
      }
    });
  }
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    super.dispose();
    _titleFocusNode.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthShort(date.month)} "
        "${date.year.toString().substring(2)} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  String _monthShort(int month) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    return months[month - 1];
  }

  Future<void> _pickAndUploadImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied to access gallery.")),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    try {
      final imageUrl = await uploadImageToServer(pickedFile.path);
      _htmlController.insertNetworkImage(imageUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Image upload failed: $e")));
      }
    }
  }

  Future<String> uploadImageToServer(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imagePath),
    });

    try {
      final response = await dio.post(
        '${dotenv.env['BASE_URL']}/api/notes/upload-image',
        data: formData,
      );

      if (response.statusCode == 200 && response.data["imageUrl"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );

        return response.data["imageUrl"];
      } else {
        throw Exception("Unexpected response: ${response.data}");
      }
    } catch (e) {
      throw Exception("Upload error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
              decoration: const InputDecoration(
                hintText: 'Note title...',
                border: InputBorder.none,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 20,
                    color: Color.fromARGB(255, 38, 32, 32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 78, 73, 73),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Last modified: ${_formatDate(_currentNote.updatedAt != "" ? _currentNote.updatedAt : _currentNote.createdAt)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Spacer(),
                  if (_showSavedIcon) ...[
                    Icon(Icons.check, color: Colors.green, size: 18),
                    SizedBox(width: 4),
                    Text('Saved', style: TextStyle(color: Colors.green)),
                  ],
                ],
              ),
            ),

            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _pickAndUploadImage,
                icon: const Icon(Icons.image),
                label: const Text("Upload Image"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 6),
            Expanded(
              child: HtmlEditor(
                controller: _htmlController,
                htmlEditorOptions: HtmlEditorOptions(
                  hint: 'Write your note here...',
                  initialText: widget.note.content,
                  shouldEnsureVisible: false,
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  defaultToolbarButtons: [
                    FontButtons(),
                    ListButtons(),
                    InsertButtons(picture: true, table: true),
                  ],
                ),
                otherOptions: OtherOptions(
                  height: MediaQuery.of(context).size.height * 0.6,
                ),
                callbacks: Callbacks(
                  onFocus: () {
                    _titleFocusNode.unfocus();
                  },
                  onChangeContent: (html) {
                    _triggerSave(contentOverride: html ?? '');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
