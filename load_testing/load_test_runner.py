import asyncio
import time
import httpx
import random
import os
import json
import sys

# Target API host to test
target_host = os.getenv("TEST_HOST", "https://plant-care-ai-1-beem.onrender.com")
# If it doesn't end with /api/v1, let's normalize it
if not target_host.endswith("/api/v1"):
    if target_host.endswith("/"):
        target_host += "api/v1"
    else:
        target_host += "/api/v1"

# Concurrency parameters
CONCURRENCY = 100 # 100 Virtual Users
DURATION = 60    # 1 Minute
MAX_REQUESTS_CAP = 15000 # Safety cap

print(f"==================================================")
print(f"Starting API Load Testing...")
print(f"Target: {target_host}")
print(f"Virtual Users (Concurrency): {CONCURRENCY}")
print(f"Duration: {DURATION} seconds")
print(f"==================================================")

# Endpoints configuration
endpoints = [
    {"path": "/health", "weight": 80, "method": "GET"},
    {"path": "/simulator?crop=Tomato&disease=Septoria_Leaf_Spot&current_severity=mild", "weight": 20, "method": "GET"}
]

# Statistics accumulator
stats = {
    "total_requests": 0,
    "success_requests": 0,
    "failed_requests": 0,
    "latencies": [],
    "rps_timeline": {}
}

lock = asyncio.Lock()

async def send_request(client, session_id):
    # Select endpoint by weight
    r = random.randint(1, 100)
    endpoint = endpoints[0]
    weight_accum = 0
    for ep in endpoints:
        weight_accum += ep["weight"]
        if r <= weight_accum:
            endpoint = ep
            break

    url = f"{target_host}{endpoint['path']}"
    method = endpoint["method"]
    
    start_time = time.time()
    success = False
    status_code = 0
    
    try:
        if method == "GET":
            response = await client.get(url, timeout=10.0)
        else:
            response = await client.post(url, json={}, timeout=10.0)
            
        status_code = response.status_code
        if 200 <= status_code < 300:
            success = True
    except Exception as e:
        status_code = 599 # timeout/network error
        
    duration = (time.time() - start_time) * 1000.0 # ms
    
    # Record stats
    async with lock:
        stats["total_requests"] += 1
        if success:
            stats["success_requests"] += 1
        else:
            stats["failed_requests"] += 1
        stats["latencies"].append(duration)
        
        # Track RPS timeline
        second_bucket = int(time.time())
        stats["rps_timeline"][second_bucket] = stats["rps_timeline"].get(second_bucket, 0) + 1

async def worker(client, worker_id, stop_time):
    while time.time() < stop_time and stats["total_requests"] < MAX_REQUESTS_CAP:
        await send_request(client, worker_id)
        # Yield to let other tasks run
        await asyncio.sleep(0.01)

async def main():
    stop_time = time.time() + DURATION
    
    # Configure connection limits for 100 concurrent users
    limits = httpx.Limits(max_keepalive_connections=CONCURRENCY, max_connections=CONCURRENCY * 2)
    
    async with httpx.AsyncClient(limits=limits) as client:
        # Spawn concurrent workers
        tasks = []
        for i in range(CONCURRENCY):
            tasks.append(asyncio.create_task(worker(client, i, stop_time)))
            
        # Wait for all workers to finish
        await asyncio.gather(*tasks)

if __name__ == "__main__":
    start_wall_time = time.time()
    
    # Run async main
    asyncio.run(main())
    
    total_elapsed = time.time() - start_wall_time
    print(f"\nLoad Test Completed in {total_elapsed:.2f} seconds.")
    
    # Compute metrics
    latencies = stats["latencies"]
    if latencies:
        latencies.sort()
        avg_latency = sum(latencies) / len(latencies)
        min_latency = latencies[0]
        max_latency = latencies[-1]
        p90_latency = latencies[int(len(latencies) * 0.90)]
        p95_latency = latencies[int(len(latencies) * 0.95)]
    else:
        avg_latency = min_latency = max_latency = p90_latency = p95_latency = 0
        
    # RPS Calculations
    # Remove first and last second to account for ramp-up/cool-down
    second_keys = sorted(list(stats["rps_timeline"].keys()))
    if len(second_keys) > 2:
        valid_seconds = second_keys[1:-1]
        rps_vals = [stats["rps_timeline"][k] for k in valid_seconds]
        avg_rps = sum(rps_vals) / len(rps_vals) if rps_vals else 0
    else:
        avg_rps = stats["total_requests"] / total_elapsed if total_elapsed > 0 else 0

    results_data = {
        "concurrency": CONCURRENCY,
        "duration_seconds": DURATION,
        "total_requests": stats["total_requests"],
        "success_requests": stats["success_requests"],
        "failed_requests": stats["failed_requests"],
        "success_rate_percent": (stats["success_requests"] / stats["total_requests"] * 100) if stats["total_requests"] > 0 else 0,
        "avg_rps": round(avg_rps, 2),
        "latency_min_ms": round(min_latency, 2),
        "latency_max_ms": round(max_latency, 2),
        "latency_avg_ms": round(avg_latency, 2),
        "latency_90th_ms": round(p90_latency, 2),
        "latency_95th_ms": round(p95_latency, 2)
    }

    # Print summary
    print(f"\n================ SUMMARY ================")
    print(f"Requests per Second (RPS): {results_data['avg_rps']} req/sec")
    print(f"Total Requests: {results_data['total_requests']}")
    print(f"Success Rate: {results_data['success_rate_percent']:.2f}%")
    print(f"Response Times:")
    print(f"  Min:     {results_data['latency_min_ms']} ms")
    print(f"  Average: {results_data['latency_avg_ms']} ms")
    print(f"  Max:     {results_data['latency_max_ms']} ms")
    print(f"  90th %:  {results_data['latency_90th_ms']} ms")
    print(f"  95th %:  {results_data['latency_95th_ms']} ms")
    print(f"=========================================")

    # Write stats to JSON file
    os.makedirs("load_testing", exist_ok=True)
    with open("load_testing/load_test_results.json", "w") as f:
        json.dump(results_data, f, indent=2)
    print("Saved load test results to load_testing/load_test_results.json")
