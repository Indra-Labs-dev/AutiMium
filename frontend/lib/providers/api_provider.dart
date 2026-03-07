import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiProvider extends ChangeNotifier {
  String _baseUrl = 'http://localhost:8000';
  bool _isConnected = false;
  String _statusMessage = 'Disconnected';

  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;
  String get baseUrl => _baseUrl;

  ApiProvider() {
    checkConnection();
  }

  Future<void> checkConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/'));
      if (response.statusCode == 200) {
        _isConnected = true;
        _statusMessage = 'Connected';
      } else {
        _isConnected = false;
        _statusMessage = 'Server error';
      }
    } catch (e) {
      _isConnected = false;
      _statusMessage = 'Cannot connect to backend';
    }
    notifyListeners();
  }

  // Network Scan
  Future<Map<String, dynamic>> networkScan({
    required String ip,
    String scanType = '-sV',
    String? ports,
  }) async {
    try {
      Uri uri = Uri.parse('$_baseUrl/scan').replace(
        queryParameters: {
          'ip': ip,
          'scan_type': scanType,
          if (ports != null) 'ports': ports,
        },
      );

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Scan failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Malware Analysis
  Future<Map<String, dynamic>> analyzeMalware({
    required String filePath,
    String analysisType = 'static',
  }) async {
    try {
      Uri uri = Uri.parse('$_baseUrl/analyze/malware').replace(
        queryParameters: {
          'file_path': filePath,
          'analysis_type': analysisType,
        },
      );

      final response = await http.post(uri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Analysis failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Bruteforce Attack
  Future<Map<String, dynamic>> bruteforce({
    required String service,
    required String targetIp,
    required String usernameList,
    required String passwordList,
    int? port,
  }) async {
    try {
      Uri uri = Uri.parse('$_baseUrl/bruteforce').replace(
        queryParameters: {
          'service': service,
          'target_ip': targetIp,
          'username_list': usernameList,
          'password_list': passwordList,
          if (port != null) 'port': port.toString(),
        },
      );

      final response = await http.post(uri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Bruteforce failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Report
  Future<Map<String, dynamic>> getReport(String reportId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/report/$reportId'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Report not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get All Reports
  Future<List<Map<String, dynamic>>> getAllReports({int limit = 50}) async {
    try {
      Uri uri = Uri.parse('$_baseUrl/reports').replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['reports']);
      } else {
        throw Exception('Failed to fetch reports');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete Report
  Future<void> deleteReport(String reportId) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/report/$reportId'));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete report');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check Backend Status
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/status'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get status');
      }
    } catch (e) {
      rethrow;
    }
  }
}
