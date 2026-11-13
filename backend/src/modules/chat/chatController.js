const { v4: uuidv4 } = require('uuid');
const db = require('../../database/store');

// Get threads for logged in user
function getThreads(req, res) {
  const user = req.user;
  const threads = db.chatThreads.filter(t => t.farmerId === user.id || t.buyerId === user.id);

  return res.json({
    success: true,
    threads
  });
}

// Get messages for a thread
function getMessages(req, res) {
  const { threadId } = req.params;
  const messages = db.messages.filter(m => m.threadId === threadId);

  return res.json({
    success: true,
    messages
  });
}

// Send message or counter offer
function sendMessage(req, res) {
  const { threadId } = req.params;
  const { text, offerPricePerUnit, quantity } = req.body;

  let thread = db.chatThreads.find(t => t.id === threadId);
  if (!thread) {
    // Check if new thread
    const { cropId, farmerId, buyerId } = req.body;
    thread = {
      id: threadId || `chat_th_${uuidv4().substring(0, 8)}`,
      cropId: cropId || 'crop_lot_101',
      farmerId: farmerId || (req.user.role === 'farmer' ? req.user.id : 'usr_farmer_1'),
      farmerName: req.user.role === 'farmer' ? req.user.name : 'Farmer Partner',
      buyerId: buyerId || (req.user.role === 'buyer' ? req.user.id : 'usr_buyer_1'),
      buyerName: req.user.role === 'buyer' ? req.user.name : 'Buyer Partner',
      lastMessage: text,
      lastMessageAt: new Date().toISOString(),
      unreadByFarmer: req.user.role === 'buyer' ? 1 : 0,
      unreadByBuyer: req.user.role === 'farmer' ? 1 : 0
    };
    db.chatThreads.unshift(thread);
  }

  const message = {
    id: `msg_${uuidv4().substring(0, 8)}`,
    threadId: thread.id,
    senderId: req.user.id,
    senderRole: req.user.role,
    senderName: req.user.name,
    text: text || (offerPricePerUnit ? `Submitted price offer: ${offerPricePerUnit} BDT/unit` : ''),
    offerPricePerUnit: offerPricePerUnit ? parseFloat(offerPricePerUnit) : null,
    quantity: quantity ? parseFloat(quantity) : null,
    createdAt: new Date().toISOString()
  };

  db.messages.push(message);

  thread.lastMessage = message.text;
  thread.lastMessageAt = message.createdAt;

  return res.status(201).json({
    success: true,
    message,
    thread
  });
}

module.exports = {
  getThreads,
  getMessages,
  sendMessage
};

