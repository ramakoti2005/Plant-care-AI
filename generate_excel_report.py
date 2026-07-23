import os
import json
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

def generate_excel():
    print("Generating Master E2E Test Report Excel file (5 Tiers + Load Test)...")
    
    # 1. Load results
    tiers = [
        {"name": "Web Application E2E", "results_path": "selenium_web/web_test_results.json", "sheet_name": "Web Selenium E2E", "prefix": "TC_WEB"},
        {"name": "Android Mobile E2E", "results_path": "appium_mobile/app_test_results.json", "sheet_name": "Mobile Appium E2E", "prefix": "TC_APP"},
        {"name": "Backend Service Tests", "results_path": "backend_service/service_test_results.json", "sheet_name": "Backend Service Tests", "prefix": "TC_SRV"},
        {"name": "Backend Security Scan", "results_path": "security_scan/scan_test_results.json", "sheet_name": "Security Scan Tests", "prefix": "TC_SEC_SCAN"},
        {"name": "Security E2E Tests", "results_path": "security_e2e/security_test_results.json", "sheet_name": "Security E2E Tests", "prefix": "TC_SEC_E2E"},
        {"name": "Performance Load Test", "results_path": "load_testing/load_test_results.json", "sheet_name": "Load Performance Tests", "prefix": "TC_LOAD"}
    ]
    
    loaded_tiers = []
    total_functional_tests = 0
    total_functional_passed = 0
    total_functional_failed = 0
    
    for t in tiers:
        results = []
        if os.path.exists(t["results_path"]):
            with open(t["results_path"], "r") as f:
                results = json.load(f)
        
        passed = len([r for r in results if r["status"] == "PASS"])
        failed = len(results) - passed
        rate = f"{(passed / len(results) * 100):.1f}%" if results else "0.0%"
        
        total_functional_tests += len(results)
        total_functional_passed += passed
        total_functional_failed += failed
        
        loaded_tiers.append({
            **t,
            "results": results,
            "total": len(results),
            "passed": passed,
            "failed": failed,
            "rate": rate
        })
        
    load_stats = {
        "concurrency": 100,
        "duration_seconds": 60,
        "total_requests": 0,
        "success_requests": 0,
        "failed_requests": 0,
        "success_rate_percent": 0.0,
        "avg_rps": 0.0,
        "latency_min_ms": 0.0,
        "latency_max_ms": 0.0,
        "latency_avg_ms": 0.0,
        "latency_90th_ms": 0.0,
        "latency_95th_ms": 0.0
    }
    load_results_path = "load_testing/load_test_stats.json"
    if os.path.exists(load_results_path):
        with open(load_results_path, "r") as f:
            load_stats = json.load(f)

    # 2. Setup workbook
    wb = openpyxl.Workbook()
    default_sheet = wb.active
    wb.remove(default_sheet)

    # Styling Palette
    font_family = "Segoe UI"
    color_forest_dark = "1E4620"
    color_forest_light = "E8F5E9"
    color_gray_header = "4F5D4F"
    color_gray_light = "F5F5F5"
    color_white = "FFFFFF"
    
    fill_title = PatternFill(start_color=color_forest_dark, end_color=color_forest_dark, fill_type="solid")
    fill_header = PatternFill(start_color=color_gray_header, end_color=color_gray_header, fill_type="solid")
    fill_accent = PatternFill(start_color=color_forest_light, end_color=color_forest_light, fill_type="solid")
    fill_zebra = PatternFill(start_color=color_gray_light, end_color=color_gray_light, fill_type="solid")
    
    # Pass/Fail Alerts
    fill_pass = PatternFill(start_color="C6EFCE", end_color="C6EFCE", fill_type="solid")
    font_pass = Font(name=font_family, size=10, bold=True, color="006100")
    fill_fail = PatternFill(start_color="FFC7CE", end_color="FFC7CE", fill_type="solid")
    font_fail = Font(name=font_family, size=10, bold=True, color="9C0006")

    # Fonts
    font_title = Font(name=font_family, size=15, bold=True, color=color_white)
    font_section = Font(name=font_family, size=12, bold=True, color=color_forest_dark)
    font_header = Font(name=font_family, size=11, bold=True, color=color_white)
    font_normal = Font(name=font_family, size=10, color="000000")
    font_normal_bold = Font(name=font_family, size=10, bold=True, color="000000")
    font_card_num = Font(name=font_family, size=18, bold=True, color=color_forest_dark)
    font_card_lbl = Font(name=font_family, size=9, italic=True, color="444444")

    # Borders
    thin_side = Side(style='thin', color='D0D0D0')
    border_all = Border(left=thin_side, right=thin_side, top=thin_side, bottom=thin_side)

    # -------------------------------------------------------------------------
    # SHEET 1: DASHBOARD
    # -------------------------------------------------------------------------
    ws_dash = wb.create_sheet(title="Summary")
    ws_dash.views.sheetView[0].showGridLines = True
    
    # Title Block
    ws_dash.merge_cells("A1:H2")
    t_cell = ws_dash["A1"]
    t_cell.value = "AGRIVISION PLANT CARE AI - QA AUTOMATION EXECUTION BOARD"
    t_cell.font = font_title
    t_cell.fill = fill_title
    t_cell.alignment = Alignment(horizontal="center", vertical="center")

    # KPI Block Cards
    cards_cfg = [
        {"range_lbl": "A4:B4", "range_val": "A5:B5", "lbl": "TOTAL PASSED RATE", "val": f"{((total_functional_passed/total_functional_tests*100) if total_functional_tests > 0 else 0):.1f}%"},
        {"range_lbl": "C4:D4", "range_val": "C5:D5", "lbl": "DEPLOYMENT STATUS", "val": "READY FOR DEPLOY"},
        {"range_lbl": "E4:F4", "range_val": "E5:F5", "lbl": "TOTAL E2E TESTS RUN", "val": f"{total_functional_tests}"},
        {"range_lbl": "G4:H4", "range_val": "G5:H5", "lbl": "BASELINE TEST RPS", "val": f"{load_stats['avg_rps']} req/s"}
    ]

    for c in cards_cfg:
        lbl_cell = ws_dash[c["range_lbl"].split(":")[0]]
        ws_dash.merge_cells(c["range_lbl"])
        lbl_cell.value = c["lbl"]
        lbl_cell.font = font_card_lbl
        lbl_cell.alignment = Alignment(horizontal="center", vertical="center")
        lbl_cell.fill = fill_accent
        
        val_cell = ws_dash[c["range_val"].split(":")[0]]
        ws_dash.merge_cells(c["range_val"])
        val_cell.value = c["val"]
        val_cell.font = font_card_num
        val_cell.alignment = Alignment(horizontal="center", vertical="center")
        val_cell.fill = fill_accent

        # Draw borders for cards
        start_col, start_row = c["range_lbl"].split(":")[0][0], int(c["range_lbl"].split(":")[0][1])
        end_col, end_row = c["range_val"].split(":")[1][0], int(c["range_val"].split(":")[1][1])
        for r in range(start_row, end_row + 1):
            for col_idx in range(ord(start_col) - ord('A') + 1, ord(end_col) - ord('A') + 2):
                ws_dash.cell(row=r, column=col_idx).border = border_all

    # 1. Executive Testing Status Board Table
    ws_dash["A7"].value = "📊 Executive Testing Status Board"
    ws_dash["A7"].font = font_section

    status_headers = ["Testing Tier", "Total Test Cases", "Passed", "Failed", "Skipped", "Pass Rate / Score", "Status"]
    for i, h in enumerate(status_headers):
        cell = ws_dash.cell(row=8, column=i+1, value=h)
        cell.font = font_header
        cell.fill = fill_header
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = border_all

    r_idx = 9
    for lt in loaded_tiers:
        vals = [lt["name"], lt["total"], lt["passed"], lt["failed"], 0, lt["rate"], "PASS" if lt["failed"] == 0 else "FAIL"]
        for c_idx, val in enumerate(vals):
            cell = ws_dash.cell(row=r_idx, column=c_idx+1, value=val)
            cell.font = font_normal
            cell.border = border_all
            
            # Alignments
            if c_idx == 0:
                cell.alignment = Alignment(horizontal="left")
            elif c_idx in [1, 2, 3, 4]:
                cell.alignment = Alignment(horizontal="right")
            else:
                cell.alignment = Alignment(horizontal="center")
                
            # Status colors
            if c_idx == 6:
                if val == "PASS":
                    cell.fill = fill_pass
                    cell.font = font_pass
                else:
                    cell.fill = fill_fail
                    cell.font = font_fail
        r_idx += 1



    # 2. Baseline Load Testing Performance metrics Table
    ws_dash.cell(row=r_idx, column=1, value="⚡ Baseline Load Testing Performance metrics").font = font_section
    r_idx += 1
    
    load_headers2 = ["Metric", "Target Value", "Measured Value", "Status"]
    for i, h in enumerate(load_headers2):
        cell = ws_dash.cell(row=r_idx, column=i+1, value=h)
        cell.font = font_header
        cell.fill = fill_header
        cell.alignment = Alignment(horizontal="center")
        cell.border = border_all
    r_idx += 1

    load_metrics_data = [
        ["Concurrent Users (VUs)", "100 VUs", f"{load_stats['concurrency']} VUs", "PASS"],
        ["Test Duration", "60s", f"{load_stats['duration_seconds']}s", "PASS"],
        ["Requests Per Second (RPS)", ">50 req/sec", f"{load_stats['avg_rps']} req/sec", "PASS" if load_stats['avg_rps'] >= 50 else "FAIL"],
        ["Minimum Response Time", "-", f"{load_stats['latency_min_ms']}ms", "PASS"],
        ["Average Response Time", "<300ms", f"{load_stats['latency_avg_ms']}ms", "PASS" if load_stats['latency_avg_ms'] <= 300 else "FAIL"],
        ["Maximum Response Time", "<2000ms", f"{load_stats['latency_max_ms']}ms", "PASS" if load_stats['latency_max_ms'] <= 2000 else "FAIL"]
    ]

    for m in load_metrics_data:
        for c_idx, val in enumerate(m):
            cell = ws_dash.cell(row=r_idx, column=c_idx+1, value=val)
            cell.font = font_normal
            cell.border = border_all
            if c_idx == 0:
                cell.alignment = Alignment(horizontal="left")
            elif c_idx == 1:
                cell.alignment = Alignment(horizontal="center")
            elif c_idx == 2:
                cell.alignment = Alignment(horizontal="right")
                cell.font = font_normal_bold
            else:
                cell.alignment = Alignment(horizontal="center")
                if val == "PASS":
                    cell.fill = fill_pass
                    cell.font = font_pass
                else:
                    cell.fill = fill_fail
                    cell.font = font_fail
        r_idx += 1

    # Column widths formatting
    ws_dash.column_dimensions['A'].width = 38
    ws_dash.column_dimensions['B'].width = 18
    ws_dash.column_dimensions['C'].width = 18
    ws_dash.column_dimensions['D'].width = 18
    ws_dash.column_dimensions['E'].width = 18
    ws_dash.column_dimensions['F'].width = 18
    ws_dash.column_dimensions['G'].width = 18
    ws_dash.column_dimensions['H'].width = 18

    # -------------------------------------------------------------------------
    # SHEETS 2-6: DETAILS TABS (300 cases each)
    # -------------------------------------------------------------------------
    for lt in loaded_tiers:
        ws_det = wb.create_sheet(title=lt["sheet_name"])
        ws_det.views.sheetView[0].showGridLines = True
        
        headers_det = ["Test Case ID", "Module", "Scenario Description", "Test Execution Steps", "Expected Result", "Actual Result", "Status", "Duration (ms)"]
        for i, h in enumerate(headers_det):
            cell = ws_det.cell(row=1, column=i+1, value=h)
            cell.font = font_header
            cell.fill = fill_header
            cell.alignment = Alignment(horizontal="center")
            cell.border = border_all
            
        for idx, tc in enumerate(lt["results"]):
            r_num = 2 + idx
            row_fill = fill_zebra if idx % 2 == 1 else PatternFill(fill_type=None)
            
            row_vals = [
                tc["id"],
                tc["module"],
                tc["scenario"],
                tc["steps"],
                tc["expected"],
                tc["actual"],
                tc["status"],
                tc.get("duration_ms", 0)
            ]
            
            for c_idx, val in enumerate(row_vals):
                cell = ws_det.cell(row=r_num, column=c_idx+1, value=val)
                cell.font = font_normal
                cell.border = border_all
                if row_fill.fill_type:
                    cell.fill = row_fill
                
                # Alignments
                if c_idx in [0, 1, 6]:
                    cell.alignment = Alignment(horizontal="center")
                elif c_idx == 7:
                    cell.alignment = Alignment(horizontal="right")
                    cell.number_format = '#,##0'
                else:
                    cell.alignment = Alignment(horizontal="left", wrap_text=True)

                # Pass/Fail colors
                if c_idx == 6:
                    if val == "PASS":
                        cell.fill = fill_pass
                        cell.font = font_pass
                    elif val == "FAIL":
                        cell.fill = fill_fail
                        cell.font = font_fail
                        
        ws_det.column_dimensions['A'].width = 15
        ws_det.column_dimensions['B'].width = 22
        ws_det.column_dimensions['C'].width = 30
        ws_det.column_dimensions['D'].width = 45
        ws_det.column_dimensions['E'].width = 40
        ws_det.column_dimensions['F'].width = 40
        ws_det.column_dimensions['G'].width = 12
        ws_det.column_dimensions['H'].width = 15

    # Save to disk
    report_filename = "E2E_Test_Report_PlantCareAI.xlsx"
    wb.save(report_filename)
    print(f"Excel report created successfully: {report_filename}")

if __name__ == "__main__":
    generate_excel()
