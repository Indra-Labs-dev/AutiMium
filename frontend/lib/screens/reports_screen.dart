import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/api_provider.dart';
import '../providers/report_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _filterType = 'all';
  bool _isLoading = true;

  final List<Map<String, String>> _filterOptions = [
    {'value': 'all', 'label': 'All Reports'},
    {'value': 'network_scan', 'label': 'Network Scans'},
    {'value': 'malware_analysis', 'label': 'Malware Analysis'},
    {'value': 'bruteforce', 'label': 'Bruteforce'},
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });
    
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    await reportProvider.loadReports();
    
    setState(() {
      _isLoading = false;
    });
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'network_scan':
        return Icons.wifi_tethering;
      case 'malware_analysis':
        return Icons.bug_report;
      case 'bruteforce':
        return Icons.lock_open;
      default:
        return Icons.description;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'running':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reports',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Color(0xFFE94560),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _loadReports,
              ),
            ],
          ),
          SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Filter:', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _filterOptions.map((option) {
                        return DropdownMenuItem(
                          value: option['value'],
                          child: Text(option['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _filterType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Consumer<ReportProvider>(
                    builder: (context, reportProvider, child) {
                      final reports = _filterType == 'all'
                          ? reportProvider.reports
                          : reportProvider.getReportsByType(_filterType);

                      if (reports.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No reports found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xFFE94560),
                                child: Icon(_getTypeIcon(report['type']), color: Colors.white),
                              ),
                              title: Text(
                                report['target'] ?? 'Unknown',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text('Type: ${report['type']}'),
                                  Text(
                                    'Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(report['created_at']))}',
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report['status']).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _getStatusColor(report['status'])),
                                    ),
                                    child: Text(
                                      report['status'],
                                      style: TextStyle(
                                        color: _getStatusColor(report['status']),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _confirmDelete(report['id']);
                                    },
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              onTap: () {
                                _showReportDetails(report);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getTypeIcon(report['type']), color: Color(0xFFE94560)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Report Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 16),
              
              _buildInfoRow('ID', report['id']),
              _buildInfoRow('Type', report['type']),
              _buildInfoRow('Target', report['target'] ?? 'N/A'),
              _buildInfoRow('Status', report['status']),
              _buildInfoRow('Date', DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(report['created_at']))),
              
              SizedBox(height: 16),
              Text('Results:', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      report['results'] ?? 'No results available',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(String reportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Report'),
        content: Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reportProvider = Provider.of<ReportProvider>(context, listen: false);
              await reportProvider.deleteReport(reportId);
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report deleted')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
