const { v4: uuidv4 } = require("uuid");

function createFarmerForAgent(data, agentId) {
  if (data.consent !== true) throw new Error("Farmer consent must be true.");
  if (!data.name || !data.phone || !data.district)
    throw new Error("name, phone, and district are required.");
  return {
    id: `usr_farmer_${uuidv4().slice(0, 8)}`,
    phone: data.phone,
    name: data.name,
    role: "farmer",
    district: data.district,
    agentId,
    agentConsent: true,
    createdAt: new Date().toISOString(),
  };
}

function createLotForFarmer(data, agentId, farmer) {
  if (!farmer || farmer.agentId !== agentId || farmer.agentConsent !== true)
    throw new Error("Farmer is not consented to this agent.");
  if (!data.title || !data.cropType || !data.quantity || !data.askPricePerUnit)
    throw new Error(
      "title, cropType, quantity, and askPricePerUnit are required.",
    );
  return {
    id: `crop_lot_${uuidv4().slice(0, 8)}`,
    farmerId: farmer.id,
    agentId,
    cropType: data.cropType,
    title: data.title,
    quantity: Number(data.quantity),
    unit: data.unit || "kg",
    askPricePerUnit: Number(data.askPricePerUnit),
    district: farmer.district,
    status: "Listed",
    createdAt: new Date().toISOString(),
  };
}

module.exports = { createFarmerForAgent, createLotForFarmer };
