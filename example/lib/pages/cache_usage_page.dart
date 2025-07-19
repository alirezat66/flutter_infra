import 'package:flutter/material.dart';
import 'package:flutter_infra/flutter_infra.dart';

class CacheUsagePage extends StatefulWidget {
  const CacheUsagePage({super.key});

  @override
  State<CacheUsagePage> createState() => _CacheUsagePageState();
}

class _CacheUsagePageState extends State<CacheUsagePage> {
  late NetworkService _networkService;
  Map<String, dynamic>? _lastResponse;
  Map<String, dynamic>? _cacheStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeNetworkService();
  }

  void _initializeNetworkService() async {
    // Create a cache configuration
    final cacheConfig = CacheConfig(
      defaultCacheDuration: const Duration(minutes: 5),
      maxCacheSize: 50,
      cacheOnlyGetRequests: true,
      customCacheDurations: {
        '/posts': const Duration(minutes: 10), // Cache posts for 10 minutes
        '/users': const Duration(hours: 1), // Cache users for 1 hour
      },
      noCacheEndpoints: {
        '/auth/login', // Never cache login requests
        '/upload', // Never cache upload requests
      },
    );

    // Create network service with caching
    _networkService = await NetworkService.createWithCache(
      config: NetworkConfig(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        enableLogging: true,
      ),
      cacheConfig: cacheConfig,
    );

    _updateCacheStats();
  }

  void _updateCacheStats() {
    setState(() {
      _cacheStats = _networkService.getCacheStats();
    });
  }

  Future<void> _makeRequest(String endpoint) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _networkService.getJson(endpoint);
      setState(() {
        _lastResponse = response;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _updateCacheStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Usage Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cache Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cache Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Cache Enabled: ${_networkService.isCacheEnabled}'),
                    if (_cacheStats != null) ...[
                      Text('Total Entries: ${_cacheStats!['totalEntries']}'),
                      Text('Valid Entries: ${_cacheStats!['validEntries']}'),
                      Text(
                        'Expired Entries: ${_cacheStats!['expiredEntries']}',
                      ),
                      Text('Max Size: ${_cacheStats!['maxSize']}'),
                      Text('Hit Rate: ${_cacheStats!['hitRate']}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Request Buttons
            Text(
              'Test Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _makeRequest('/posts/1'),
                    child: const Text('Get Post 1'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _makeRequest('/users/1'),
                    child: const Text('Get User 1'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _makeRequest('/posts'),
                    child: const Text('Get All Posts'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _makeRequest('/users'),
                    child: const Text('Get All Users'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cache Control Buttons
            Text(
              'Cache Controls',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _networkService.clearCache();
                      _updateCacheStats();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache cleared')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Clear All Cache'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _networkService.clearCacheForEndpoint('/posts');
                      _updateCacheStats();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Posts cache cleared')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Clear Posts Cache'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Response Display
            Text(
              'Last Response',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _lastResponse == null
                          ? const Center(
                            child: Text('Make a request to see the response'),
                          )
                          : SingleChildScrollView(
                            child: Text(
                              _lastResponse.toString(),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1. Make the same request twice to see cache in action',
                    ),
                    Text('2. Check the cache statistics after each request'),
                    Text('3. Notice the x-cache header in responses'),
                    Text('4. Try clearing cache and making requests again'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _networkService.dispose();
    super.dispose();
  }
}
