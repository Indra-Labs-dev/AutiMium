/// Represents a network scan report
class ScanReport {
  final String id;
  final String type;
  final String target;
  final Map<String, dynamic>? results;
  final String status;
  final DateTime createdAt;

  ScanReport({
    required this.id,
    required this.type,
    required this.target,
    this.results,
    required this.status,
    required this.createdAt,
  });

  factory ScanReport.fromJson(Map<String, dynamic> json) {
    return ScanReport(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      target: json['target'] ?? '',
      results: json['results'] != null 
          ? Map<String, dynamic>.from(json['results']) 
          : null,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'target': target,
      'results': results,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
