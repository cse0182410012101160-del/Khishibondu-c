const { v4: uuidv4 } = require("uuid");
const db = require("../../database/store");
const { getPaymentProvider } = require("./paymentProvider");
const { createNotifier } = require("../../shared/notifier");

// Simulate MFS payment gateway initialization & lock
async function fundEscrow(req, res) {
  const { orderId, paymentRail, payerMfsNumber, amount, idempotencyKey } =
    req.body;

  if (!orderId || !paymentRail) {
    return res
      .status(400)
      .json({
        success: false,
        message: "orderId and paymentRail (bKash/Nagad/Rocket) are required.",
      });
  }

  const order = db.orders.find((o) => o.id === orderId);
  if (!order) {
    return res
      .status(404)
      .json({ success: false, message: "Order not found." });
  }

  const fundedAmount = parseFloat(amount || order.totalAmount);
  if (!Number.isFinite(fundedAmount) || fundedAmount <= 0) {
    return res
      .status(400)
      .json({
        success: false,
        message: "A positive payment amount is required.",
      });
  }

  const requestKey = idempotencyKey || req.headers["idempotency-key"];
  if (!requestKey) {
    return res
      .status(400)
      .json({
        success: false,
        message: "idempotencyKey is required for payment requests.",
      });
  }

  const existing = db.escrowTransactions.find(
    (e) => e.idempotencyKey === requestKey,
  );
  if (existing) {
    return res.json({
      success: true,
      duplicate: true,
      message: "Payment request already processed.",
      escrow: existing,
      transactionId: existing.providerRef,
    });
  }

  let providerResult;
  try {
    providerResult = await getPaymentProvider(paymentRail).fund({
      amount: fundedAmount,
      payerMfsNumber,
      idempotencyKey: requestKey,
    });
  } catch (error) {
    return res
      .status(error.statusCode || 502)
      .json({ success: false, message: error.message });
  }

  // Find or create escrow transaction
  let escrow = db.escrowTransactions.find((e) => e.orderId === orderId);
  if (!escrow) {
    escrow = {
      id: `esc_${uuidv4().substring(0, 8)}`,
      orderId: order.id,
      amount: fundedAmount,
      currency: "BDT",
      payerId: req.user.id,
      payerName: req.user.name,
      beneficiaryId: order.farmerId,
      beneficiaryName: order.farmerName,
      paymentRail,
      providerRef: providerResult.providerRef,
      idempotencyKey: requestKey,
      sandbox: providerResult.sandbox,
      status: "LOCKED",
      holdStartedAt: new Date().toISOString(),
      releasedAt: null,
    };
    db.escrowTransactions.unshift(escrow);
  } else {
    escrow.status = "LOCKED";
    escrow.paymentRail = paymentRail;
    escrow.amount = fundedAmount;
    escrow.providerRef = providerResult.providerRef;
    escrow.idempotencyKey = requestKey;
    escrow.sandbox = providerResult.sandbox;
  }

  order.status = "Confirmed";
  order.escrowStatus = "LOCKED";
  order.mfsPaymentMethod = paymentRail;
  order.mfsTransactionId = providerResult.providerRef;
  order.timeline.push({
    status: "Confirmed",
    timestamp: new Date().toISOString(),
    note: `Escrow funded ${fundedAmount.toLocaleString()} BDT via ${paymentRail} (Sandbox ref: ${providerResult.providerRef})`,
  });

  return res.json({
    success: true,
    message: `Sandbox escrow locked via ${paymentRail}. Funds are protected until delivery inspection.`,
    escrow,
    transactionId: providerResult.providerRef,
    sandbox: true,
  });
}

// Release escrow manually (e.g. by buyer or admin)
function releaseEscrow(req, res) {
  const { escrowId } = req.params;
  const escrow = db.escrowTransactions.find((e) => e.id === escrowId);

  if (!escrow) {
    return res
      .status(404)
      .json({ success: false, message: "Escrow transaction not found." });
  }

  if (escrow.status === "RELEASED") {
    return res
      .status(400)
      .json({ success: false, message: "Escrow has already been released." });
  }

  escrow.status = "RELEASED";
  escrow.releasedAt = new Date().toISOString();

  const order = db.orders.find((o) => o.id === escrow.orderId);
  if (order) {
    order.status = "Paid";
    order.escrowStatus = "RELEASED";
    order.timeline.push({
      status: "Paid",
      timestamp: new Date().toISOString(),
      note: `Escrow released. ${escrow.amount.toLocaleString()} BDT disbursed to seller wallet.`,
    });

    const farmer = db.users.find((u) => u.id === order.farmerId);
    if (farmer) {
      farmer.totalFulfilledOrders = (farmer.totalFulfilledOrders || 0) + 1;
      farmer.totalSalesVolumeBdt =
        (farmer.totalSalesVolumeBdt || 0) + order.totalAmount;
    }
    void createNotifier(db.deviceTokens)
      .notifyUser(
        order.farmerId,
        {
          title: "Payment released",
          body: `Escrow payment of ${escrow.amount.toLocaleString()} BDT was released.`,
        },
        { orderId: order.id, type: "PAYMENT_RELEASED" },
      )
      .catch((error) => console.error(`Notification failed: ${error.message}`));
  }

  return res.json({
    success: true,
    message: `Escrow of ${escrow.amount} BDT released to seller.`,
    escrow,
  });
}

// Raise Dispute (Buyer or Farmer)
function raiseDispute(req, res) {
  const { orderId, reason, evidencePhotos } = req.body;

  if (!orderId || !reason) {
    return res
      .status(400)
      .json({ success: false, message: "orderId and reason are required." });
  }

  const order = db.orders.find((o) => o.id === orderId);
  if (!order) {
    return res
      .status(404)
      .json({ success: false, message: "Order not found." });
  }

  const dispute = {
    id: `dsp_${uuidv4().substring(0, 8)}`,
    orderId,
    raisedByUserId: req.user.id,
    raisedByName: req.user.name,
    againstUserId:
      req.user.id === order.buyerId ? order.farmerId : order.buyerId,
    againstByName:
      req.user.id === order.buyerId ? order.farmerName : order.buyerName,
    reason,
    status: "PENDING_REVIEW",
    evidencePhotos: evidencePhotos || [],
    adminNotes: null,
    resolution: null,
    createdAt: new Date().toISOString(),
  };

  db.disputes.unshift(dispute);

  order.status = "Disputed";
  order.disputeId = dispute.id;
  order.timeline.push({
    status: "Disputed",
    timestamp: new Date().toISOString(),
    note: `Dispute raised: ${reason}. Escrow payout frozen pending moderator review.`,
  });

  const escrow = db.escrowTransactions.find((e) => e.orderId === orderId);
  if (escrow) {
    escrow.status = "DISPUTED";
  }

  return res.status(201).json({
    success: true,
    message:
      "Dispute ticket filed successfully. Platform moderator will arbitrate.",
    dispute,
  });
}

// Get all disputes (Admin or involved user)
function getDisputes(req, res) {
  const user = req.user;
  let results = [...db.disputes];

  if (user.role !== "admin") {
    results = results.filter(
      (d) => d.raisedByUserId === user.id || d.againstUserId === user.id,
    );
  }

  return res.json({
    success: true,
    count: results.length,
    disputes: results,
  });
}

// Admin Escrow Mediation Resolution
function resolveDispute(req, res) {
  const { id } = req.params;
  const { decision, adminNotes } = req.body; // decision: 'PAY_SELLER', 'REFUND_BUYER', 'SPLIT_50_50'

  const dispute = db.disputes.find((d) => d.id === id);
  if (!dispute) {
    return res
      .status(404)
      .json({ success: false, message: "Dispute ticket not found." });
  }

  const order = db.orders.find((o) => o.id === dispute.orderId);
  const escrow = db.escrowTransactions.find(
    (e) => e.orderId === dispute.orderId,
  );

  dispute.status =
    decision === "PAY_SELLER"
      ? "RESOLVED_SELLER_PAID"
      : decision === "REFUND_BUYER"
        ? "RESOLVED_BUYER_REFUNDED"
        : "RESOLVED_SPLIT";
  dispute.resolution = decision;
  dispute.adminNotes = adminNotes || `Arbitrated by ${req.user.name}`;
  dispute.resolvedAt = new Date().toISOString();

  if (escrow) {
    if (decision === "PAY_SELLER") {
      escrow.status = "RELEASED";
      escrow.releasedAt = new Date().toISOString();
      if (order) {
        order.status = "Paid";
        order.timeline.push({
          status: "Paid",
          timestamp: new Date().toISOString(),
          note: `Moderator ruled in favor of seller. Escrow disbursed.`,
        });
      }
    } else if (decision === "REFUND_BUYER") {
      escrow.status = "REFUNDED";
      if (order) {
        order.status = "Cancelled";
        order.timeline.push({
          status: "Cancelled",
          timestamp: new Date().toISOString(),
          note: `Moderator ruled in favor of buyer. Escrow refunded.`,
        });
      }
    }
  }

  return res.json({
    success: true,
    message: `Dispute arbitrated with decision: ${decision}.`,
    dispute,
    order,
    escrow,
  });
}

module.exports = {
  fundEscrow,
  releaseEscrow,
  raiseDispute,
  getDisputes,
  resolveDispute,
};
