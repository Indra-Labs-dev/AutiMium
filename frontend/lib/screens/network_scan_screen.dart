import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../providers/report_provider.dart';

class NetworkScanScreen extends StatefulWidget {
  const NetworkScanScreen({super.key});

  @override
  State<NetworkScanScreen> createState() => _NetworkScanScreenState();
}

class _NetworkScanScreenState extends State<NetworkScanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController(text: '127.0.0.1');
  final _portsController = TextEditingController();
  
  String _scanType = '-sV';
  bool _isScanning = false;
  String _output = '';
  
  final List<Map<String, String>> _scanTypes = [
    {'value': '-sV', 'label': 'Version Detection'},
    {'value': '-sS', 'label': 'SYN Stealth Scan'},
    {'value': '-sT', 'label': 'TCP Connect Scan'},
    {'value': '-A', 'label': 'Aggressive Scan'},
    {'value': '-O', 'label': 'OS Detection'},
  ];

  @override
  void dispose() {
    _ipController.dispose();
    _portsController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isScanning = true;
      _output = 'Starting scan...\n';
    });

    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);

      final result = await apiProvider.networkScan(
        ip: _ipController.text,
        scanType: _scanType,
        ports: _portsController.text.isEmpty ? null : _portsController.text,
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
        'type': 'network_scan',
        'target': _ipController.text,
        'results': result['output'],
        'status': result['status'],
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan completed successfully!')),
      );
    } catch (e) {
      setState(() {
        _output += '\nError: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                ).createShader(bounds),
                child: const Text(
                  'Network Scan',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Advanced network reconnaissance and vulnerability detection',
                style: TextStyle(
                  color: Color(0xFF6B7B9F),
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Configuration Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F1535).withOpacity(0.9),
                      const Color(0xFF1A2345).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0066FF).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0066FF).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _ipController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Target IP / CIDR',
                            hintText: 'e.g., 192.168.1.1 or 10.0.0.0/24',
                            prefixIcon: Icon(Icons.dns, color: Color(0xFF00D4FF)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter target IP';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        DropdownButtonFormField<String>(
                          value: _scanType,
                          dropdownColor: const Color(0xFF0F1535),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Scan Type',
                            prefixIcon: Icon(Icons.tune, color: Color(0xFF00D4FF)),
                          ),
                          items: _scanTypes.map((type) {
                            return DropdownMenuItem(
                              value: type['value'],
                              child: Text(type['label']!, style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _scanType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        TextFormField(
                          controller: _portsController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Ports (optional)',
                            hintText: 'e.g., 22,80,443 or 1-1000',
                            prefixIcon: Icon(Icons.list, color: Color(0xFF00D4FF)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0066FF).withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            icon: _isScanning 
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.play_arrow, size: 28),
                            label: Text(
                              _isScanning ? 'SCANNING...' : 'START SCAN',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            onPressed: _isScanning ? null : _startScan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
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
            ],
          ),
        ),
        
        // Output Terminal
        Expanded(
          child: _buildTerminalOutput(),
        ),
      ],
    );
  }
  
  Widget _buildTerminalOutput() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1535), Color(0xFF1A2345)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF0066FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 24, color: Color(0xFF00D4FF)),
                const SizedBox(width: 12),
                const Text(
                  'TERMINAL OUTPUT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D4FF),
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF00),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00FF00),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Color(0xFF00FF00),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
