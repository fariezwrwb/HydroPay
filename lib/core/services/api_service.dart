import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';

class ApiService {
  static Future<Map<String, String>> _headers({bool withToken = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'app-key': 'cede99000e4669efd1c71a60e189ac61db29db03',
    };

    if (withToken) {
      final token = await AuthService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Uri _uri(String endpoint) =>
      Uri.parse('${ApiConstants.baseUrl}$endpoint');

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool withToken = true,
  }) async {
    final res = await http.get(
      _uri(endpoint),
      headers: await _headers(withToken: withToken),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withToken = true,
  }) async {
    final res = await http.post(
      _uri(endpoint),
      headers: await _headers(withToken: withToken),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool withToken = true,
  }) async {
    final res = await http.patch(
      _uri(endpoint),
      headers: await _headers(withToken: withToken),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool withToken = true,
  }) async {
    final res = await http.delete(
      _uri(endpoint),
      headers: await _headers(withToken: withToken),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required String filePath,
    required String fileField,
  }) async {
    final token = await AuthService.getToken();

    final request = http.MultipartRequest(
      'POST',
      _uri(endpoint),
    );

    request.headers['app-key'] = 'cede99000e4669efd1c71a60e189ac61db29db03';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }
}