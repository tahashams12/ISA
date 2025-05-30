import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCheckingConnection = false;
  String _connectionStatus = 'Not checked yet';
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Connection Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Connection',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Backend API Status:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _connectionStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isCheckingConnection ? null : _checkApiConnection,
                        child: _isCheckingConnection
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Check Connection'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // API Information Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('API Endpoint', ApiService.baseUrl),
                    const Divider(),
                    _buildInfoRow(
                        'Health Check', '${ApiService.baseUrl}/health'),
                    const Divider(),
                    _buildInfoRow(
                        'Reviews Endpoint', '${ApiService.baseUrl}/reviews'),
                    const Divider(),
                    _buildInfoRow('Categories Endpoint',
                        '${ApiService.baseUrl}/categories'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // About this app button
            Card(
              elevation: 2,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/about');
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'About This App',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkApiConnection() async {
    setState(() {
      _isCheckingConnection = true;
      _connectionStatus = 'Checking...';
    });

    try {
      final isConnected = await ApiService().checkHealth();

      setState(() {
        _isCheckingConnection = false;
        _isConnected = isConnected;
        _connectionStatus = isConnected ? 'Connected' : 'Disconnected';
      });
    } catch (e) {
      setState(() {
        _isCheckingConnection = false;
        _isConnected = false;
        _connectionStatus =
            'Error: ${e.toString().substring(0, min(30, e.toString().length))}...';
      });
    }
  }

  Color _getStatusColor() {
    if (_connectionStatus == 'Not checked yet') {
      return Colors.grey;
    } else if (_connectionStatus == 'Checking...') {
      return Colors.blue;
    } else if (_isConnected) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  int min(int a, int b) => a < b ? a : b;
}
