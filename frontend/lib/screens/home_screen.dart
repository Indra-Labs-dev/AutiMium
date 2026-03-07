import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import 'network_scan_screen.dart';
import 'malware_analysis_screen.dart';
import 'bruteforce_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NetworkScanScreen(),
    const MalwareAnalysisScreen(),
    const BruteforceScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
              ).createShader(bounds),
              child: const Icon(Icons.security, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF00FFFF)],
              ).createShader(bounds),
              child: const Text(
                'AutoMium',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Spacer(),
            Consumer<ApiProvider>(
              builder: (context, apiProvider, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: apiProvider.isConnected 
                          ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)]
                          : [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: apiProvider.isConnected ? Colors.green : Colors.red,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (apiProvider.isConnected ? Colors.green : Colors.red).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: apiProvider.isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (apiProvider.isConnected ? Colors.green : Colors.red).withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        apiProvider.statusMessage,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00D4FF)),
            onPressed: () {
              Provider.of<ApiProvider>(context, listen: false).checkConnection();
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFF0A0E27),
                Color(0xFF0F1535),
                Color(0xFF0A0E27),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF050818),
              const Color(0xFF0A0E27).withOpacity(0.5),
              const Color(0xFF050818),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.of(context).size.width > 800,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                  ).createShader(bounds),
                  child: const Icon(Icons.shield, size: 56, color: Colors.white),
                ),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.wifi_tethering),
                  label: Text('Network Scan'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.bug_report),
                  label: Text('Malware Analysis'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.lock_open),
                  label: Text('Bruteforce'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.description),
                  label: Text('Reports'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: Color(0xFF0066FF)),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
