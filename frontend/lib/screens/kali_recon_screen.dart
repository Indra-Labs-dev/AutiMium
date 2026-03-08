import 'package:flutter/material.dart';

class KaliReconScreen extends StatefulWidget {
  const KaliReconScreen({super.key});

  @override
  State<KaliReconScreen> createState() => _KaliReconScreenState();
}

class _KaliReconScreenState extends State<KaliReconScreen> {
  final _formKey = GlobalKey<FormState>();
  String _target = '';
  String _selectedTool = 'theHarvester';
  String _result = '';
  bool _isLoading = false;

  final List<String> _tools = [
    'theHarvester',
    'whois',
    'nslookup',
    'dnsrecon',
    'maltego',
    'recon-ng'
  ];

  Future<void> _runRecon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // TODO: Connect to real API endpoint when ready
      // For now using mock functionality
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _result = '[+] Reconnaissance initiated for $_target\n[+] Using tool: $_selectedTool\n\n[*] Gathering information...\n[+] Results would appear here from backend API...';
        _isLoading = false;
      });
      // final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      // final response = await apiProvider.post(
      //   '/kali/recon',
      //   {'target': _target, 'tool': _selectedTool},
      // );
      // setState(() {
      //   _result = response.toString();
      //   _isLoading = false;
      // });
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
          // Header
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                ).createShader(bounds),
                child: const Icon(Icons.search, size: 48, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Text(
                'Reconnaissance Tools',
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
            'Information gathering and OSINT tools',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Tool Selection Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _tools.map((tool) => _buildToolCard(tool)).toList(),
          ),
          const SizedBox(height: 32),

          // Input Form
          Card(
            color: const Color(0xFF0F1535).withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Configuration',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF00D4FF),
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Target Domain or IP',
                        hintText: 'example.com or 192.168.1.1',
                        prefixIcon: const Icon(Icons.business, color: Color(0xFF0066FF)),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runRecon,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(_isLoading ? 'Running...' : 'Run Reconnaissance'),
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

          // Results
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
                  Row(
                    children: [
                      const Icon(Icons.terminal, color: Color(0xFF00FF88), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
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

  Widget _buildToolCard(String tool) {
    final isSelected = _selectedTool == tool;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = tool),
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
              _getToolIcon(tool),
              color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withOpacity(0.7),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              tool,
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

  IconData _getToolIcon(String tool) {
    switch (tool) {
      case 'theHarvester':
        return Icons.email;
      case 'whois':
        return Icons.info;
      case 'nslookup':
        return Icons.dns;
      case 'dnsrecon':
        return Icons.search;
      case 'maltego':
        return Icons.account_tree;
      case 'recon-ng':
        return Icons.folder;
      default:
        return Icons.terminal;
    }
  }
}
