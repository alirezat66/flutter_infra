import 'package:flutter/material.dart';
import 'package:flutter_infra/flutter_infra.dart';

class CommonUsagePage extends StatefulWidget {
  const CommonUsagePage({super.key});

  @override
  State<CommonUsagePage> createState() => _CommonUsagePageState();
}

class _CommonUsagePageState extends State<CommonUsagePage> {
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

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Common Storage Service - with some custom config
      _storageService = await StorageService.create(
        config: StorageConfig(enableLogging: true),
      );

      // Token Manager for authentication
      _tokenManager = DefaultTokenManager(
        storage: _storageService,
        config: TokenConfig(
          tokenStorageKey: 'user_auth_token',
          refreshTokenStorageKey: 'user_refresh_token',
        ),
      );

      // Common Network Service - with logging and token support
      _networkService = await NetworkService.createWithTokenSupport(
        config: NetworkConfig(
          baseUrl: 'https://jsonplaceholder.typicode.com',
          enableLogging: true,
          timeout: const Duration(seconds: 15),
          defaultHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'FlutterInfraDemo/1.0',
          },
        ),
        tokenManager: _tokenManager,
      );

      // Load existing values
      await _loadStorageValues();
      await _loadTokenValue();

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
          await _storageService.getString('common_demo_key') ?? '';
      final secureValue =
          await _storageService.getSecureString('common_secure_key') ?? '';

      setState(() {
        _normalStorageValue = normalValue;
        _secureStorageValue = secureValue;
      });
    } catch (e) {
      debugPrint('Error loading storage values: $e');
    }
  }

  Future<void> _loadTokenValue() async {
    try {
      final token = await _tokenManager.getToken() ?? '';
      setState(() {
        _tokenValue = token;
      });
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  Future<void> _saveToNormalStorage() async {
    try {
      const value = 'Common usage - normal storage with custom config';
      await _storageService.setString('common_demo_key', value);

      setState(() {
        _normalStorageValue = value;
      });

      _showSnackBar('Saved to normal storage!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _saveToSecureStorage() async {
    try {
      const value = 'Common usage - secure storage with custom key';
      await _storageService.setSecureString('common_secure_key', value);

      setState(() {
        _secureStorageValue = value;
      });

      _showSnackBar('Saved to secure storage!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _saveToken() async {
    try {
      const token = 'demo_jwt_token_common_usage_example';
      await _tokenManager.saveToken(token);

      setState(() {
        _tokenValue = token;
      });

      _showSnackBar('Token saved!');
    } catch (e) {
      _showSnackBar('Error saving token: $e');
    }
  }

  Future<void> _clearToken() async {
    try {
      await _tokenManager.deleteToken();

      setState(() {
        _tokenValue = '';
      });

      _showSnackBar('Token cleared!');
    } catch (e) {
      _showSnackBar('Error clearing token: $e');
    }
  }

  Future<void> _clearNormalStorage() async {
    try {
      await _storageService.deleteKey('common_demo_key');

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
      await _storageService.deleteSecureKey('common_secure_key');

      setState(() {
        _secureStorageValue = '';
      });

      _showSnackBar('Secure storage cleared!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _makeAuthenticatedRequest() async {
    setState(() {
      _isLoading = true;
      _networkResponse = '';
    });

    try {
      final response = await _networkService.get(
        '/posts/1',
        queryParameters: {'include': 'comments'},
      );

      if (response.isSuccess) {
        setState(() {
          _networkResponse =
              'Authenticated GET Success! Response: ${response.data}';
        });
      } else {
        setState(() {
          _networkResponse =
              'Error: ${response.error?.message ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _networkResponse = 'Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePostWithHeaders() async {
    setState(() {
      _isLoading = true;
      _networkResponse = '';
    });

    try {
      final response = await _networkService.post(
        '/posts',
        data: {
          'title': 'Common Usage Demo',
          'body':
              'This post demonstrates common usage patterns with custom headers',
          'userId': 1,
        },
        queryParameters: {'version': '2.0'},
      );

      if (response.isSuccess) {
        setState(() {
          _networkResponse =
              'POST with Headers Success! Response: ${response.data}';
        });
      } else {
        setState(() {
          _networkResponse =
              'POST Error: ${response.error?.message ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _networkResponse = 'POST Exception: $e';
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
        title: const Text('Common Usage'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📗 Common Usage Examples',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These examples show typical usage patterns with some customization like logging, custom headers, and token management.',
                      style: TextStyle(color: Colors.green[700]),
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
                      'Storage Service (Common Config)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Custom StorageConfig with logging enabled.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // Normal Storage
                    Text(
                      'Normal Storage (Custom Config)',
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
                            ? 'No value stored'
                            : _normalStorageValue,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveToNormalStorage,
                            child: const Text('Save'),
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
                      'Secure Storage (Custom Key)',
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
                            ? 'No value stored'
                            : _secureStorageValue,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveToSecureStorage,
                            child: const Text('Save'),
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

            // Token Management Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Token Management',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Custom token manager with custom storage keys.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _tokenValue.isEmpty ? 'No token stored' : _tokenValue,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveToken,
                            child: const Text('Save Token'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearToken,
                            child: const Text('Clear Token'),
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
                      'Network Service (With Auth & Logging)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NetworkService with token support, logging, custom headers, and timeout.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _makeAuthenticatedRequest,
                            child: const Text('Auth GET'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _makePostWithHeaders,
                            child: const Text('POST + Headers'),
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
                      height: 200,
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
                                      ? 'No request made yet. Tap a button above to make a request.'
                                      : _networkResponse,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
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
