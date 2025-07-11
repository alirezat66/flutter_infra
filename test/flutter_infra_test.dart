// Main test runner that imports all test suites
// Storage tests
import 'storage/preferences_storage_impl_test.dart' as preferences_tests;
import 'storage/secure_storage_impl_test.dart' as secure_tests;
import 'storage/storage_service_test.dart' as service_tests;
import 'storage/storage_config_test.dart' as config_tests;
import 'storage/typed_storage_ext_test.dart' as typed_tests;

// Network tests
import 'network/network_service_test.dart' as network_service_tests;
import 'network/network_comparison_test.dart' as network_comparison_tests;
import 'network/http/http_network_client_test.dart' as http_client_tests;
import 'network/dio/dio_network_client_test.dart' as dio_client_tests;
import 'network/core/network_config_test.dart' as network_config_tests;
import 'network/core/inceptors/logger_interceptor_test.dart'
    as logger_interceptor_tests;

void main() {
  // Run all storage test suites
  preferences_tests.main();
  secure_tests.main();
  service_tests.main();
  config_tests.main();
  typed_tests.main();

  // Run all network test suites
  network_service_tests.main();
  network_comparison_tests.main();
  http_client_tests.main();
  dio_client_tests.main();
  network_config_tests.main();
  logger_interceptor_tests.main();
}
