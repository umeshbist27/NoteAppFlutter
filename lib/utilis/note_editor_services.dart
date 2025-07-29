import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteEditorService {
  final Dio _dio;

  NoteEditorService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = dotenv.env['BASE_URL'] ?? '';
  }
  Map<String, dynamic> get headers => _dio.options.headers;

  Future<String> uploadImage(String imagePath) async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imagePath),
    });
    final response = await _dio.post('/api/notes/upload-image', data: formData);

    if (response.statusCode == 200 && response.data["imageUrl"] != null) {
      return response.data["imageUrl"];
    } else {
      throw Exception("Failed to upload image: ${response.data}");
    }
  }
}
