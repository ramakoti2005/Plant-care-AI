import os
import json

def generate_summary():
    print("Generating GitHub Actions step summary...")
    summary_file = os.getenv("GITHUB_STEP_SUMMARY")
    if not summary_file:
        print("GITHUB_STEP_SUMMARY not set. Skipping GitHub summary generation.")
        return

    # Load results
    web_results = []
    if os.path.exists("selenium_web/web_test_results.json"):
        with open("selenium_web/web_test_results.json", "r") as f:
            web_results = json.load(f)
            
    app_results = []
    if os.path.exists("appium_mobile/app_test_results.json"):
        with open("appium_mobile/app_test_results.json", "r") as f:
            app_results = json.load(f)
            
    load_stats = {}
    if os.path.exists("load_testing/load_test_results.json"):
        with open("load_testing/load_test_results.json", "r") as f:
            load_stats = json.load(f)

    # 1. Dashboard summary header
    markdown = []
    markdown.append("# AgriVision Plant Care AI - QA Automation Execution Report\n")
    
    # 2. Executive Summary Cards
    web_total = len(web_results)
    web_passed = len([r for r in web_results if r["status"] == "PASS"])
    web_failed = web_total - web_passed
    web_rate = f"{(web_passed/web_total*100):.1f}%" if web_total > 0 else "N/A"
    
    app_total = len(app_results)
    app_passed = len([r for r in app_results if r["status"] == "PASS"])
    app_failed = app_total - app_passed
    app_rate = f"{(app_passed/app_total*100):.1f}%" if app_total > 0 else "N/A"

    markdown.append("## Executive Metrics Summary\n")
    markdown.append("| Metric | Web Selenium E2E | Mobile Appium E2E |")
    markdown.append("| --- | --- | --- |")
    markdown.append(f"| **Total Test Cases** | {web_total} | {app_total} |")
    markdown.append(f"| **Passed Cases** | {web_passed} | {app_passed} |")
    markdown.append(f"| **Failed Cases** | {web_failed} | {app_failed} |")
    markdown.append(f"| **Success Rate** | **{web_rate}** | **{app_rate}** |\n")

    # 3. Load Testing Metrics
    if load_stats:
        markdown.append("## API Load Test Performance Summary")
        markdown.append(f"- **Concurrency**: {load_stats.get('concurrency')} Virtual Users")
        markdown.append(f"- **Duration**: {load_stats.get('duration_seconds')} seconds")
        markdown.append(f"- **Total Requests**: {load_stats.get('total_requests')}")
        markdown.append(f"- **Average RPS**: **{load_stats.get('avg_rps')} req/sec**")
        markdown.append(f"- **Success Rate**: {load_stats.get('success_rate_percent'):.2f}%")
        markdown.append(f"- **Response Time (Min / Avg / Max)**: {load_stats.get('latency_min_ms')} ms / **{load_stats.get('latency_avg_ms')} ms** / {load_stats.get('latency_max_ms')} ms")
        markdown.append(f"- **95th Percentile Latency**: {load_stats.get('latency_95th_ms')} ms\n")

    # Helper function to render a table of test cases
    def make_test_table(results):
        lines = []
        lines.append("| Test ID | Module | Scenario | Expected | Status | Duration |")
        lines.append("| --- | --- | --- | --- | --- | --- |")
        for tc in results:
            status_emoji = "🟢 PASS" if tc["status"] == "PASS" else "🔴 FAIL"
            # escape markdown characters in scenario/expected/actual
            scen = tc["scenario"].replace("|", "\\|")
            exp = tc["expected"].replace("|", "\\|")
            lines.append(f"| `{tc['id']}` | {tc['module']} | {scen} | {exp} | **{status_emoji}** | {tc.get('duration_ms', 0)} ms |")
        return "\n".join(lines)

    # 4. Web Selenium Detailed Cases (Collapsible)
    markdown.append("## Detailed E2E Web Test Cases (300 cases)")
    markdown.append("<details>")
    markdown.append("<summary>🔍 Click to Expand / Collapse Web Test Cases</summary>\n")
    markdown.append(make_test_table(web_results))
    markdown.append("\n</details>\n")

    # 5. Mobile Appium Detailed Cases (Collapsible)
    markdown.append("## Detailed E2E Mobile Test Cases (300 cases)")
    markdown.append("<details>")
    markdown.append("<summary>📱 Click to Expand / Collapse Mobile Test Cases</summary>\n")
    markdown.append(make_test_table(app_results))
    markdown.append("\n</details>\n")

    # Write to summary file
    with open(summary_file, "a", encoding="utf-8") as f:
        f.write("\n".join(markdown))
        
    print("Successfully wrote QA summary report to GITHUB_STEP_SUMMARY.")

if __name__ == "__main__":
    generate_summary()
