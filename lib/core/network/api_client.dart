import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../services/language_service.dart';
import 'api_constants.dart';
import 'auth_session_manager.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
  });

  bool get isOk => success && statusCode >= 200 && statusCode < 300;
  String? get error => message;

  dynamic operator [](String key) {
    if (key == 'success') return success;
    if (key == 'data') return data;
    if (key == 'message') return message;
    if (key == 'statusCode') return statusCode;
    if (data is Map) {
      return (data as Map)[key];
    }
    return null;
  }
}

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  factory ApiClient() => instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 15);

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final lang = LanguageService.instance.currentLanguage;
    final token = AuthSessionManager.instance.token;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': lang,
      'ngrok-skip-browser-warning': 'true', // ngrok browser warning skip
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams, bool includeLang = true]) {
    final base = ApiConstants.baseUrl;
    final fullUrl = '$base$path';
    final parsedUri = Uri.parse(fullUrl);

    // Do not append ?lang= query parameter for upload routes or when includeLang is false
    final shouldIncludeLang = includeLang && !path.contains('/upload');
    final lang = LanguageService.instance.currentLanguage;

    final params = Map<String, String>.from(parsedUri.queryParameters);

    if (shouldIncludeLang && !params.containsKey('lang')) {
      params['lang'] = lang;
    }

    if (queryParams != null && queryParams.isNotEmpty) {
      queryParams.forEach((key, value) {
        if (value != null) {
          params[key] = value.toString();
        }
      });
    }

    return parsedUri.replace(queryParameters: params);
  }

  // GET
  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final response = await _client
          .get(uri, headers: _buildHeaders(headers))
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] GET $path error: $e');
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  // POST
  Future<ApiResponse<dynamic>> post(
    String path, [
    dynamic body,
    Map<String, String>? headers,
  ]) async {
    try {
      final uri = _buildUri(path);
      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await _client
          .post(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] POST $path error: $e');
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  // PUT
  Future<ApiResponse<dynamic>> put(
    String path, [
    dynamic body,
    Map<String, String>? headers,
  ]) async {
    try {
      final uri = _buildUri(path);
      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await _client
          .put(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] PUT $path error: $e');
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  // DELETE
  Future<ApiResponse<dynamic>> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] DELETE $path error: $e');
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  // POST Multipart (File Upload)
  Future<ApiResponse<dynamic>> postMultipart(
    String path, {
    required String fileField,
    required List<int> bytes,
    required String filename,
    String? mimeType,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, null, false);
      final request = http.MultipartRequest('POST', uri);

      final reqHeaders = _buildHeaders(headers);
      reqHeaders.remove('Content-Type');
      request.headers.addAll(reqHeaders);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      String validFilename = filename;
      String ext = '';
      if (validFilename.contains('.')) {
        ext = validFilename.split('.').last.toLowerCase();
      }

      final allowedExts = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
      if (ext.isEmpty || !allowedExts.contains(ext)) {
        validFilename = '${validFilename.split('.').first}.jpg';
        ext = 'jpg';
      }

      MediaType? parsedContentType;
      if (mimeType != null && mimeType.startsWith('image/')) {
        try {
          parsedContentType = MediaType.parse(mimeType);
        } catch (_) {}
      }

      if (parsedContentType == null) {
        if (ext == 'png') {
          parsedContentType = MediaType('image', 'png');
        } else if (ext == 'webp') {
          parsedContentType = MediaType('image', 'webp');
        } else if (ext == 'gif') {
          parsedContentType = MediaType('image', 'gif');
        } else {
          parsedContentType = MediaType('image', 'jpeg');
        }
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          bytes,
          filename: validFilename,
          contentType: parsedContentType,
        ),
      );

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] POST Multipart $path error: $e');
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  ApiResponse<dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return ApiResponse(
          success: decoded['success'] == true,
          message: decoded['message']?.toString(),
          data: decoded['data'] ?? decoded,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        data: decoded,
        statusCode: response.statusCode,
      );
    } catch (_) {
      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        message: response.body,
        statusCode: response.statusCode,
      );
    }
  }
}
