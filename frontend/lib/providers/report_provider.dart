import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReportProvider extends ChangeNotifier {
  late Box _reportsBox;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get reports => _reports;
  bool get isLoading => _isLoading;

  ReportProvider() {
    // Don't call async methods in constructor
    // initHive() will be called manually after provider creation
  }

  Future<void> initialize() async {
    await initHive();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    _reportsBox = await Hive.openBox('reports');
    loadReports();
  }

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    await _loadReportsData();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadReportsSilent() async {
    // Load reports without notifying listeners (for use during build)
    await _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    try {
      final keys = _reportsBox.keys.toList();
      _reports = keys.map((key) {
        final data = _reportsBox.get(key) as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from({
          'id': key,
          ...data,
        });
      }).cast<Map<String, dynamic>>().toList();
      
      _reports.sort((a, b) => 
        DateTime.parse(b['created_at'] as String).compareTo(DateTime.parse(a['created_at'] as String))
      );
    } catch (e) {
      print('Error loading reports: $e');
    }
  }

  Future<void> addReport(Map<String, dynamic> report) async {
    try {
      await _reportsBox.put(report['id'], report);
      await loadReports();
    } catch (e) {
      print('Error adding report: $e');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _reportsBox.delete(id);
      await loadReports();
    } catch (e) {
      print('Error deleting report: $e');
    }
  }

  Future<void> clearAllReports() async {
    try {
      await _reportsBox.clear();
      await loadReports();
    } catch (e) {
      print('Error clearing reports: $e');
    }
  }

  List<Map<String, dynamic>> getReportsByType(String type) {
    return _reports.where((r) => r['type'] == type).toList();
  }

  Map<String, dynamic>? getReportById(String id) {
    try {
      return _reports.firstWhere((r) => r['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
