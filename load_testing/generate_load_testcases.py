import json
import os

def generate_load_cases():
    print("Generating 300 Load Test Cases...")
    
    modules = [
        "Concurrency Benchmarks", "Endpoint Throughput", "Latency Constraints",
        "Spike Testing", "Stress Testing", "Endurance & Soak", "Volume Testing",
        "Resource Throttling", "Network Packet Audits", "API Connection Pooling"
    ]
    
    scenarios = [
        "Verify API response time under {v} concurrent virtual users",
        "Benchmark {ep} endpoint throughput under target load of {rps} RPS",
        "Check average latency on {ep} is below {lat}ms with {v} VUs",
        "Simulate traffic spike of {v_spike} VUs on {ep} and check auto-recovery",
        "Perform stress test by scaling VUs to {v_stress} on {ep} until degradation",
        "Run soak test of {v} VUs for {duration} min on {ep} to monitor memory leaks",
        "Assess response payload compression efficiency under {v} concurrent requests",
        "Evaluate CPU usage throttling with {v} active requests on {ep}",
        "Audit packet drop rates under simulated packet corruption at {v} VUs",
        "Validate database connection pool availability under {v} concurrent queries"
    ]
    
    endpoints_list = ["/analyze", "/plants/history", "/auth/token", "/auth/register", "/health", "/simulator"]
    
    test_cases = []
    
    for i in range(1, 301):
        tc_id = f"TC_LOAD_{i:03d}"
        module = modules[(i - 1) % len(modules)]
        
        # Pick scenario layout
        scen_idx = (i - 1) % len(scenarios)
        scen_tpl = scenarios[scen_idx]
        
        # Parameter substitutions
        v = 10 + (i * 3) % 200
        rps = 50 + (i * 5) % 300
        lat = 100 + (i * 10) % 800
        v_spike = 150 + (i * 4) % 400
        v_stress = 300 + (i * 10) % 1000
        duration = 5 + (i * 2) % 60
        ep = endpoints_list[(i - 1) % len(endpoints_list)]
        
        scenario = scen_tpl.format(v=v, ep=ep, rps=rps, lat=lat, v_spike=v_spike, v_stress=v_stress, duration=duration)
        
        steps = (
            f"1. Setup Jmeter/Locust framework.\n"
            f"2. Configure target endpoint: {ep}.\n"
            f"3. Ramp up to {v} Virtual Users in 10s.\n"
            f"4. Maintain load for {duration} seconds.\n"
            f"5. Capture latency percentiles and system resource metrics."
        )
        
        expected = (
            f"Response code 200 OK. Success rate is 100%. "
            f"Avg response latency is within target threshold. No HTTP errors."
        )
        
        test_cases.append({
            "id": tc_id,
            "module": module,
            "scenario": scenario,
            "steps": steps,
            "expected": expected
        })
        
    os.makedirs("load_testing", exist_ok=True)
    with open("load_testing/load_test_cases.json", "w") as f:
        json.dump(test_cases, f, indent=2)
        
    print(f"Generated 300 test cases at load_testing/load_test_cases.json")

if __name__ == "__main__":
    generate_load_cases()
