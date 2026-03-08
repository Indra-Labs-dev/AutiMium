import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../providers/api_provider.dart';
import '../providers/report_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      
      // Load reports from local storage (don't notify listeners during build)
      await reportProvider.loadReportsSilent();
      
      final reports = reportProvider.reports;
      
      // Calculate statistics
      _stats = calculateStats(reports);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard stats: $e')),
        );
      }
    }
  }

  Map<String, dynamic> calculateStats(List<dynamic> reports) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int totalReports = reports.length;
    int completedReports = reports.where((r) => r['status'] == 'completed').length;
    int pendingReports = reports.where((r) => r['status'] == 'pending').length;
    int failedReports = reports.where((r) => r['status'] == 'failed').length;
    
    int networkScans = reports.where((r) => r['type'] == 'network_scan').length;
    int malwareAnalysis = reports.where((r) => r['type'] == 'malware_analysis').length;
    int bruteforceTests = reports.where((r) => r['type'] == 'bruteforce').length;
    
    // Today's activity
    int todayActivity = reports.where((r) {
      final reportDate = DateTime.parse(r['created_at']);
      return reportDate.isAfter(today);
    }).length;
    
    // Success rate
    double successRate = totalReports > 0 
        ? (completedReports / totalReports) * 100 
        : 0.0;
    
    // Threats detected (from malware analysis)
    int threatsDetected = reports.where((r) {
      return r['type'] == 'malware_analysis' && 
             r['results'] != null && 
             r['results'].toString().contains('threat');
    }).length;
    
    return {
      'total': totalReports,
      'completed': completedReports,
      'pending': pendingReports,
      'failed': failedReports,
      'network_scans': networkScans,
      'malware_analysis': malwareAnalysis,
      'bruteforce_tests': bruteforceTests,
      'today_activity': todayActivity,
      'success_rate': successRate,
      'threats_detected': threatsDetected,
    };
  }

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      
                      const SizedBox(height: 32),
                      
                      // Quick Stats Row
                      _buildQuickStatsRow(),
                      
                      const SizedBox(height: 32),
                      
                      // Charts Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildReportTypeChart(),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildSuccessRateCard(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Activity Timeline
                      _buildRecentActivity(),
                      
                      const SizedBox(height: 24),
                      
                      // Kali Tools Status
                      _buildKaliToolsStatus(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: const Color(0xFF00D4FF),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Security Operations Overview',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _loadDashboardStats,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Reports',
          _stats?['total']?.toString() ?? '0',
          Icons.folder,
          const Color(0xFF0066FF),
        ),
        _buildStatCard(
          'Today\'s Activity',
          _stats?['today_activity']?.toString() ?? '0',
          Icons.trending_up,
          const Color(0xFF00D4FF),
        ),
        _buildStatCard(
          'Threats Detected',
          _stats?['threats_detected']?.toString() ?? '0',
          Icons.warning,
          const Color(0xFFFF3366),
        ),
        _buildStatCard(
          'Success Rate',
          '${_stats?['success_rate']?.toStringAsFixed(1) ?? '0'}%',
          Icons.check_circle,
          const Color(0xFF00FF88),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF00D4FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    value: (_stats?['network_scans'] ?? 0).toDouble(),
                    title: 'Network\n${_stats?['network_scans'] ?? 0}',
                    color: const Color(0xFF0066FF),
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: (_stats?['malware_analysis'] ?? 0).toDouble(),
                    title: 'Malware\n${_stats?['malware_analysis'] ?? 0}',
                    color: const Color(0xFFFF3366),
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: (_stats?['bruteforce_tests'] ?? 0).toDouble(),
                    title: 'Bruteforce\n${_stats?['bruteforce_tests'] ?? 0}',
                    color: const Color(0xFF00D4FF),
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF00D4FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 15,
            percent: (_stats?['success_rate'] ?? 0) / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_stats?['success_rate']?.toStringAsFixed(1) ?? '0'}%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FF88),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Success',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            progressColor: const Color(0xFF00FF88),
            backgroundColor: const Color(0xFF00FF88).withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(height: 24),
          _buildMetricRow('Completed', _stats?['completed'] ?? 0, Colors.green),
          const SizedBox(height: 12),
          _buildMetricRow('Pending', _stats?['pending'] ?? 0, Colors.orange),
          const SizedBox(height: 12),
          _buildMetricRow('Failed', _stats?['failed'] ?? 0, Colors.red),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF00D4FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Network Scan Completed',
            'Target: 192.168.1.1',
            Icons.network_check,
            const Color(0xFF0066FF),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Malware Analysis Finished',
            '3 threats detected',
            Icons.shield,
            const Color(0xFFFF3366),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Bruteforce Test Successful',
            'SSH credentials found',
            Icons.lock_open,
            const Color(0xFF00D4FF),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: color),
        ],
      ),
    );
  }

  Widget _buildKaliToolsStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kali Linux Tools Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF00D4FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildToolChip('Nmap', Icons.wifi_tethering, true),
              _buildToolChip('Metasploit', Icons.bug_report, true),
              _buildToolChip('Hydra', Icons.lock, true),
              _buildToolChip('YARA', Icons.search, true),
              _buildToolChip('Nikto', Icons.web, true),
              _buildToolChip('Wireshark', Icons.insights, true),
              _buildToolChip('Aircrack-ng', Icons.wifi, true),
              _buildToolChip('SQLMap', Icons.storage, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolChip(String label, IconData icon, bool available) {
    return Chip(
      avatar: Icon(icon, size: 18, color: available ? const Color(0xFF00FF88) : Colors.grey),
      label: Text(label),
      backgroundColor: available 
          ? const Color(0xFF00FF88).withOpacity(0.2)
          : Colors.grey.withOpacity(0.2),
      side: BorderSide(
        color: available ? const Color(0xFF00FF88) : Colors.grey,
        width: 1,
      ),
    );
  }
}
