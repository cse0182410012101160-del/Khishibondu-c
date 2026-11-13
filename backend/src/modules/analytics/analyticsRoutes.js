const express = require('express');
const router = express.Router();
const analyticsController = require('./analyticsController');
const { authenticateToken, authorizeRole } = require('../../middleware/auth');

router.get('/farmer/:farmerId?', authenticateToken, analyticsController.getFarmerAnalytics);
router.get('/admin', authenticateToken, authorizeRole('admin'), analyticsController.getAdminAnalytics);
router.get('/ngo', authenticateToken, authorizeRole('ngo', 'admin'), analyticsController.getNgoAnalytics);

module.exports = router;

