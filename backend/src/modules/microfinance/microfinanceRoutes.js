const express = require('express');
const router = express.Router();
const microfinanceController = require('./microfinanceController');
const { authenticateToken, authorizeRole } = require('../../middleware/auth');

router.get('/credit-score/:farmerId?', authenticateToken, microfinanceController.getFarmerCreditProfile);
router.post('/simulate-emi', microfinanceController.simulateEmi);
router.post('/apply', authenticateToken, authorizeRole('farmer', 'admin'), microfinanceController.applyForLoan);
router.get('/applications', authenticateToken, microfinanceController.getLoanApplications);
router.put('/applications/:id/status', authenticateToken, authorizeRole('ngo', 'admin'), microfinanceController.updateLoanStatus);

module.exports = router;

