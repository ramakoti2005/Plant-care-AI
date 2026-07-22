import os
import json
import urllib.request
import asyncio
from typing import List, Dict

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")

def _fetch_url_sync(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": "PlantCareAI/1.0"})
    with urllib.request.urlopen(req, timeout=5) as response:
        return json.loads(response.read().decode("utf-8"))

async def fetch_url_async(url: str) -> dict:
    try:
        return await asyncio.to_thread(_fetch_url_sync, url)
    except Exception as e:
        print(f"Weather API request failed: {e}")
        return {}

async def get_weather_alerts(lat: float, lon: float) -> List[Dict[str, str]]:
    alerts = []
    temp = None
    humidity = None
    is_raining = False

    # Try OpenWeatherMap first if key is present
    if OPENWEATHER_API_KEY and OPENWEATHER_API_KEY.strip() and OPENWEATHER_API_KEY != "YOUR_OPENWEATHER_API_KEY":
        url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={OPENWEATHER_API_KEY.strip()}&units=metric"
        data = await fetch_url_async(url)
        if data and "main" in data:
            temp = data["main"].get("temp")
            humidity = data["main"].get("humidity")
            weather = data.get("weather", [])
            if weather:
                weather_main = weather[0].get("main", "").lower()
                if "rain" in weather_main or "thunderstorm" in weather_main or "drizzle" in weather_main:
                    is_raining = True

    # Fallback to keyless Open-Meteo API
    if temp is None or humidity is None:
        url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,weather_code"
        data = await fetch_url_async(url)
        if data and "current" in data:
            temp = data["current"].get("temperature_2m")
            humidity = data["current"].get("relative_humidity_2m")
            wcode = data["current"].get("weather_code")
            # WMO Weather codes for rain/drizzle/thunderstorm
            if wcode in [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99]:
                is_raining = True

    # If both failed, use default/mock values so the UI doesn't break
    if temp is None or humidity is None:
        print("Both Weather APIs failed. Falling back to default baseline values.")
        temp = 25.0
        humidity = 60.0

    # Climate Alert Rules Evaluation
    if temp < 10.0:
        alerts.append({
            "title": "Frost Risk Warning ❄️",
            "body": f"Cold temperature of {temp}°C detected. Alert user to cover or move plants indoors."
        })
    elif temp > 35.0:
        alerts.append({
            "title": "Drought & Heat Warning ☀️",
            "body": f"High temperature of {temp}°C detected. Advise extra irrigation and shade for plants."
        })

    if humidity > 80.0:
        alerts.append({
            "title": "Fungal Disease Risk 🌧️",
            "body": f"High humidity of {humidity}% detected! Inspect leaves for fungal spots or mildew."
        })

    if is_raining:
        alerts.append({
            "title": "Rain Forecasted 🌧️",
            "body": "Rain or thunderstorm detected. Advise skipping manual watering today."
        })

    return alerts
