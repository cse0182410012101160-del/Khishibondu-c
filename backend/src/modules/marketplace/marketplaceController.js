const { v4: uuidv4 } = require("uuid");
const db = require("../../database/store");
const { createNotifier } = require("../../shared/notifier");

// List crops with filtering, search, sorting
function getCrops(req, res) {
  const {
    category,
    division,
    district,
    minPrice,
    maxPrice,
    organic,
    status,
    search,
    farmerId,
  } = req.query;

  let results = [...db.crops];

  if (category && category !== "All") {
    results = results.filter(
      (c) => c.category.toLowerCase() === category.toLowerCase(),
    );
  }

  if (division && division !== "All") {
    results = results.filter(
      (c) => c.division.toLowerCase() === division.toLowerCase(),
    );
  }

  if (district) {
    results = results.filter(
      (c) => c.district.toLowerCase() === district.toLowerCase(),
    );
  }

  if (minPrice) {
    results = results.filter((c) => c.pricePerUnit >= parseFloat(minPrice));
  }

  if (maxPrice) {
    results = results.filter((c) => c.pricePerUnit <= parseFloat(maxPrice));
  }

  if (organic !== undefined && organic !== "") {
    const isOrganic = organic === "true";
    results = results.filter((c) => c.organicCertified === isOrganic);
  }

  if (status) {
    results = results.filter(
      (c) => c.status.toLowerCase() === status.toLowerCase(),
    );
  }

  if (farmerId) {
    results = results.filter((c) => c.farmerId === farmerId);
  }

  if (search) {
    const query = search.toLowerCase();
    results = results.filter(
      (c) =>
        c.title.toLowerCase().includes(query) ||
        (c.titleBn && c.titleBn.toLowerCase().includes(query)) ||
        c.description.toLowerCase().includes(query) ||
        c.district.toLowerCase().includes(query),
    );
  }

  return res.json({
    success: true,
    count: results.length,
    crops: results,
  });
}

// Get single crop with bids
function getCropById(req, res) {
  const { id } = req.params;
  const crop = db.crops.find((c) => c.id === id);

  if (!crop) {
    return res
      .status(404)
      .json({ success: false, message: "Crop listing not found." });
  }

  const bids = db.bids.filter((b) => b.cropId === id);

  return res.json({
    success: true,
    crop: {
      ...crop,
      bids,
    },
  });
}

// Farmer creates crop listing
function createCrop(req, res) {
  const {
    title,
    titleBn,
    category,
    categoryBn,
    quantity,
    unit,
    pricePerUnit,
    minOrderQuantity,
    description,
    descriptionBn,
    division,
    district,
    upazila,
    harvestDate,
    grade,
    organicCertified,
    images,
    coordinates,
  } = req.body;

  if (!title || !category || !quantity || !pricePerUnit) {
    return res.status(400).json({
      success: false,
      message: "Title, category, quantity, and pricePerUnit are required.",
    });
  }

  const user = req.user;
  const cropId = `crop_lot_${Date.now()}`;
  const batchQrCode = `QR-${(district || user.district || "BDG").substring(0, 3).toUpperCase()}-${new Date().getFullYear()}-${cropId.slice(-4)}`;

  const newCrop = {
    id: cropId,
    farmerId: user.id,
    farmerName: user.name,
    farmerRating: user.rating || 5.0,
    title,
    titleBn: titleBn || title,
    category,
    categoryBn: categoryBn || category,
    quantity: parseFloat(quantity),
    unit: unit || "Maund (মন)",
    pricePerUnit: parseFloat(pricePerUnit),
    totalValue: parseFloat(quantity) * parseFloat(pricePerUnit),
    minOrderQuantity: parseFloat(minOrderQuantity || 1),
    description: description || "",
    descriptionBn: descriptionBn || description || "",
    division: division || user.division || "Rajshahi",
    district: district || user.district || "Bogura",
    upazila: upazila || user.upazila || "Sadar",
    coordinates: coordinates || { lat: 24.8465, lng: 89.3777 },
    harvestDate: harvestDate || new Date().toISOString().split("T")[0],
    grade: grade || "A",
    organicCertified: Boolean(organicCertified),
    images:
      Array.isArray(images) && images.length > 0
        ? images
        : [
            "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&fit=crop",
          ],
    batchQrCode,
    status: "Listed",
    bidsCount: 0,
    createdAt: new Date().toISOString(),
  };

  db.crops.unshift(newCrop);

  return res.status(201).json({
    success: true,
    message: "Crop lot successfully listed on marketplace.",
    crop: newCrop,
  });
}

// Buyer submits bulk lot bid
function submitBid(req, res) {
  const { id } = req.params;
  const { quantityRequested, offeredPricePerUnit, note } = req.body;

  const crop = db.crops.find((c) => c.id === id);
  if (!crop) {
    return res
      .status(404)
      .json({ success: false, message: "Crop listing not found." });
  }

  if (crop.status !== "Listed" && crop.status !== "Negotiating") {
    return res.status(400).json({
      success: false,
      message: `Cannot place bid on crop with status: ${crop.status}`,
    });
  }

  const requestedQty = parseFloat(quantityRequested || crop.quantity);
  const offeredPrice = parseFloat(offeredPricePerUnit);

  if (isNaN(offeredPrice) || offeredPrice <= 0) {
    return res
      .status(400)
      .json({
        success: false,
        message: "Valid offeredPricePerUnit is required.",
      });
  }

  const bid = {
    id: `bid_${uuidv4().substring(0, 8)}`,
    cropId: crop.id,
    buyerId: req.user.id,
    buyerName: req.user.name,
    farmerId: crop.farmerId,
    quantityRequested: requestedQty,
    unit: crop.unit,
    offeredPricePerUnit: offeredPrice,
    totalOfferedAmount: requestedQty * offeredPrice,
    note: note || "",
    status: "pending", // pending, accepted, rejected
    createdAt: new Date().toISOString(),
  };

  db.bids.unshift(bid);
  crop.bidsCount = (crop.bidsCount || 0) + 1;
  crop.status = "Negotiating";

  return res.status(201).json({
    success: true,
    message: "Bulk lot bid submitted to farmer successfully.",
    bid,
  });
}

// Farmer accepts or rejects a bid
function updateBidStatus(req, res) {
  const { bidId } = req.params;
  const { status, counterOfferPrice } = req.body;

  const bid = db.bids.find((b) => b.id === bidId);
  if (!bid) {
    return res.status(404).json({ success: false, message: "Bid not found." });
  }

  if (bid.farmerId !== req.user.id && req.user.role !== "admin") {
    return res
      .status(403)
      .json({
        success: false,
        message: "Only the farmer can accept/reject this bid.",
      });
  }

  bid.status = status; // accepted, rejected, countered

  if (status === "accepted") {
    const crop = db.crops.find((c) => c.id === bid.cropId);
    if (crop) {
      crop.status = "Confirmed";
    }

    // Auto-create Order in Confirmed/Escrow state
    const orderId = `ord_${uuidv4().substring(0, 8)}`;
    const newOrder = {
      id: orderId,
      cropId: bid.cropId,
      bidId: bid.id,
      buyerId: bid.buyerId,
      buyerName: bid.buyerName,
      farmerId: bid.farmerId,
      farmerName: req.user.name,
      cropTitle: crop ? crop.title : "Harvest Lot",
      quantity: bid.quantityRequested,
      unit: bid.unit,
      pricePerUnit: bid.offeredPricePerUnit,
      totalAmount: bid.totalOfferedAmount,
      status: "Confirmed",
      escrowStatus: "LOCKED",
      mfsPaymentMethod: "bKash",
      mfsTransactionId: `TRX_MFS_${Math.floor(1000000000 + Math.random() * 9000000000)}`,
      deliveryAddress: "Divisional Wholesale Hub",
      batchQrCode: crop ? crop.batchQrCode : `QR-${orderId}`,
      timeline: [
        {
          status: "Listed",
          timestamp: crop ? crop.createdAt : new Date().toISOString(),
          note: "Lot listed",
        },
        {
          status: "Negotiating",
          timestamp: bid.createdAt,
          note: `Bid accepted by farmer`,
        },
        {
          status: "Confirmed",
          timestamp: new Date().toISOString(),
          note: `Escrow funded ${bid.totalOfferedAmount} BDT`,
        },
      ],
      createdAt: new Date().toISOString(),
    };

    db.orders.unshift(newOrder);

    // Register Escrow lock
    const escrowTx = {
      id: `esc_${uuidv4().substring(0, 8)}`,
      orderId: newOrder.id,
      amount: newOrder.totalAmount,
      currency: "BDT",
      payerId: newOrder.buyerId,
      payerName: newOrder.buyerName,
      beneficiaryId: newOrder.farmerId,
      beneficiaryName: newOrder.farmerName,
      paymentRail: "bKash",
      status: "LOCKED",
      holdStartedAt: new Date().toISOString(),
      releasedAt: null,
    };

    db.escrowTransactions.unshift(escrowTx);
    void createNotifier(db.deviceTokens)
      .notifyUser(
        bid.buyerId,
        {
          title: "Bid accepted",
          body: `${newOrder.cropTitle} bid accepted by the farmer.`,
        },
        { orderId: newOrder.id, type: "BID_ACCEPTED" },
      )
      .catch((error) => console.error(`Notification failed: ${error.message}`));

    return res.json({
      success: true,
      message: "Bid accepted! Order created and Escrow funded.",
      bid,
      order: newOrder,
      escrow: escrowTx,
    });
  }

  return res.json({
    success: true,
    message: `Bid status updated to ${status}.`,
    bid,
  });
}

module.exports = {
  getCrops,
  getCropById,
  createCrop,
  submitBid,
  updateBidStatus,
};
