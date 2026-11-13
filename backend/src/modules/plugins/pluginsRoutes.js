const express = require('express');
const router = express.Router();
const pluginsController = require('./pluginsController');
const { authenticateToken, authorizeRole } = require('../../middleware/auth');

router.get('/', pluginsController.getPlugins);
router.put('/:id/toggle', authenticateToken, authorizeRole('admin'), pluginsController.togglePlugin);
router.post('/register', authenticateToken, authorizeRole('admin'), pluginsController.registerPlugin);

module.exports = router;

