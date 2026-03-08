import 'package:flutter/material.dart';
import 'kali_recon_screen.dart';
import 'kali_scanning_screen.dart';
import 'kali_exploitation_screen.dart';
import 'kali_malware_screen.dart';
import 'kali_forensics_screen.dart';
import 'kali_wireless_screen.dart';
import 'kali_password_screen.dart';
import 'kali_web_attacks_screen.dart';
import 'kali_sniffing_screen.dart';

class KaliToolsScreen extends StatefulWidget {
  const KaliToolsScreen({super.key});

  @override
  State<KaliToolsScreen> createState() => _KaliToolsScreenState();
}

class _KaliToolsScreenState extends State<KaliToolsScreen> {
  int _selectedIndex = 0;

  final List<Widget> _categoryScreens = [
    const KaliReconScreen(),
    const KaliScanningScreen(),
    const KaliExploitationScreen(),
    const KaliMalwareScreen(),
    const KaliForensicsScreen(),
    const KaliWirelessScreen(),
    const KaliPasswordScreen(),
    const KaliWebAttacksScreen(),
    const KaliSniffingScreen(), // Bonus!
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF050818),
              const Color(0xFF0A0E27),
              const Color(0xFF0F1535),
            ],
          ),
        ),
        child: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.of(context).size.width > 1000,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              leading: Padding(
                padding: const EdgeInsets.all(16),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF3366), Color(0xFF0066FF)],
                  ).createShader(bounds),
                  child: const Icon(Icons.terminal, size: 48, color: Colors.white),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Recon'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.wifi_tethering),
                  label: Text('Scanning'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bug_report),
                  label: Text('Exploit'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shield),
                  label: Text('Malware'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder),
                  label: Text('Forensics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.wifi),
                  label: Text('Wireless'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.lock),
                  label: Text('Passwords'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.web),
                  label: Text('Web Attacks'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.network_check),
                  label: Text('Sniffing'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: Color(0xFF0066FF)),
            Expanded(
              child: _categoryScreens[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
