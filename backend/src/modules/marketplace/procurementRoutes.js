const express = require('express');
const router = express.Router();
const controller = require('./procurementController');
const { authenticateToken, authorizeRole } = require('../../middleware/auth');

router.get('/', authenticateToken, authorizeRole('buyer', 'admin'), controller.getProcurementView);

module.exports = router;
