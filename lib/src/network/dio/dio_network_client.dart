import 'package:dio/dio.dart';
import 'package:flutter_infra/src/network/dio/network_interceptor_adapter.dart';
import '../core/api_client.dart';
import '../core/network_config.dart';
import '../core/network_response.dart';
import '../core/network_error.dart';
import '../core/inceptors/logger_interceptor.dart';

/// Dio implementation of NetworkClient with advanced features
class DioNetworkClient implements NetworkClient {
  final NetworkConfig _config;
  late final Dio _dio;

  DioNetworkClient({NetworkConfig? config})
    : _config = config ?? _getDefaultConfig() {
    _setupDio();
  }

  /// Default configuration for Dio with LoggerInterceptor
  /// TokenInterceptor can be added when storage is available
  static NetworkConfig _getDefaultConfig() {
    return NetworkConfig(
      enableLogging: true,
      interceptors: [
        const LoggerInterceptor(),
        // TokenInterceptor is not included by default to avoid storage dependency
        // Users can add it when they configure storage
      ],
    );
  }

  /// Creates an instance with custom configuration
  factory DioNetworkClient.withConfig(NetworkConfig config) {
    return DioNetworkClient(config: config);
  }

  /// Sets up Dio with configuration
  void _setupDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl ?? '',
        connectTimeout: _config.timeout,
        receiveTimeout: _config.timeout,
        sendTimeout: _config.timeout,
        headers: _config.defaultHeaders,
      ),
    );

    // Add custom interceptors (LoggerInterceptor by default, TokenInterceptor can be added via config)
    for (final interceptor in _config.interceptors) {
      _dio.interceptors.add(NetworkInterceptorAdapter(interceptor));
    }
  }

  @override
  Future<NetworkResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _convertResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<NetworkResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _convertResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<NetworkResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _convertResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<NetworkResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return _convertResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Converts Dio response to NetworkResponse
  NetworkResponse _convertResponse(Response response) {
    return NetworkResponse(
      statusCode: response.statusCode ?? 0,
      data: response.data,
      headers: _convertHeaders(response.headers),
    );
  }

  /// Converts Dio headers to Map<String,String>
  Map<String, String> _convertHeaders(Headers headers) {
    final result = <String, String>{};
    headers.forEach((key, values) {
      if (values.isNotEmpty) {
        result[key] = values.first;
      }
    });
    return result;
  }

  /// Handles errors and converts them to NetworkResponse
  NetworkResponse _handleError(dynamic error) {
    NetworkError networkError;
    int statusCode = 0;
    dynamic responseData;
    Map<String, String>? headers;

    if (error is DioException) {
      statusCode = error.response?.statusCode ?? 0;
      responseData = error.response?.data;
      headers =
          error.response?.headers != null
              ? _convertHeaders(error.response!.headers)
              : null;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          networkError = NetworkError(
            message: 'Request timeout: ${error.message}',
            code: statusCode,
            originalException: error,
          );
          break;
        case DioExceptionType.connectionError:
          networkError = NetworkError(
            message: 'Connection error: ${error.message}',
            code: statusCode,
            originalException: error,
          );
          break;
        case DioExceptionType.badResponse:
          networkError = NetworkError(
            message: 'Bad response: ${error.message}',
            code: statusCode,
            originalException: error,
          );
          break;
        case DioExceptionType.cancel:
          networkError = NetworkError(
            message: 'Request cancelled: ${error.message}',
            originalException: error,
          );
          break;
        case DioExceptionType.unknown:
          networkError = NetworkError(
            message: 'Unknown error: ${error.message}',
            code: statusCode,
            originalException: error,
          );
          break;
        default:
          networkError = NetworkError(
            message: 'Request failed: ${error.message}',
            code: statusCode,
            originalException: error,
          );
      }
    } else {
      networkError = NetworkError(
        message: 'Unexpected error: ${error.toString()}',
        originalException: error,
      );
    }

    // Apply error interceptors
    for (final interceptor in _config.interceptors) {
      interceptor.onError(networkError);
    }

    return NetworkResponse(
      statusCode: statusCode,
      data: responseData,
      error: networkError,
      headers: headers,
    );
  }

  /// Disposes the Dio instance
  void dispose() {
    _dio.close();
  }
}
