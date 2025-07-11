import 'package:flutter/material.dart';
import 'package:flutter_infra/flutter_infra.dart';

class DefaultUsagePage extends StatefulWidget {
  const DefaultUsagePage({super.key});

  @override
  State<DefaultUsagePage> createState() => _DefaultUsagePageState();
}

class _DefaultUsagePageState extends State<DefaultUsagePage> {
  late StorageService _storageService;
  late NetworkService _networkService;

  // Storage demo values
  String _normalStorageValue = '';
  String _secureStorageValue = '';

  // Network demo values
  String _networkResponse = '';
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Default Storage Service - using factory method
      _storageService = await StorageService.create();

      // Default Network Service - minimal configuration
      _networkService = await NetworkService.create(
        config: NetworkConfig(baseUrl: 'https://jsonplaceholder.typicode.com'),
      );

      // Load existing storage values
      await _loadStorageValues();

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
          await _storageService.getString('default_demo_key') ?? '';
      final secureValue =
          await _storageService.getSecureString('default_secure_key') ?? '';

      setState(() {
        _normalStorageValue = normalValue;
        _secureStorageValue = secureValue;
      });
    } catch (e) {
      debugPrint('Error loading storage values: $e');
    }
  }

  Future<void> _saveToNormalStorage() async {
    try {
      const value = 'Default normal storage value';
      await _storageService.setString('default_demo_key', value);

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
      const value = 'Default secure storage value';
      await _storageService.setSecureString('default_secure_key', value);

      setState(() {
        _secureStorageValue = value;
      });

      _showSnackBar('Saved to secure storage!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _clearNormalStorage() async {
    try {
      await _storageService.deleteKey('default_demo_key');

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
      await _storageService.deleteSecureKey('default_secure_key');

      setState(() {
        _secureStorageValue = '';
      });

      _showSnackBar('Secure storage cleared!');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _makeNetworkRequest() async {
    setState(() {
      _isLoading = true;
      _networkResponse = '';
    });

    try {
      final response = await _networkService.get('/posts/1');

      if (response.isSuccess) {
        setState(() {
          _networkResponse = 'Success! Response: ${response.data}';
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

  Future<void> _makePostRequest() async {
    setState(() {
      _isLoading = true;
      _networkResponse = '';
    });

    try {
      final response = await _networkService.post(
        '/posts',
        data: {
          'title': 'Default Usage Demo',
          'body': 'This is a demo post using default configuration',
          'userId': 1,
        },
      );

      if (response.isSuccess) {
        setState(() {
          _networkResponse = 'POST Success! Response: ${response.data}';
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
        title: const Text('Default Usage'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📘 Default Usage Examples',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.blue[800]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These examples show the most basic usage of flutter_infra services with minimal configuration.',
                      style: TextStyle(color: Colors.blue[700]),
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
                      'Storage Service (Default)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Uses StorageService.create() with default implementations.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // Normal Storage
                    Text(
                      'Normal Storage',
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
                      'Secure Storage',
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

            // Network Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Network Service (Default)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Basic NetworkService with minimal configuration (only baseUrl).',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _makeNetworkRequest,
                            child: const Text('GET Request'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _makePostRequest,
                            child: const Text('POST Request'),
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
