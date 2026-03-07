import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class NetworkMonitoringScreen extends StatefulWidget {
  const NetworkMonitoringScreen({super.key});

  @override
  State<NetworkMonitoringScreen> createState() => _NetworkMonitoringScreenState();
}

class _NetworkMonitoringScreenState extends State<NetworkMonitoringScreen> {
  Map<String, dynamic>? _connections;
  Map<String, dynamic>? _interfaces;
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _arpTable;
  Map<String, dynamic>? _listeningPorts;
  
  bool _isLoading = false;
  String _selectedTab = 'connections';
  
  final List<Map<String, dynamic>> _tabs = [
    {'id': 'connections', 'label': 'Connections', 'icon': Icons.link},
    {'id': 'interfaces', 'label': 'Interfaces', 'icon': Icons.router},
    {'id': 'ports', 'label': 'Listening Ports', 'icon': Icons.dns},
    {'id': 'arp', 'label': 'ARP Table', 'icon': Icons.table_chart},
    {'id': 'stats', 'label': 'Statistics', 'icon': Icons.show_chart},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    try {
      final apiProvider = context.read<ApiProvider>();
      
      final results = await Future.wait([
        apiProvider.getActiveConnections(),
        apiProvider.getNetworkInterfaces(),
        apiProvider.getListeningPorts(),
        apiProvider.getArpTable(),
        apiProvider.getNetworkStatistics(),
      ]);
      
      setState(() {
        _connections = results[0];
        _interfaces = results[1];
        _listeningPorts = results[2];
        _arpTable = results[3];
        _statistics = results[4];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _selectedTab == tab['id'];
                
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab['icon'] as IconData, size: 18),
                        const SizedBox(width: 8),
                        Text(tab['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedTab = tab['id'] as String);
                    },
                    selectedColor: const Color(0xFF0066FF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF00D4FF),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'connections':
        return _buildConnectionsView();
      case 'interfaces':
        return _buildInterfacesView();
      case 'ports':
        return _buildPortsView();
      case 'arp':
        return _buildArpView();
      case 'stats':
        return _buildStatsView();
      default:
        return const Center(child: Text('Select a tab'));
    }
  }

  Widget _buildConnectionsView() {
    if (_connections == null || !_connections!['success']) {
      return const Center(child: Text('No connections data available'));
    }
    
    final connections = _connections!['connections'] as List<dynamic>? ?? [];
    final totalConnections = _connections!['total_connections'] as int? ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatCard(
                'Total Connections',
                totalConnections.toString(),
                Icons.link,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Listening Ports',
                (_connections!['listening_ports'] as int? ?? 0).toString(),
                Icons.dns,
              ),
            ],
          ),
        ),
        
        Expanded(
          child: connections.isEmpty
              ? const Center(child: Text('No active connections'))
              : ListView.builder(
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    final conn = connections[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0066FF),
                          child: Icon(
                            conn['type'].toString().startsWith('tcp') 
                                ? Icons.dns 
                                : Icons.wifi,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          '${conn['local_address']} → ${conn['peer_address']}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                        subtitle: Text(
                          'State: ${conn['state']} | Process: ${conn['process']}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInterfacesView() {
    if (_interfaces == null || !_interfaces!['success']) {
      return const Center(child: Text('No interfaces data available'));
    }
    
    final interfaces = _interfaces!['interfaces'] as List<dynamic>? ?? [];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: interfaces.length,
      itemBuilder: (context, index) {
        final iface = interfaces[index];
        final name = iface['name'] ?? 'Unknown';
        final state = iface['state'] ?? 'UNKNOWN';
        final macAddress = iface['mac_address'] ?? 'N/A';
        final ipv4Addresses = iface['ipv4_addresses'] as List<dynamic>? ?? [];
        final ipv6Addresses = iface['ipv6_addresses'] as List<dynamic>? ?? [];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: state == 'UP' ? Colors.green : Colors.red,
              child: Icon(Icons.router, color: Colors.white),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('State: $state | MAC: $macAddress'),
            children: [
              if (ipv4Addresses.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.language, size: 20),
                  title: const Text('IPv4 Addresses'),
                  subtitle: Text(ipv4Addresses.join('\n')),
                ),
              if (ipv6Addresses.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.wifi_tethering, size: 20),
                  title: const Text('IPv6 Addresses'),
                  subtitle: Text(ipv6Addresses.join('\n')),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortsView() {
    if (_listeningPorts == null) {
      return const Center(child: Text('No ports data available'));
    }
    
    final ports = _listeningPorts!['listening_ports'] as List<dynamic>? ?? [];
    final count = _listeningPorts!['count'] as int? ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildStatCard('Listening Services', count.toString(), Icons.dns),
        ),
        
        Expanded(
          child: ports.isEmpty
              ? const Center(child: Text('No listening ports found'))
              : ListView.builder(
                  itemCount: ports.length,
                  itemBuilder: (context, index) {
                    final port = ports[index];
                    final address = port['address'] ?? 'Unknown';
                    final process = port['process'] ?? 'Unknown';
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0066FF),
                          child: const Icon(Icons.lock_open, color: Colors.white, size: 20),
                        ),
                        title: Text(address, style: const TextStyle(fontFamily: 'monospace')),
                        subtitle: Text('Process: $process'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildArpView() {
    if (_arpTable == null || !_arpTable!['success']) {
      return const Center(child: Text('No ARP data available'));
    }
    
    final arpTable = _arpTable!['arp_table'] as List<dynamic>? ?? [];
    final entriesCount = _arpTable!['entries_count'] as int? ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildStatCard('ARP Entries', entriesCount.toString(), Icons.table_chart),
        ),
        
        Expanded(
          child: arpTable.isEmpty
              ? const Center(child: Text('No ARP entries'))
              : ListView.builder(
                  itemCount: arpTable.length,
                  itemBuilder: (context, index) {
                    final entry = arpTable[index];
                    final ipAddress = entry['ip_address'] ?? 'Unknown';
                    final macAddress = entry['mac_address'] ?? 'Unknown';
                    final interface = entry['interface'] ?? 'Unknown';
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00D4FF),
                          child: const Icon(Icons.devices, color: Colors.white, size: 20),
                        ),
                        title: Text(ipAddress, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('MAC: $macAddress\nInterface: $interface'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsView() {
    if (_statistics == null || !_statistics!['success']) {
      return const Center(child: Text('No statistics data available'));
    }
    
    final stats = _statistics!['statistics'] as Map<String, dynamic>? ?? {};
    
    if (stats.isEmpty) {
      return const Center(child: Text('No network statistics available'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final ifaceName = stats.keys.elementAt(index);
        final ifaceStats = stats[ifaceName] as Map<String, dynamic>;
        
        final rxBytes = ifaceStats['rx_bytes'] as int? ?? 0;
        final txBytes = ifaceStats['tx_bytes'] as int? ?? 0;
        final rxPackets = ifaceStats['rx_packets'] as int? ?? 0;
        final txPackets = ifaceStats['tx_packets'] as int? ?? 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0066FF),
              child: Text(
                ifaceName.substring(0, 3).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(ifaceName, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              ListTile(
                leading: const Icon(Icons.download, size: 20),
                title: const Text('Received'),
                subtitle: Text('${_formatBytes(rxBytes)} (${rxPackets.toString()} packets)'),
              ),
              ListTile(
                leading: const Icon(Icons.upload, size: 20),
                title: const Text('Transmitted'),
                subtitle: Text('${_formatBytes(txBytes)} (${txPackets.toString()} packets)'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF0066FF).withOpacity(0.2), const Color(0xFF00D4FF).withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF00D4FF), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF00D4FF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
