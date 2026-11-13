const express = require('express');
const router = express.Router();
const escrowController = require('./escrowController');
const { authenticateToken, authorizeRole } = require('../../middleware/auth');

router.post('/fund', authenticateToken, escrowController.fundEscrow);
router.post('/release/:escrowId', authenticateToken, escrowController.releaseEscrow);
router.post('/dispute', authenticateToken, escrowController.raiseDispute);
router.get('/disputes', authenticateToken, escrowController.getDisputes);
router.put('/disputes/:id/resolve', authenticateToken, authorizeRole('admin'), escrowController.resolveDispute);

module.exports = router;

