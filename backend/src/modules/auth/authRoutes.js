const express = require('express');
const router = express.Router();
const authController = require('./authController');
const { authenticateToken } = require('../../middleware/auth');

router.post('/request-otp', async (req, res, next) => {
  try {
    await authController.requestOtp(req, res);
  } catch (error) {
    next(error);
  }
});
router.post('/verify-otp', authController.verifyOtp);
router.post('/register', authController.registerUser);
router.post('/demo-login', authController.demoLogin);
router.get('/demo-accounts', authController.getDemoAccounts);
router.get('/me', authenticateToken, authController.getMe);

module.exports = router;
