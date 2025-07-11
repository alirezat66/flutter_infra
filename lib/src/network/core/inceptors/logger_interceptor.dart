import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_infra/src/network/core/network_error.dart';
import 'package:flutter_infra/src/network/core/network_interceptor.dart';
import 'package:flutter_infra/src/network/core/network_request.dart';
import 'package:flutter_infra/src/network/core/network_response.dart';

class LoggerInterceptor implements NetworkInterceptor {
  final int maxWidth;
  const LoggerInterceptor({this.maxWidth = 200});

  @override
  Future<void> onRequest(NetworkRequest request) async {
    _log('➡️ [${request.method}] ${request.path}');
    if (request.queryParameters != null &&
        request.queryParameters!.isNotEmpty) {
      _log('Query: ${jsonEncode(request.queryParameters)}');
    }
    if (request.body != null) {
      _log('Body: ${jsonEncode(request.body)}');
    }
    _log('Headers: ${jsonEncode(request.headers)}');
  }

  @override
  Future<void> onResponse(NetworkResponse response) async {
    _log(
      '✅ [${response.statusCode}] Response: ${_trim(jsonEncode(response.data))}',
    );
  }

  @override
  Future<void> onError(NetworkError error) async {
    _log('❌ [${error.code ?? '???'}] Error: ${error.message}');
  }

  void _log(String message) {
    for (final chunk in _chunk(message)) {
      debugPrint(chunk);
    }
  }

  List<String> _chunk(String str) {
    final chunks = <String>[];
    for (int i = 0; i < str.length; i += maxWidth) {
      chunks.add(
        str.substring(i, i + maxWidth > str.length ? str.length : i + maxWidth),
      );
    }
    return chunks;
  }

  String _trim(String str) {
    return str.length > maxWidth ? '${str.substring(0, maxWidth)}...' : str;
  }
}
