import 'dart:async';

import 'package:flutter_infra/src/network/core/network_error.dart';
import 'package:flutter_infra/src/network/core/network_request.dart';
import 'package:flutter_infra/src/network/core/network_response.dart';

abstract class NetworkInterceptor {
  FutureOr<void> onRequest(NetworkRequest request);
  FutureOr<void> onResponse(NetworkResponse response);
  FutureOr<void> onError(NetworkError error);
}
