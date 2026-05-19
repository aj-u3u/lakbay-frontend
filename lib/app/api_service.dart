import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers for URL and token
final backendUrlProvider = StateNotifierProvider<BackendUrlNotifier, String>((ref) {
  return BackendUrlNotifier();
});

final authTokenProvider = StateNotifierProvider<AuthTokenNotifier, String?>((ref) {
  return AuthTokenNotifier();
});

class BackendUrlNotifier extends StateNotifier<String> {
  BackendUrlNotifier() : super(defaultUrl) {
    _init();
  }

  static String get defaultUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static const String _key = 'backend_url';

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_key);
    if (url != null && url.isNotEmpty) {
      state = url;
    }
  }

  Future<void> setUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
    state = url;
  }
}

class AuthTokenNotifier extends StateNotifier<String?> {
  AuthTokenNotifier() : super(null) {
    _init();
  }

  static const String _key = 'auth_token';

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, token);
    }
    state = token;
  }
}

// ApiService provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final baseUrl = ref.watch(backendUrlProvider);
  final token = ref.watch(authTokenProvider);
  return ApiService(baseUrl: baseUrl, token: token, ref: ref);
});

class ApiService {
  final String baseUrl;
  final String? token;
  final Ref ref;
  late final Dio _dio;

  ApiService({required this.baseUrl, required this.token, required this.ref}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));

    // Optional logger interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('API Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('API Response: ${response.statusCode} ${response.realUri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('API Error: ${e.message} - ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  // Authentication: Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['access_token'] as String?;
        if (token != null) {
          await ref.read(authTokenProvider.notifier).setToken(token);
        }
        return data;
      } else {
        throw Exception(response.data['detail'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      throw Exception(detail ?? e.message ?? 'Server error during login');
    }
  }

  // Authentication: Register
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['detail'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      throw Exception(detail ?? e.message ?? 'Server error during registration');
    }
  }

  // AI Recommendation
  Future<Map<String, dynamic>> getAIRecommendation(String prompt) async {
    try {
      final response = await _dio.post('/ai-recommendation/ai/recommend', data: {
        'prompt': prompt,
      });

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['detail'] ?? 'Failed to get recommendations');
      }
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      throw Exception(detail ?? e.message ?? 'Server error during recommendation');
    }
  }
}
