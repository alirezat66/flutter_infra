import 'package:flutter/material.dart';
import 'pages/default_usage_page.dart';
import 'pages/common_usage_page.dart';
import 'pages/advanced_usage_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infra Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Infra Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚀 Flutter Infra Package Examples',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explore different usage patterns for storage and network services. '
                      'Each example demonstrates a different level of customization.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Example Cards
            Expanded(
              child: Column(
                children: [
                  // Default Usage Card
                  Expanded(
                    child: _ExampleCard(
                      title: '📘 Default Usage',
                      subtitle: 'Basic setup with minimal configuration',
                      description:
                          'Learn the simplest way to use storage and network services '
                          'with default settings and basic features.',
                      color: Colors.blue,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DefaultUsagePage(),
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Common Usage Card
                  Expanded(
                    child: _ExampleCard(
                      title: '📗 Common Usage',
                      subtitle: 'Partially customized with popular features',
                      description:
                          'Explore common patterns with logging, authentication, '
                          'custom headers, and token management.',
                      color: Colors.green,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CommonUsagePage(),
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Advanced Usage Card
                  Expanded(
                    child: _ExampleCard(
                      title: '📙 Advanced Usage',
                      subtitle: 'Completely customized implementation',
                      description:
                          'Master advanced features like encryption, custom interceptors, '
                          'complex data handling, and refresh token strategies.',
                      color: Colors.purple,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdvancedUsagePage(),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Footer
            Text(
              'Each example is self-contained and demonstrates different aspects of the flutter_infra package.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color.withValues(alpha: 0.6),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.6),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
