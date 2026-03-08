"""Reports API routes"""

from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse, Response
from app.models.database import get_report, get_all_reports, delete_report
from app.services.export_service import ReportExporter
import json
import os

router = APIRouter()


@router.get("/")
async def list_reports(limit: int = 50):
    """Get all reports with optional limit"""
    try:
        reports = get_all_reports(limit)
        return {
            "reports": reports,
            "count": len(reports)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/export-all")
async def export_all_reports(format: str = "csv"):
    """Export all reports in CSV or HTML format"""
    try:
        reports = get_all_reports(1000)
        
        if format.lower() == "csv":
            csv_content = ReportExporter.to_csv(reports)
            
            return Response(
                content=csv_content,
                media_type="text/csv",
                headers={
                    "Content-Disposition": "attachment; filename=all_reports.csv"
                }
            )
        
        elif format.lower() == "html":
            html_content = ReportExporter.to_html(reports, title="AutoMium - All Reports")
            
            return Response(
                content=html_content,
                media_type="text/html",
                headers={
                    "Content-Disposition": "attachment; filename=all_reports.html"
                }
            )
        
        else:
            raise HTTPException(status_code=400, detail=f"Unsupported format: {format}")
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{report_id}")
async def get_single_report(report_id: str):
    """Get a specific report by ID"""
    report = get_report(report_id)
    
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    return {"report": report}


@router.delete("/{report_id}")
async def remove_report(report_id: str):
    """Delete a specific report"""
    success = delete_report(report_id)
    
    if not success:
        raise HTTPException(status_code=404, detail="Report not found")
    
    return {"status": "success", "message": "Report deleted"}


@router.post("/export/{report_id}")
async def export_report(report_id: str, format: str = "json"):
    """Export report in JSON, PDF, CSV, or HTML format"""
    report = get_report(report_id)
    
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    if format.lower() == "json":
        # Save to JSON file
        filename = f"report_{report_id}.json"
        filepath = f"data/{filename}"
        
        os.makedirs("data", exist_ok=True)
        with open(filepath, 'w') as f:
            json.dump(report, f, indent=2)
        
        return FileResponse(
            filepath,
            media_type='application/json',
            filename=filename
        )
    
    elif format.lower() == "csv":
        # Export to CSV
        csv_content = ReportExporter.to_csv([report])
        
        return Response(
            content=csv_content,
            media_type="text/csv",
            headers={
                "Content-Disposition": f"attachment; filename=report_{report_id}.csv"
            }
        )
    
    elif format.lower() == "html":
        # Export to HTML (detailed terminal style)
        html_content = ReportExporter.export_single_report_html(report)
        
        return Response(
            content=html_content,
            media_type="text/html",
            headers={
                "Content-Disposition": f"attachment; filename=report_{report_id}.html"
            }
        )
    
    elif format.lower() == "pdf":
        # Generate PDF (requires reportlab)
        try:
            from reportlab.lib import colors
            from reportlab.lib.pagesizes import letter
            from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
            from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
            from reportlab.lib.units import inch
            
            filename = f"report_{report_id}.pdf"
            filepath = f"data/{filename}"
            
            doc = SimpleDocTemplate(filepath, pagesize=letter)
            styles = getSampleStyleSheet()
            story = []
            
            # Title
            title_style = ParagraphStyle(
                'CustomTitle',
                parent=styles['Heading1'],
                fontSize=24,
                textColor=colors.HexColor('#0066FF'),
                spaceAfter=30
            )
            
            story.append(Paragraph("AutoMium Security Report", title_style))
            story.append(Spacer(1, 0.3*inch))
            
            # Metadata table
            metadata = [
                ["Report ID", report["id"]],
                ["Type", report["type"]],
                ["Target", report["target"]],
                ["Date", report["created_at"]],
                ["Status", report["status"]]
            ]
            
            table = Table(metadata, colWidths=[2*inch, 4*inch])
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#0066FF')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 14),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('GRID', (0, 0), (-1, -1), 1, colors.black),
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#E6F0FF')])
            ]))
            
            story.append(table)
            story.append(Spacer(1, 0.3*inch))
            
            # Results
            story.append(Paragraph("Analysis Results", styles['Heading2']))
            story.append(Spacer(1, 0.2*inch))
            
            # Format results as text
            results_text = report["results"]
            if len(results_text) > 5000:
                results_text = results_text[:5000] + "... (truncated)"
            
            code_style = ParagraphStyle(
                'Code',
                parent=styles['Normal'],
                fontName='Courier',
                fontSize=8,
                leftIndent=20,
                rightIndent=20,
                backColor=colors.HexColor('#F5F5F5'),
                borderColor=colors.HexColor('#CCCCCC'),
                borderWidth=1,
                spaceAfter=10
            )
            
            story.append(Paragraph(
                results_text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"),
                code_style
            ))
            
            # Build PDF
            doc.build(story)
            
            return FileResponse(
                filepath,
                media_type='application/pdf',
                filename=filename
            )
            
        except ImportError:
            raise HTTPException(
                status_code=503,
                detail="ReportLab not installed. Install with: pip install reportlab"
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"PDF generation failed: {str(e)}")
    else:
        raise HTTPException(status_code=400, detail="Unsupported format. Use 'json' or 'pdf'")
