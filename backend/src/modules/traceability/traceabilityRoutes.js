const express = require('express');
const router = express.Router();
const traceabilityController = require('./traceabilityController');
const { authenticateToken, authorizeRole } = require('../../middleware/auth');

// Public QR scan endpoint
router.get('/:batchQrCode', traceabilityController.getBatchTraceability);

// Farmer generates batch QR
router.post('/generate', authenticateToken, authorizeRole('farmer', 'admin'), traceabilityController.generateBatchQr);

module.exports = router;

