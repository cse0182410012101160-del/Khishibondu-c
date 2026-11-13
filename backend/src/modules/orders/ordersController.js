const { v4: uuidv4 } = require('uuid');
const db = require('../../database/store');

// Get orders based on user role
function getOrders(req, res) {
  const user = req.user;
  let results = [...db.orders];

  if (user.role === 'farmer') {
    results = results.filter(o => o.farmerId === user.id);
  } else if (user.role === 'buyer') {
    results = results.filter(o => o.buyerId === user.id);
  } // NGO and Admin can view all or filtered

  const { status } = req.query;
  if (status) {
    results = results.filter(o => o.status.toLowerCase() === status.toLowerCase());
  }

  return res.json({
    success: true,
    count: results.length,
    orders: results
  });
}

// Get single order with complete timeline
function getOrderById(req, res) {
  const { id } = req.params;
  const order = db.orders.find(o => o.id === id);

  if (!order) {
    return res.status(404).json({ success: false, message: 'Order not found.' });
  }

  const escrow = db.escrowTransactions.find(e => e.orderId === id);
  const dispute = db.disputes.find(d => d.orderId === id);

  return res.json({
    success: true,
    order: {
      ...order,
      escrow,
      dispute
    }
  });
}

// Transition state machine
function updateOrderStatus(req, res) {
  const { id } = req.params;
  const { nextStatus, note } = req.body;

  const validTransitions = {
    'Listed': ['Negotiating', 'Confirmed', 'Cancelled'],
    'Negotiating': ['Confirmed', 'Cancelled'],
    'Confirmed': ['Delivered', 'Disputed', 'Cancelled'],
    'Delivered': ['Paid', 'Disputed'],
    'Disputed': ['Paid', 'Cancelled'],
    'Paid': []
  };

  const order = db.orders.find(o => o.id === id);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Order not found.' });
  }

  const allowed = validTransitions[order.status] || [];
  if (!allowed.includes(nextStatus) && req.user.role !== 'admin') {
    return res.status(400).json({
      success: false,
      message: `Invalid state transition from '${order.status}' to '${nextStatus}'. Allowed: ${allowed.join(', ')}`
    });
  }

  order.status = nextStatus;
  order.timeline.push({
    status: nextStatus,
    timestamp: new Date().toISOString(),
    note: note || `Order updated to ${nextStatus} by ${req.user.name}`
  });

  // If status becomes Paid, release escrow
  if (nextStatus === 'Paid') {
    order.escrowStatus = 'RELEASED';
    const escrow = db.escrowTransactions.find(e => e.orderId === order.id);
    if (escrow) {
      escrow.status = 'RELEASED';
      escrow.releasedAt = new Date().toISOString();
    }

    // Update farmer fulfillment stats
    const farmer = db.users.find(u => u.id === order.farmerId);
    if (farmer) {
      farmer.totalFulfilledOrders = (farmer.totalFulfilledOrders || 0) + 1;
      farmer.totalSalesVolumeBdt = (farmer.totalSalesVolumeBdt || 0) + order.totalAmount;
    }
  }

  return res.json({
    success: true,
    message: `Order status advanced to '${nextStatus}'.`,
    order
  });
}

// Buyer confirms delivery -> triggers escrow release to farmer
function confirmDelivery(req, res) {
  const { id } = req.params;
  const order = db.orders.find(o => o.id === id);

  if (!order) {
    return res.status(404).json({ success: false, message: 'Order not found.' });
  }

  if (order.buyerId !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Only the ordering buyer or admin can confirm delivery.' });
  }

  order.status = 'Paid';
  order.escrowStatus = 'RELEASED';
  order.timeline.push({
    status: 'Delivered',
    timestamp: new Date().toISOString(),
    note: 'Delivery verified by buyer at unloading depot.'
  });
  order.timeline.push({
    status: 'Paid',
    timestamp: new Date().toISOString(),
    note: `Escrow funds of ${order.totalAmount} BDT released to farmer via ${order.mfsPaymentMethod}.`
  });

  const escrow = db.escrowTransactions.find(e => e.orderId === order.id);
  if (escrow) {
    escrow.status = 'RELEASED';
    escrow.releasedAt = new Date().toISOString();
  }

  // Update farmer sales stats
  const farmer = db.users.find(u => u.id === order.farmerId);
  if (farmer) {
    farmer.totalFulfilledOrders = (farmer.totalFulfilledOrders || 0) + 1;
    farmer.totalSalesVolumeBdt = (farmer.totalSalesVolumeBdt || 0) + order.totalAmount;
  }

  return res.json({
    success: true,
    message: 'Delivery confirmed! Escrow funds released to farmer.',
    order,
    escrow
  });
}

module.exports = {
  getOrders,
  getOrderById,
  updateOrderStatus,
  confirmDelivery
};

