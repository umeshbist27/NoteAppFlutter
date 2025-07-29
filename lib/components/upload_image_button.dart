import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noteappflu/utilis/note_editor_services.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadImageButton extends StatelessWidget {
  final Function(String) onImageUploaded;
  const UploadImageButton({super.key, required this.onImageUploaded});
  Future<void> _pickAndUpload(BuildContext context) async {
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
      final imageUrl = await NoteEditorService().uploadImage(pickedFile.path);
      onImageUploaded(imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _pickAndUpload(context),
      icon: const Icon(Icons.image),
      label: const Text("Upload Image"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }
}
