"""
Report Export Services - CSV, HTML, PDF Generation
"""

import csv
import io
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any


class ReportExporter:
    """Export reports in various formats"""
    
    @staticmethod
    def to_csv(reports: List[Dict[str, Any]], output_path: str = None) -> str:
        """
        Export reports to CSV format
        
        Args:
            reports: List of report dictionaries
            output_path: Optional file path to save CSV
            
        Returns:
            CSV content as string
        """
        output = io.StringIO()
        
        if not reports:
            return ""
        
        # Define fieldnames based on report type
        fieldnames = ['id', 'type', 'target', 'status', 'created_at']
        
        writer = csv.DictWriter(output, fieldnames=fieldnames, extrasaction='ignore')
        writer.writeheader()
        
        for report in reports:
            writer.writerow(report)
        
        csv_content = output.getvalue()
        
        if output_path:
            Path(output_path).parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'w', newline='') as f:
                f.write(csv_content)
        
        return csv_content
    
    @staticmethod
    def to_html(reports: List[Dict[str, Any]], title: str = "AutoMium Reports") -> str:
        """
        Export reports to HTML format with styling
        
        Args:
            reports: List of report dictionaries
            title: HTML page title
            
        Returns:
            HTML content as string
        """
        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 20px;
            min-height: 100vh;
        }}
        
        .container {{
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }}
        
        .header {{
            background: linear-gradient(135deg, #0066FF 0%, #00D4FF 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }}
        
        .header h1 {{
            font-size: 32px;
            margin-bottom: 10px;
        }}
        
        .header p {{
            opacity: 0.9;
            font-size: 16px;
        }}
        
        .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
            border-bottom: 2px solid #e9ecef;
        }}
        
        .stat-card {{
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
        }}
        
        .stat-value {{
            font-size: 36px;
            font-weight: bold;
            color: #0066FF;
            margin-bottom: 5px;
        }}
        
        .stat-label {{
            color: #6c757d;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}
        
        .table-container {{
            padding: 30px;
            overflow-x: auto;
        }}
        
        table {{
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }}
        
        thead {{
            background: linear-gradient(135deg, #0066FF 0%, #00D4FF 100%);
            color: white;
        }}
        
        th {{
            padding: 16px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }}
        
        tbody tr {{
            border-bottom: 1px solid #e9ecef;
            transition: all 0.3s ease;
        }}
        
        tbody tr:hover {{
            background: #f8f9fa;
            transform: scale(1.01);
        }}
        
        td {{
            padding: 16px;
            color: #495057;
        }}
        
        .status-badge {{
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }}
        
        .status-completed {{
            background: #d4edda;
            color: #155724;
        }}
        
        .status-pending {{
            background: #fff3cd;
            color: #856404;
        }}
        
        .status-failed {{
            background: #f8d7da;
            color: #721c24;
        }}
        
        .footer {{
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #6c757d;
            font-size: 14px;
            border-top: 2px solid #e9ecef;
        }}
        
        @media print {{
            body {{
                background: white;
                padding: 0;
            }}
            
            .container {{
                box-shadow: none;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ {title}</h1>
            <p>Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        </div>
        
        <div class="stats">
            <div class="stat-card">
                <div class="stat-value">{len(reports)}</div>
                <div class="stat-label">Total Reports</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{sum(1 for r in reports if r.get('status') == 'completed')}</div>
                <div class="stat-label">Completed</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{sum(1 for r in reports if r.get('type') == 'network_scan')}</div>
                <div class="stat-label">Network Scans</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{sum(1 for r in reports if r.get('type') == 'malware_analysis')}</div>
                <div class="stat-label">Malware Analysis</div>
            </div>
        </div>
        
        <div class="table-container">
            <h2 style="margin-bottom: 20px; color: #495057;">Reports Details</h2>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Target</th>
                        <th>Status</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
"""
        
        for report in reports:
            status_class = f"status-{report.get('status', 'pending')}"
            html += f"""
                    <tr>
                        <td><code>{report.get('id', 'N/A')}</code></td>
                        <td>{report.get('type', 'N/A')}</td>
                        <td>{report.get('target', 'N/A')}</td>
                        <td><span class="status-badge {status_class}">{report.get('status', 'N/A')}</span></td>
                        <td>{report.get('created_at', 'N/A')}</td>
                    </tr>
"""
        
        html += """
                </tbody>
            </table>
        </div>
        
        <div class="footer">
            <p>AutoMium - Personal Pentesting & Malware Analysis Tool</p>
            <p>Generated automatically by AutoMium Report Engine</p>
        </div>
    </div>
</body>
</html>
"""
        
        return html
    
    @staticmethod
    def export_single_report_html(report: Dict[str, Any]) -> str:
        """
        Export a single detailed report to HTML
        
        Args:
            report: Single report dictionary
            
        Returns:
            Detailed HTML content
        """
        import json
        
        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Report: {report.get('id', 'N/A')}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Courier New', monospace;
            background: #0A0E27;
            color: #00D4FF;
            padding: 40px 20px;
        }}
        
        .terminal {{
            max-width: 1200px;
            margin: 0 auto;
            background: #0F1535;
            border: 1px solid rgba(0, 212, 255, 0.3);
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 0 40px rgba(0, 212, 255, 0.2);
        }}
        
        .header {{
            border-bottom: 2px solid #0066FF;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }}
        
        .header h1 {{
            font-size: 28px;
            margin-bottom: 10px;
            color: #00FFFF;
        }}
        
        .info-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }}
        
        .info-item {{
            background: rgba(0, 102, 255, 0.1);
            padding: 15px;
            border-radius: 8px;
            border-left: 3px solid #0066FF;
        }}
        
        .info-label {{
            font-size: 12px;
            color: #00D4FF;
            text-transform: uppercase;
            margin-bottom: 5px;
        }}
        
        .info-value {{
            font-size: 16px;
            color: #FFFFFF;
        }}
        
        .results {{
            background: #000000;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #0066FF;
            max-height: 600px;
            overflow-y: auto;
        }}
        
        .results pre {{
            white-space: pre-wrap;
            word-wrap: break-word;
            color: #00FF00;
            line-height: 1.6;
        }}
        
        .footer {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #0066FF;
            text-align: center;
            font-size: 12px;
            color: #00D4FF;
        }}
    </style>
</head>
<body>
    <div class="terminal">
        <div class="header">
            <h1>🛡️ AutoMium Analysis Report</h1>
            <p style="opacity: 0.7;">Detailed Technical Report</p>
        </div>
        
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Report ID</div>
                <div class="info-value">{report.get('id', 'N/A')}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Type</div>
                <div class="info-value">{report.get('type', 'N/A')}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Target</div>
                <div class="info-value">{report.get('target', 'N/A')}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Status</div>
                <div class="info-value">{report.get('status', 'N/A')}</div>
            </div>
            <div class="info-item">
                <div class="info-label">Date</div>
                <div class="info-value">{report.get('created_at', 'N/A')}</div>
            </div>
        </div>
        
        <h2 style="margin-bottom: 15px; color: #00FFFF;">Analysis Results</h2>
        <div class="results">
            <pre>{json.dumps(report.get('results', {}), indent=2)}</pre>
        </div>
        
        <div class="footer">
            <p>AutoMium v2.1 - Cybersecurity Analysis Platform</p>
            <p>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        </div>
    </div>
</body>
</html>
"""
        
        return html
