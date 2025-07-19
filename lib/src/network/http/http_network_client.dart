import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/api_client.dart';
import '../core/network_config.dart';
import '../core/network_request.dart';
import '../core/network_response.dart';
import '../core/network_error.dart';
import '../core/inceptors/logger_interceptor.dart';

/// HTTP implementation of NetworkClient using dart:io http package
class HttpNetworkClient implements NetworkClient {
  final NetworkConfig _config;
  late final http.Client _client;

  HttpNetworkClient({NetworkConfig? config})
    : _config = config ?? _getDefaultConfig() {
    _setupClient();
  }

  /// Default configuration for HTTP with LoggerInterceptor
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
  factory HttpNetworkClient.withConfig(NetworkConfig config) {
    return HttpNetworkClient(config: config);
  }

  /// Sets up HTTP client with configuration
  void _setupClient() {
    _client = http.Client();
  }

  @override
  Future<NetworkResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _makeRequest(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
    );
  }

  @override
  Future<NetworkResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _makeRequest(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  @override
  Future<NetworkResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _makeRequest(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  @override
  Future<NetworkResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _makeRequest(
      method: 'DELETE',
      path: path,
      queryParameters: queryParameters,
    );
  }

  /// Makes an HTTP request with interceptor support
  Future<NetworkResponse> _makeRequest({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // Build request
      final request = NetworkRequest(
        method: method,
        path: path,
        queryParameters: queryParameters,
        body: data,
        headers: Map<String, String>.from(_config.defaultHeaders),
      );

      // Apply request interceptors
      for (final interceptor in _config.interceptors) {
        await interceptor.onRequest(request);
      }

      // Perform the actual HTTP request
      final response = await _performRequest(request);

      // Apply response interceptors
      for (final interceptor in _config.interceptors) {
        await interceptor.onResponse(response);
      }

      return response;
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Performs the actual HTTP request
  Future<NetworkResponse> _performRequest(NetworkRequest request) async {
    final uri = _buildUri(request.path, request.queryParameters);
    final headers = request.headers;
    final bodyData = _encodeBody(request.body);

    http.Response response;

    try {
      switch (request.method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(_config.timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: bodyData)
              .timeout(_config.timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: bodyData)
              .timeout(_config.timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(_config.timeout);
          break;
        default:
          throw NetworkError(
            message: 'Unsupported HTTP method: ${request.method}',
            code: 400,
          );
      }

      final responseData = _parseResponseData(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return NetworkResponse(
          statusCode: response.statusCode,
          data: responseData,
          headers: _convertHeaders(response.headers),
        );
      } else {
        final error = NetworkError(
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          code: response.statusCode,
        );
        return NetworkResponse(
          statusCode: response.statusCode,
          data: responseData,
          error: error,
          headers: _convertHeaders(response.headers),
        );
      }
    } on SocketException catch (e) {
      throw NetworkError(
        message: 'Connection failed: ${e.message}',
        originalException: e,
      );
    } on HttpException catch (e) {
      throw NetworkError(
        message: 'HTTP error: ${e.message}',
        originalException: e,
      );
    } on FormatException catch (e) {
      throw NetworkError(
        message: 'Invalid response format: ${e.message}',
        originalException: e,
      );
    } catch (e) {
      throw NetworkError(
        message: 'Request failed: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// Handles errors and converts them to NetworkResponse
  NetworkResponse _handleError(dynamic error) {
    NetworkError networkError;

    if (error is NetworkError) {
      networkError = error;
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
      statusCode: networkError.code ?? 0,
      error: networkError,
    );
  }

  /// Builds the complete URI with base URL and query parameters
  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    String finalUrl = path;

    // Add base URL if provided and path is not absolute
    if (_config.baseUrl != null && !path.startsWith('http')) {
      final baseUrl =
          _config.baseUrl!.endsWith('/')
              ? _config.baseUrl!.substring(0, _config.baseUrl!.length - 1)
              : _config.baseUrl!;
      final requestPath = path.startsWith('/') ? path : '/$path';
      finalUrl = '$baseUrl$requestPath';
    }

    final uri = Uri.parse(finalUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryParams = queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      return uri.replace(
        queryParameters: {...uri.queryParameters, ...queryParams},
      );
    }

    return uri;
  }

  /// Encodes the request body
  String? _encodeBody(dynamic body) {
    if (body == null) return null;

    if (body is String) {
      return body;
    } else if (body is Map || body is List) {
      return jsonEncode(body);
    } else {
      return body.toString();
    }
  }

  /// Parses response data
  dynamic _parseResponseData(String responseBody) {
    if (responseBody.isEmpty) return null;

    try {
      return jsonDecode(responseBody);
    } catch (e) {
      return responseBody;
    }
  }

  /// Converts http package headers to Map&lt;String,String&gt;
  Map<String, String> _convertHeaders(Map<String, String> headers) {
    return Map<String, String>.from(headers);
  }

  /// Disposes the HTTP client
  void dispose() {
    _client.close();
  }
}
