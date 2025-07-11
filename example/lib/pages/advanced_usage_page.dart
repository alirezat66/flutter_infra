import 'package:flutter/material.dart';
import 'package:flutter_infra/flutter_infra.dart';

class AdvancedUsagePage extends StatefulWidget {
  const AdvancedUsagePage({super.key});

  @override
  State<AdvancedUsagePage> createState() => _AdvancedUsagePageState();
}

class _AdvancedUsagePageState extends State<AdvancedUsagePage> {
  late StorageService _storageService;
  late NetworkService _networkService;
  late TokenManager _tokenManager;

  // Storage demo values
  String _normalStorageValue = '';
  String _secureStorageValue = '';

  // Network demo values
  String _networkResponse = '';
  bool _isLoading = false;
  bool _isInitialized = false;

  // Token demo values
  String _tokenValue = '';
  String _refreshTokenValue = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Advanced Storage Service - fully customized
      _storageService = await StorageService.create(
        config: StorageConfig(
          enableLogging: true,
          encryptionKey: 'MyCustomEncryptionKey123',
        ),
      );

      // Advanced Token Manager with completely custom configuration
      _tokenManager = DefaultTokenManager(
        storage: _storageService,
        config: TokenConfig(
          tokenHeaderKey: 'X-Auth-Token',
          tokenStorageKey: 'advanced_access_token',
          tokenResponseField: 'access_token',
          tokenPrefix: 'CustomBearer',
          refreshTokenStorageKey: 'advanced_refresh_token',
          refreshTokenResponseField: 'refresh_token',
          refreshTokenEndPoint: '/api/auth/refresh',
        ),
      );

      // Advanced Network Service - completely customized
      _networkService = await NetworkService.create(
        config: NetworkConfig(
          baseUrl: 'https://jsonplaceholder.typicode.com',
          enableLogging: true,
          maxLoggerWidth: 150,
          timeout: const Duration(seconds: 45),
          defaultHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-API-Version': '3.0',
            'X-Client-Platform': 'flutter',
            'X-App-Version': '1.0.0',
          },
          interceptors: [
            const LoggerInterceptor(maxWidth: 150),
            TokenInterceptor(
              tokenManager: _tokenManager,
              // No refresh strategy for this example to avoid circular dependency
            ),
            CustomHeaderInterceptor(),
          ],
        ),
      );

      // Load existing values
      await _loadStorageValues();
      await _loadTokenValues();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing services: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadStorageValues() async {
    try {
      final normalValue =
          await _storageService.getString('advanced_demo_key') ?? '';
      final secureValue =
          await _storageService.getSecureString('advanced_secure_key') ?? '';

      setState(() {
        _normalStorageValue = normalValue;
        _secureStorageValue = secureValue;
      });
    } catch (e) {
      debugPrint('Error loading storage values: $e');
    }
  }

  Future<void> _loadTokenValues() async {
    try {
      final token = await _tokenManager.getToken() ?? '';
      final refreshToken = await _tokenManager.getRefreshToken() ?? '';
      setState(() {
        _tokenValue = token;
        _refreshTokenValue = refreshToken;
      });
    } catch (e) {
      debugPrint('Error loading tokens: $e');
    }
  }

  Future<void> _saveComplexData() async {
    try {
      final complexData = {
        'user': {
          'id': 123,
          'name': 'Advanced User',
          'preferences': {'theme': 'dark', 'notifications': true},
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _storageService.setJson('advanced_demo_key', complexData);

      setState(() {
        _normalStorageValue = complexData.toString();
      });

      _showSnackBar('Complex object saved!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _saveEncryptedSecureData() async {
    try {
      final sensitiveData = {
        'creditCard': '1234-5678-9012-3456',
        'ssn': 'XXX-XX-1234',
        'apiKeys': {
          'stripe': 'sk_test_advanced_example',
          'aws': 'AKIA_advanced_example',
        },
      };

      await _storageService.setSecureJson('advanced_secure_key', sensitiveData);

      setState(() {
        _secureStorageValue = '[ENCRYPTED] Sensitive data stored securely';
      });

      _showSnackBar('Encrypted data saved!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _saveAdvancedTokens() async {
    try {
      const accessToken = 'advanced_jwt_access_token_with_custom_claims';
      const refreshToken = 'advanced_refresh_token_with_rotation';

      await _tokenManager.saveToken(accessToken);
      await _tokenManager.saveRefreshToken(refreshToken);

      setState(() {
        _tokenValue = accessToken;
        _refreshTokenValue = refreshToken;
      });

      _showSnackBar('Advanced tokens saved!');
    } catch (e) {
      _showSnackBar('Error saving tokens: $e');
    }
  }

  Future<void> _clearAllTokens() async {
    try {
      await _tokenManager.deleteToken();
      await _tokenManager.deleteRefreshToken();

      setState(() {
        _tokenValue = '';
        _refreshTokenValue = '';
      });

      _showSnackBar('All tokens cleared!');
    } catch (e) {
      _showSnackBar('Error clearing tokens: $e');
    }
  }

  Future<void> _clearNormalStorage() async {
    try {
      await _storageService.deleteKey('advanced_demo_key');

      setState(() {
        _normalStorageValue = '';
      });

      _showSnackBar('Normal storage cleared!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _clearSecureStorage() async {
    try {
      await _storageService.deleteSecureKey('advanced_secure_key');

      setState(() {
        _secureStorageValue = '';
      });

      _showSnackBar('Secure storage cleared!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _makeRequestWithAllFeatures() async {
    setState(() {
      _isLoading = true;
      _networkResponse = '';
    });

    try {
      final response = await _networkService.get(
        '/posts/1',
        queryParameters: {
          'include': 'comments,author',
          'fields': 'id,title,body',
        },
      );

      if (response.isSuccess) {
        setState(() {
          _networkResponse =
              'Advanced GET Success!\n'
              'Status: ${response.statusCode}\n'
              'Headers: ${response.headers}\n'
              'Data: ${response.data}';
        });
      } else {
        setState(() {
          _networkResponse =
              'Advanced Error: ${response.error?.message ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _networkResponse = 'Advanced Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeComplexPostRequest() async {
    setState(() {
      _isLoading = true;
      _networkResponse = '';
    });

    try {
      final complexPayload = {
        'title': 'Advanced Usage Demo',
        'body': 'This demonstrates advanced features',
        'userId': 1,
        'metadata': {
          'client': 'flutter',
          'version': '3.0',
          'features': ['encryption', 'tokens', 'interceptors'],
        },
        'tags': ['demo', 'advanced', 'flutter-infra'],
        'settings': {
          'public': true,
          'allowComments': true,
          'category': 'tutorial',
        },
      };

      final response = await _networkService.post(
        '/posts',
        data: complexPayload,
        queryParameters: {'version': '3.0', 'format': 'json'},
      );

      if (response.isSuccess) {
        setState(() {
          _networkResponse =
              'Complex POST Success!\n'
              'Created Resource ID: ${response.data?['id']}\n'
              'Full Response: ${response.data}';
        });
      } else {
        setState(() {
          _networkResponse =
              'Complex POST Error: ${response.error?.message ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _networkResponse = 'Complex POST Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _networkService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Usage'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📙 Advanced Usage Examples',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.purple[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These examples show completely customized usage with encryption, custom interceptors, complex data handling, and advanced token management.',
                      style: TextStyle(color: Colors.purple[700]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Storage Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Advanced Storage (Encrypted)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Custom encryption and complex object storage.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // Normal Storage
                    Text(
                      'Encrypted Normal Storage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _normalStorageValue.isEmpty
                            ? 'No complex object stored'
                            : _normalStorageValue,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveComplexData,
                            child: const Text('Save Complex'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearNormalStorage,
                            child: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Secure Storage
                    Text(
                      'Encrypted Secure Storage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _secureStorageValue.isEmpty
                            ? 'No sensitive data stored'
                            : _secureStorageValue,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveEncryptedSecureData,
                            child: const Text('Save Encrypted'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearSecureStorage,
                            child: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Advanced Token Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Advanced Token Management',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Custom token configuration with refresh strategy.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Access Token:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _tokenValue.isEmpty ? 'No access token' : _tokenValue,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                      ),
                    ),

                    Text(
                      'Refresh Token:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _refreshTokenValue.isEmpty
                            ? 'No refresh token'
                            : _refreshTokenValue,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveAdvancedTokens,
                            child: const Text('Save Tokens'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearAllTokens,
                            child: const Text('Clear All'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Network Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Advanced Network Service',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Custom interceptors, complex payloads, and advanced features.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _makeRequestWithAllFeatures,
                            child: const Text('Advanced GET'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _makeComplexPostRequest,
                            child: const Text('Complex POST'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Response:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SingleChildScrollView(
                                child: Text(
                                  _networkResponse.isEmpty
                                      ? 'No advanced request made yet. Tap a button above to test advanced features.'
                                      : _networkResponse,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom interceptor for demonstration
class CustomHeaderInterceptor implements NetworkInterceptor {
  @override
  Future<void> onRequest(NetworkRequest request) async {
    request.headers['X-Timestamp'] =
        DateTime.now().millisecondsSinceEpoch.toString();
    request.headers['X-Request-Source'] = 'flutter-infra-advanced';
  }

  @override
  Future<void> onResponse(NetworkResponse response) async {
    // Could log response times, update metrics, etc.
  }

  @override
  Future<void> onError(NetworkError error) async {
    // Could send error reports, retry logic, etc.
  }
}
