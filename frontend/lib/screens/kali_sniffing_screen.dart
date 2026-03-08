import 'package:flutter/material.dart';

class KaliSniffingScreen extends StatefulWidget {
  const KaliSniffingScreen({super.key});

  @override
  State<KaliSniffingScreen> createState() => _KaliSniffingScreenState();
}

class _KaliSniffingScreenState extends State<KaliSniffingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _interface = 'eth0';
  String _tool = 'tcpdump';
  String _target = '';
  String _result = '';
  bool _isLoading = false;

  final List<String> _tools = ['tcpdump', 'wireshark', 'bettercap', 'arpspoof', 'dsniff', 'ettercap'];

  Future<void> _runSniffing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _result = ''; });
    try {
      await Future.delayed(const Duration(seconds: 2));
      setState(() { 
        _result = '[+] Tool: $_tool\n[+] Interface: $_interface\n[+] Target: ${_target.isNotEmpty ? _target : "All traffic"}\n\n[*] Starting packet capture...\n[+] Capturing packets...'; 
        _isLoading = false; 
      });
    } catch (e) {
      setState(() { _result = 'Error: $e'; _isLoading = false; });
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
                shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFFFF3366)]).createShader(bounds),
                child: const Icon(Icons.network_check, size: 48, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Text('Sniffing & Spoofing', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00D4FF))),
            ],
          ),
          const SizedBox(height: 32),
          
          Wrap(spacing: 16, runSpacing: 16, children: _tools.map((t) => _buildToolCard(t)).toList()),
          const SizedBox(height: 32),
          
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
                        labelText: 'Network Interface',
                        hintText: 'eth0, wlan0, etc.',
                        prefixIcon: const Icon(Icons.usb, color: Color(0xFF00D4FF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFF0A0E27),
                      ),
                      initialValue: 'eth0',
                      onSaved: (value) => _interface = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Target IP (optional)',
                        hintText: '192.168.1.100 (leave empty for all traffic)',
                        prefixIcon: const Icon(Icons.computer, color: Color(0xFF00D4FF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFF0A0E27),
                      ),
                      onSaved: (value) => _target = value!,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runSniffing,
                        icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi_tethering),
                        label: Text(_isLoading ? 'Capturing...' : 'Start Capture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D4FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          if (_result.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00D4FF), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.terminal, color: Color(0xFF00D4FF), size: 24),
                      SizedBox(width: 12),
                      Text('Packet Capture Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(_result, style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Color(0xFF00D4FF))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolCard(String tool) {
    final isSelected = _tool == tool;
    return GestureDetector(
      onTap: () => setState(() => _tool = tool),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF00D4FF).withOpacity(0.3), const Color(0xFF00D4FF).withOpacity(0.1)]
                : [const Color(0xFF0F1535).withOpacity(0.8), const Color(0xFF0A0E27).withOpacity(0.5)],
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
            Icon(isSelected ? Icons.network_check : Icons.wifi_tethering, color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withOpacity(0.7), size: 32),
            const SizedBox(height: 8),
            Text(tool, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
