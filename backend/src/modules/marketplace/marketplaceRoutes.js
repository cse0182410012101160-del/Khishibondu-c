const express = require('express');
const router = express.Router();
const marketplaceController = require('./marketplaceController');
const { authenticateToken, authorizeRole } = require('../../middleware/auth');

router.get('/crops', marketplaceController.getCrops);
router.get('/crops/:id', marketplaceController.getCropById);

// Farmer only or admin
router.post('/crops', authenticateToken, authorizeRole('farmer', 'admin'), marketplaceController.createCrop);

// Buyer submits bid
router.post('/crops/:id/bids', authenticateToken, authorizeRole('buyer', 'admin'), marketplaceController.submitBid);

// Farmer accepts/rejects bid
router.put('/bids/:bidId/status', authenticateToken, authorizeRole('farmer', 'admin'), marketplaceController.updateBidStatus);

module.exports = router;

