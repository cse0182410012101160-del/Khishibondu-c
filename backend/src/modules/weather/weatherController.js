const db = require("../../database/store");
const districts = require("../../../data/districts.json");

const weatherCache = new Map();
const CACHE_TTL_MS = 30 * 60 * 1000;

async function fetchForecast(district) {
  const coordinates = districts[district.toLowerCase()];
  if (!coordinates) return null;

  const cached = weatherCache.get(district.toLowerCase());
  if (cached && cached.expiresAt > Date.now()) return cached.value;

  const params = new URLSearchParams({
    latitude: coordinates.lat,
    longitude: coordinates.lon,
    forecast_days: "3",
    timezone: "Asia/Dhaka",
    daily:
      "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max",
  });
  const response = await fetch(
    `https://api.open-meteo.com/v1/forecast?${params}`,
  );
  if (!response.ok) throw new Error(`Open-Meteo returned ${response.status}`);

  const data = await response.json();
  const value = {
    district: coordinates.name,
    coordinates,
    forecast: data.daily.time.map((date, index) => ({
      date,
      weatherCode: data.daily.weather_code[index],
      maxTemperatureC: data.daily.temperature_2m_max[index],
      minTemperatureC: data.daily.temperature_2m_min[index],
      precipitationProbability: data.daily.precipitation_probability_max[index],
    })),
  };
  weatherCache.set(district.toLowerCase(), {
    value,
    expiresAt: Date.now() + CACHE_TTL_MS,
  });
  return value;
}

// Get weather for division/district or GPS coordinates
async function getWeather(req, res) {
  const { division, district } = req.query;

  if (district) {
    try {
      const forecast = await fetchForecast(district);
      if (forecast) return res.json({ success: true, weather: forecast });
    } catch (error) {
      console.error(
        `Weather provider failed for ${district}: ${error.message}`,
      );
    }
  }

  let report = null;

  if (district) {
    report = db.weatherData.find(
      (w) => w.district.toLowerCase() === district.toLowerCase(),
    );
  }

  if (!report && division) {
    report = db.weatherData.find(
      (w) => w.division.toLowerCase() === division.toLowerCase(),
    );
  }

  // If GPS coordinates provided, default to closest division
  if (!report) {
    report = db.weatherData[0]; // Bogura/Rajshahi default
  }

  return res.json({
    success: true,
    weather: report,
    forecast: report
      ? [{ ...report, date: new Date().toISOString().slice(0, 10) }]
      : [],
    availableStations: db.weatherData.map((w) => ({
      division: w.division,
      district: w.district,
      condition: w.condition,
      temperatureC: w.temperatureC,
    })),
  });
}

// Get active severe weather alerts (Cyclone / Flood warnings in BD)
function getWeatherAlerts(req, res) {
  const alerts = db.weatherData.filter(
    (w) =>
      w.floodAlert ||
      w.cycloneAlert ||
      w.riskLevel === "HIGH" ||
      w.riskLevel === "CRITICAL",
  );

  return res.json({
    success: true,
    activeAlertsCount: alerts.length,
    alerts,
  });
}

module.exports = {
  getWeather,
  getWeatherAlerts,
};
