import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

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

  // Network Scan - Updated for modular backend
  Future<Map<String, dynamic>> networkScan({
    required String ip,
    String scanType = '-sV',
    String? ports,
    bool aggressive = false,
    bool osDetection = false,
    bool scriptScan = false,
    bool traceroute = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/scan/scan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ip': ip,
          'scan_type': scanType,
          if (ports != null) 'ports': ports,
          'aggressive': aggressive,
          'os_detection': osDetection,
          'script_scan': scriptScan,
          'traceroute': traceroute,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Scan failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Vulnerability Scan
  Future<Map<String, dynamic>> vulnerabilityScan({
    required String ip,
    String? ports,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/scan/vulnerabilities'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ip': ip,
          if (ports != null) 'ports': ports,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Vulnerability scan failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Malware Analysis - Updated for modular backend
  Future<Map<String, dynamic>> analyzeMalware({
    required String filePath,
    String analysisType = 'static',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze/malware'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'file_path': filePath,
          'analysis_type': analysisType,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Analysis failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Bruteforce Attack - Updated for modular backend
  Future<Map<String, dynamic>> bruteforce({
    required String service,
    required String targetIp,
    required String usernameList,
    required String passwordList,
    int? port,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bruteforce/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service': service,
          'target_ip': targetIp,
          'username_list': usernameList,
          'password_list': passwordList,
          if (port != null) 'port': port,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Bruteforce failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Report - Updated endpoint
  Future<Map<String, dynamic>> getReport(String reportId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/reports/$reportId'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Report not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Export Report (PDF or JSON)
  Future<Uint8List> exportReport(String reportId, String format) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reports/export/$reportId?format=$format'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to export report');
      }
      
      // Return the file bytes (caller will save it)
      return response.bodyBytes;
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

  // Check Backend Status - Updated endpoint
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tools/status'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get status');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Tools Installation Instructions
  Future<Map<String, dynamic>> getInstallInstructions(String toolName) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tools/install/$toolName'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get installation instructions');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Execute Terminal Command (REST API)
  Future<Map<String, dynamic>> executeTerminalCommand(String command, {int timeout = 60}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/terminal/execute').replace(
          queryParameters: {
            'command': command,
            'timeout': timeout.toString(),
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Command execution failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
