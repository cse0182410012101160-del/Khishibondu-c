const express = require('express');
const router = express.Router();
const chatController = require('./chatController');
const { authenticateToken } = require('../../middleware/auth');

router.get('/threads', authenticateToken, chatController.getThreads);
router.get('/threads/:threadId/messages', authenticateToken, chatController.getMessages);
router.post('/threads/:threadId/messages', authenticateToken, chatController.sendMessage);

module.exports = router;

