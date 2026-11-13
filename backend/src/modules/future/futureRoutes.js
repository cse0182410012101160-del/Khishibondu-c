const express = require('express');
const router = express.Router();
const controller = require('./futureController');
const { authenticateToken, authorizeRole } = require('../../middleware/auth');

router.get('/input-shop', authenticateToken, authorizeRole('farmer', 'admin'), controller.getInputShop);
router.post('/input-shop/bnpl', authenticateToken, authorizeRole('farmer'), controller.applyBnpl);
router.get('/sensors', authenticateToken, authorizeRole('farmer', 'admin'), controller.getSensors);
router.get('/export-matches', authenticateToken, authorizeRole('farmer', 'buyer', 'admin'), controller.getExportMatches);
router.post('/export-inquiries', authenticateToken, authorizeRole('farmer', 'buyer'), controller.createExportInquiry);

module.exports = router;
