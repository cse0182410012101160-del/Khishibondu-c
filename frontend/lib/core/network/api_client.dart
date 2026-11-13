import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/cache_service.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  final CacheService _cacheService;

  ApiClient(this._cacheService, {String? customBaseUrl}) {
    // Detect environment or emulator
    String baseUrl = customBaseUrl ?? AppConstants.localhostBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      baseUrl = customBaseUrl ?? AppConstants.defaultBaseUrl;
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _cacheService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('🌐 [DIO REQ] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ [DIO RES] ${response.statusCode} ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            print('❌ [DIO ERR] ${error.response?.statusCode} ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get client => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}

