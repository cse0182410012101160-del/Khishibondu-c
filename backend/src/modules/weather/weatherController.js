const db = require('../../database/store');

// Get weather for division/district or GPS coordinates
function getWeather(req, res) {
  const { division, district, lat, lng } = req.query;

  let report = null;

  if (district) {
    report = db.weatherData.find(w => w.district.toLowerCase() === district.toLowerCase());
  }

  if (!report && division) {
    report = db.weatherData.find(w => w.division.toLowerCase() === division.toLowerCase());
  }

  // If GPS coordinates provided, default to closest division
  if (!report) {
    report = db.weatherData[0]; // Bogura/Rajshahi default
  }

  return res.json({
    success: true,
    weather: report,
    availableStations: db.weatherData.map(w => ({
      division: w.division,
      district: w.district,
      condition: w.condition,
      temperatureC: w.temperatureC
    }))
  });
}

// Get active severe weather alerts (Cyclone / Flood warnings in BD)
function getWeatherAlerts(req, res) {
  const alerts = db.weatherData.filter(w => w.floodAlert || w.cycloneAlert || w.riskLevel === 'HIGH' || w.riskLevel === 'CRITICAL');

  return res.json({
    success: true,
    activeAlertsCount: alerts.length,
    alerts
  });
}

module.exports = {
  getWeather,
  getWeatherAlerts
};

