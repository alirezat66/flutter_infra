import 'package:dio/dio.dart';
import 'package:flutter_infra/flutter_infra.dart';

class NetworkInterceptorAdapter extends Interceptor {
  final NetworkInterceptor interceptor;

  NetworkInterceptorAdapter(this.interceptor);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final networkRequest = NetworkRequest(
        method: options.method,
        path: options.path,
        headers: Map<String, String>.from(
          options.headers.cast<String, String>(),
        ),
        queryParameters: options.queryParameters,
        body: options.data,
      );

      await interceptor.onRequest(networkRequest);

      // Apply any changes back to the request options
      options.headers.clear();
      options.headers.addAll(networkRequest.headers);
      options.queryParameters.clear();
      options.queryParameters.addAll(networkRequest.queryParameters ?? {});
      options.data = networkRequest.body;

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          message: 'Interceptor error: ${e.toString()}',
        ),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      final networkResponse = NetworkResponse(
        statusCode: response.statusCode ?? 0,
        data: response.data,
        headers: _convertHeaders(response.headers),
      );

      await interceptor.onResponse(networkResponse);

      handler.next(response);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: e,
          message: 'Response interceptor error: ${e.toString()}',
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final networkError = NetworkError(
        message: err.message ?? 'Unknown error',
        code: err.response?.statusCode,
        originalException: err,
      );

      await interceptor.onError(networkError);

      handler.next(err);
    } catch (e) {
      handler.next(err);
    }
  }

  Map<String, String> _convertHeaders(Headers headers) {
    final result = <String, String>{};
    headers.forEach((key, values) {
      if (values.isNotEmpty) {
        result[key] = values.first;
      }
    });
    return result;
  }
}
