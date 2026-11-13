const express = require('express');
const router = express.Router();
const weatherController = require('./weatherController');

router.get('/', weatherController.getWeather);
router.get('/alerts', weatherController.getWeatherAlerts);

module.exports = router;

