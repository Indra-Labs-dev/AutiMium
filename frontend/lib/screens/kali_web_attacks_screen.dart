import 'package:flutter/material.dart';

class KaliWebAttacksScreen extends StatefulWidget {
  const KaliWebAttacksScreen({super.key});

  @override
  State<KaliWebAttacksScreen> createState() => _KaliWebAttacksScreenState();
}

class _KaliWebAttacksScreenState extends State<KaliWebAttacksScreen> {
  final _formKey = GlobalKey<FormState>();
  String _target = '';
  String _tool = 'sqlmap';
  String _result = '';
  bool _isLoading = false;

  final List<String> _tools = ['sqlmap', 'burpsuite', 'owasp-zap', 'xsstrike', 'dalfox', 'wpscan'];

  Future<void> _runAttack() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _result = ''; });
    try {
      await Future.delayed(const Duration(seconds: 2));
      setState(() { _result = '[+] Tool: $_tool\n[+] Target: $_target\n\n[*] Starting web application attack...\n[+] Scan in progress...'; _isLoading = false; });
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
                shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0066FF)]).createShader(bounds),
                child: const Icon(Icons.web, size: 48, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Text('Web Application Attacks', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00D4FF))),
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
                        labelText: 'Target URL',
                        hintText: 'http://example.com/vuln.php?id=1',
                        prefixIcon: const Icon(Icons.link, color: Color(0xFF00D4FF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFF0A0E27),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      onSaved: (value) => _target = value!,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runAttack,
                        icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.bug_report),
                        label: Text(_isLoading ? 'Scanning...' : 'Launch Attack'),
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
                      Text('Scan Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
            Icon(isSelected ? Icons.web_asset : Icons.web, color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withOpacity(0.7), size: 32),
            const SizedBox(height: 8),
            Text(tool, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
