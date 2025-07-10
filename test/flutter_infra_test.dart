// Main test runner that imports all test suites
import 'preferences_storage_impl_test.dart' as preferences_tests;
import 'secure_storage_impl_test.dart' as secure_tests;
import 'storage_service_test.dart' as service_tests;
import 'storage_config_test.dart' as config_tests;
import 'typed_storage_ext_test.dart' as typed_tests;

void main() {
  // Run all test suites
  preferences_tests.main();
  secure_tests.main();
  service_tests.main();
  config_tests.main();
  typed_tests.main();
}
