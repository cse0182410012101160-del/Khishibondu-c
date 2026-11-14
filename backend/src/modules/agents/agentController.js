const db = require("../../database/store");
const { createFarmerForAgent, createLotForFarmer } = require("./agentService");

function createFarmer(req, res) {
  try {
    const farmer = createFarmerForAgent(req.body, req.user.id);
    db.users.push(farmer);
    return res.status(201).json({ success: true, farmer });
  } catch (error) {
    return res.status(400).json({ success: false, message: error.message });
  }
}

function createLot(req, res) {
  const farmer = db.users.find(
    (user) => user.id === req.body.farmerId && user.role === "farmer",
  );
  try {
    const lot = createLotForFarmer(req.body, req.user.id, farmer);
    db.crops.unshift(lot);
    return res.status(201).json({ success: true, lot });
  } catch (error) {
    return res.status(400).json({ success: false, message: error.message });
  }
}

module.exports = { createFarmer, createLot };
