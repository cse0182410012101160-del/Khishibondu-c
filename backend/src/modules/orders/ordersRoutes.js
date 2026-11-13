const express = require('express');
const router = express.Router();
const ordersController = require('./ordersController');
const { authenticateToken } = require('../../middleware/auth');

router.get('/', authenticateToken, ordersController.getOrders);
router.get('/:id', authenticateToken, ordersController.getOrderById);
router.put('/:id/status', authenticateToken, ordersController.updateOrderStatus);
router.put('/:id/confirm-delivery', authenticateToken, ordersController.confirmDelivery);

module.exports = router;

