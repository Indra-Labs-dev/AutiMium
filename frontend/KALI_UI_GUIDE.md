# 🛠️ Guide: Ajouter des Écrans pour les Outils Kali Linux

## Structure Actuelle

Le système d'outils Kali est organisé en **8 catégories** avec navigation par rail :

1. **Reconnaissance** (Recon) ✅ CRÉÉ
2. **Scanning & Enumeration** (Scanning)
3. **Exploitation** (Exploit)
4. **Malware Analysis** (Malware)
5. **Forensics** (Forensics)
6. **Wireless Attacks** (Wireless)
7. **Password Attacks** (Passwords)
8. **Web Application Attacks** (Web)

---

## Comment Créer un Écran d'Outil Kali

### Template de Base

Créez un fichier `lib/screens/kali_[category]_screen.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class Kali[Category]Screen extends StatefulWidget {
  const Kali[Category]Screen({super.key});

  @override
  State<Kali[Category]Screen> createState() => _Kali[Category]ScreenState();
}

class _Kali[Category]ScreenState extends State<Kali[Category]Screen> {
  final _formKey = GlobalKey<FormState>();
  String _result = '';
  bool _isLoading = false;

  Future<void> _runTool() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Appel API vers le backend
      // Exemple: await apiProvider.post('/kali/[endpoint]', data);
      
      setState(() {
        _result = 'Result here';
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
          // Header avec icône et titre
          // Formulaire de configuration
          // Bouton d'exécution
          // Affichage des résultats
        ],
      ),
    );
  }
}
```

---

## Exemple Complet: Scanning Screen

Voici comment créer `kali_scanning_screen.dart` :

```dart
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

  final List<String> _scanTypes = ['nmap', 'masscan', 'enum4linux', 'nikto'];

  Future<void> _runScan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final response = await apiProvider.callEndpoint(
        'POST',
        '/kali/scan/enumeration',
        {
          'target': _target,
          'scan_type': _scanType,
          'ports': _ports.isNotEmpty ? _ports : null,
          'aggressive': _aggressive,
        },
      );

      setState(() {
        _result = response.toString();
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
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      onSaved: (value) => _target = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ports (optional)',
                        hintText: '22,80,443 or 1-1000',
                        prefixIcon: Icon(Icons.list, color: Color(0xFF0066FF)),
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
    return GestureDetector(
      onTap: () => setState(() => _scanType = type),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _scanType == type
              ? const Color(0xFF0066FF).withOpacity(0.3)
              : const Color(0xFF0F1535).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _scanType == type
                ? const Color(0xFF00D4FF)
                : const Color(0xFF0066FF).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForTool(type),
              color: _scanType == type
                  ? const Color(0xFF00D4FF)
                  : Colors.white.withOpacity(0.7),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _scanType == type
                    ? const Color(0xFF00D4FF)
                    : Colors.white.withOpacity(0.8),
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
      default:
        return Icons.terminal;
    }
  }
}
```

---

## Backend Endpoints Correspondants

Chaque écran frontend appelle ces endpoints backend :

```python
# Reconnaissance
POST /kali/recon
{
  "target": "example.com",
  "tool": "theHarvester"
}

# Scanning
POST /kali/scan/enumeration
{
  "target": "192.168.1.1",
  "scan_type": "nmap",
  "ports": "22,80,443",
  "aggressive": false
}

# Exploitation
POST /kali/exploit
{
  "exploit": "exploit/unix/ftp/vsftpd_234_backdoor",
  "target": "192.168.1.1",
  "payload": "cmd/unix/interact"
}

# Malware Generation
POST /kali/malware/generate
{
  "payload": "windows/meterpreter/reverse_tcp",
  "lhost": "192.168.1.100",
  "lport": 4444,
  "format": "exe"
}

# Et ainsi de suite...
```

---

## Prochaines Étapes

Pour compléter l'interface utilisateur Kali :

1. ✅ **Recon Screen** - Déjà créé
2. ⏳ **Scanning Screen** - Template ci-dessus
3. ⏳ **Exploitation Screen** - Suivre le même pattern
4. ⏳ **Malware Screen** - Suivre le même pattern
5. ⏳ **Forensics Screen** - Suivre le même pattern
6. ⏳ **Wireless Screen** - Suivre le même pattern
7. ⏳ **Password Screen** - Suivre le même pattern
8. ⏳ **Web Screen** - Suivre le même pattern

Chaque écran prend environ **300-400 lignes** de code Dart.

---

## Design System à Respecter

- **Couleurs:**
  - Primary: `#0066FF` (Bleu)
  - Secondary: `#00D4FF` (Cyan)
  - Accent: `#FF3366` (Rouge/Rose)
  - Success: `#00FF88` (Vert)
  
- **Effets:**
  - Glassmorphism avec opacité
  - Gradients linéaires
  - Borders lumineux
  - Ombres portées

- **Composants:**
  - Cards avec coins arrondis (12px)
  - Boutons avec gradients
  - Icônes avec ShaderMask
  - Terminal style pour résultats

---

<div align="center">

### 🛡️ AutoMium - Kali UI Development Guide

*Consistent • Beautiful • Functional*

</div>
