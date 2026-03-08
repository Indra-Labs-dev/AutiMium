import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class KaliScanningScreen extends StatefulWidget {
  const KaliScanningScreen({super.key});

  @override
  State<KaliScanningScreen> createState() => _KaliScanningScreenState();
}

class _KaliScanningScreenState extends State<KaliScanningScreen> {
  final _formKey = GlobalKey<FormState>();
  String _target = '';
  String _scanType = 'nmap';
  String _ports = '';
  bool _aggressive = false;
  String _result = '';
  bool _isLoading = false;

  final List<String> _scanTypes = ['nmap', 'masscan', 'enum4linux', 'nikto', 'gobuster'];

  Future<void> _runScan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Note: This would call the actual API endpoint
      // For now, showing mock functionality
      // final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _result = '[+] Scan initiated for $_target\n[+] Using tool: $_scanType\n[+] Ports: ${_ports.isNotEmpty ? _ports : "default"}\n[+] Aggressive mode: $_aggressive\n\nScan results would appear here...';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                ).createShader(bounds),
                child: const Icon(Icons.wifi_tethering, size: 48, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Text(
                'Scanning & Enumeration',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Network scanning and service enumeration tools',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          
          // Tool selection cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _scanTypes.map((type) => _buildToolCard(type)).toList(),
          ),
          const SizedBox(height: 32),
          
          // Configuration form
          Card(
            color: const Color(0xFF0F1535).withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Target IP or Network',
                        hintText: '192.168.1.1 or 192.168.1.0/24',
                        prefixIcon: const Icon(Icons.computer, color: Color(0xFF0066FF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0A0E27),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a target';
                        }
                        return null;
                      },
                      onSaved: (value) => _target = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ports (optional)',
                        hintText: '22,80,443 or 1-1000',
                        prefixIcon: const Icon(Icons.list, color: Color(0xFF0066FF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0A0E27),
                      ),
                      onSaved: (value) => _ports = value!,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Aggressive Scan'),
                      subtitle: const Text('More intensive but may be detected'),
                      value: _aggressive,
                      onChanged: (value) => setState(() => _aggressive = value),
                      activeColor: const Color(0xFFFF3366),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runScan,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(_isLoading ? 'Scanning...' : 'Start Scan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Results display
          if (_result.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00FF88), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.terminal, color: Color(0xFF00FF88), size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Scan Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Color(0xFF00FF88),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolCard(String type) {
    final isSelected = _scanType == type;
    return GestureDetector(
      onTap: () => setState(() => _scanType = type),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    const Color(0xFF0066FF).withOpacity(0.3),
                    const Color(0xFF0066FF).withOpacity(0.1)
                  ]
                : [
                    const Color(0xFF0F1535).withOpacity(0.8),
                    const Color(0xFF0A0E27).withOpacity(0.5)
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D4FF) : const Color(0xFF0066FF).withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForTool(type),
              color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withOpacity(0.7),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTool(String type) {
    switch (type) {
      case 'nmap':
        return Icons.wifi_tethering;
      case 'masscan':
        return Icons.speed;
      case 'enum4linux':
        return Icons.folder_shared;
      case 'nikto':
        return Icons.web;
      case 'gobuster':
        return Icons.folder_open;
      default:
        return Icons.terminal;
    }
  }
}
