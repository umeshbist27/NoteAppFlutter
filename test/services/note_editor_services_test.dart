import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:noteappflu/utilis/note_editor_services.dart';
import 'note_editor_services_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late NoteEditorService service;

  setUp(() async {
    mockDio = MockDio();
    when(mockDio.options).thenReturn(BaseOptions());
    dotenv.testLoad(fileInput: 'BASE_URL=https://example.com');
    service = NoteEditorService(dio: mockDio);
    SharedPreferences.setMockInitialValues({"token": "test-token"});
  });

  test('uploads image successfully and returns URL', () async {
    when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
      (_) async => Response(
        statusCode: 200,
        data: {"imageUrl": "https://cdn.test/image.png"},
        requestOptions: RequestOptions(path: ''),
      ),
    );

    final imageUrl = await service.uploadImage('test/assets/image.png');
    expect(imageUrl, "https://cdn.test/image.png");
  });

  test('throws exception if image upload fails', () async {
    when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
      (_) async => Response(
        statusCode: 400,
        data: {"error": "Invalid"},
        requestOptions: RequestOptions(path: ''),
      ),
    );

    expect(
      () async => await service.uploadImage('test/assets/image.png'),
      throwsException,
    );
  });

  test('sets Authorization header from SharedPreferences token', () async {
    when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
      (_) async => Response(
        statusCode: 200,
        data: {"imageUrl": "https://cdn.test/image.png"},
        requestOptions: RequestOptions(path: ''),
      ),
    );
    await service.uploadImage('test/assets/image.png');
    expect(service.headers['Authorization'], 'Bearer test-token');
  });
}