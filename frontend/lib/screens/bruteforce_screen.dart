import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../providers/report_provider.dart';

class BruteforceScreen extends StatefulWidget {
  const BruteforceScreen({super.key});

  @override
  State<BruteforceScreen> createState() => _BruteforceScreenState();
}

class _BruteforceScreenState extends State<BruteforceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetIpController = TextEditingController();
  final _usernameListController = TextEditingController();
  final _passwordListController = TextEditingController();
  final _portController = TextEditingController();
  
  String _service = 'ssh';
  bool _isRunning = false;
  String _output = '';

  final List<Map<String, String>> _services = [
    {'value': 'ssh', 'label': 'SSH'},
    {'value': 'ftp', 'label': 'FTP'},
    {'value': 'http', 'label': 'HTTP'},
    {'value': 'https', 'label': 'HTTPS'},
    {'value': 'telnet', 'label': 'Telnet'},
    {'value': 'mysql', 'label': 'MySQL'},
    {'value': 'postgresql', 'label': 'PostgreSQL'},
    {'value': 'smb', 'label': 'SMB'},
  ];

  @override
  void dispose() {
    _targetIpController.dispose();
    _usernameListController.dispose();
    _passwordListController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _startBruteforce() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isRunning = true;
      _output = 'Starting bruteforce attack...\n';
    });

    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);

      final result = await apiProvider.bruteforce(
        service: _service,
        targetIp: _targetIpController.text,
        usernameList: _usernameListController.text,
        passwordList: _passwordListController.text,
        port: _portController.text.isEmpty ? null : int.parse(_portController.text),
      );

      setState(() {
        _output += result['output'] ?? 'No output\n';
        if (result['errors']?.isNotEmpty == true) {
          _output += '\nErrors:\n${result['errors']}';
        }
      });

      // Save to local reports
      await reportProvider.addReport({
        'id': result['report_id'],
        'type': 'bruteforce',
        'target': '$_service://${_targetIpController.text}',
        'results': result['output'],
        'status': result['status'],
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bruteforce completed!')),
      );
    } catch (e) {
      setState(() {
        _output += '\nError: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bruteforce failed: $e')),
      );
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bruteforce Attack',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Color(0xFFE94560),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '⚠️ WARNING: Use only on systems you have authorization to test!',
            style: TextStyle(color: Colors.orangeAccent, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _service,
                            decoration: InputDecoration(
                              labelText: 'Service',
                              prefixIcon: Icon(Icons.dns),
                              border: OutlineInputBorder(),
                            ),
                            items: _services.map((svc) {
                              return DropdownMenuItem(
                                value: svc['value'],
                                child: Text(svc['label']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _service = value!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _targetIpController,
                            decoration: InputDecoration(
                              labelText: 'Target IP',
                              hintText: 'e.g., 192.168.1.1',
                              prefixIcon: Icon(Icons.computer),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Port (optional)',
                        hintText: 'Leave empty for default',
                        prefixIcon: Icon(Icons.input),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _usernameListController,
                      decoration: InputDecoration(
                        labelText: 'Username Wordlist Path',
                        hintText: '/path/to/usernames.txt',
                        prefixIcon: Icon(Icons.account_circle),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _passwordListController,
                      decoration: InputDecoration(
                        labelText: 'Password Wordlist Path',
                        hintText: '/path/to/passwords.txt',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isRunning 
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.lock_open),
                        label: Text(_isRunning ? 'Running...' : 'Start Attack'),
                        onPressed: _isRunning ? null : _startBruteforce,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.terminal, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Output',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _output,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Colors.greenAccent,
                          ),
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
    );
  }
}
