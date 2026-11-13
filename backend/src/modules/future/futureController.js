const { v4: uuidv4 } = require('uuid');

const products = [
  { id: 'input_001', name: 'Urea fertilizer', nameBn: 'ইউরিয়া সার', priceBdt: 1850, unit: '50 kg bag', vendor: 'Krishi Input Cooperative' },
  { id: 'input_002', name: 'Certified onion seed', nameBn: 'মানসম্মত পেঁয়াজ বীজ', priceBdt: 920, unit: '500 g pack', vendor: 'North Bengal Seed Hub' },
  { id: 'input_003', name: 'Organic compost', nameBn: 'জৈব কম্পোস্ট', priceBdt: 650, unit: '25 kg bag', vendor: 'Green Soil Network' }
];

const telemetry = [
  { sensorId: 'SENSOR-BOG-01', district: 'Bogura', moisturePct: 34, nitrogenPpm: 42, phosphorusPpm: 18, potassiumPpm: 55, batteryPct: 87, recordedAt: new Date().toISOString() },
  { sensorId: 'SENSOR-DIN-02', district: 'Dinajpur', moisturePct: 28, nitrogenPpm: 36, phosphorusPpm: 21, potassiumPpm: 48, batteryPct: 73, recordedAt: new Date().toISOString() }
];

const matches = [
  { id: 'export_001', cropType: 'Premium potato', destination: 'Dubai, UAE', requiredQuantityKg: 5000, targetPriceBdtPerKg: 72, certifications: ['GlobalGAP', 'Cold chain'] },
  { id: 'export_002', cropType: 'Aromatic rice', destination: 'Doha, Qatar', requiredQuantityKg: 3000, targetPriceBdtPerKg: 118, certifications: ['Moisture certificate', 'Phytosanitary certificate'] }
];

function getInputShop(req, res) {
  return res.json({ success: true, sandbox: true, products, financing: { enabled: true, maxTenureMonths: 6, annualRatePct: 8.5 } });
}

function applyBnpl(req, res) {
  const { productId, quantity, tenureMonths } = req.body;
  const product = products.find(item => item.id === productId);
  if (!product || !Number.isFinite(Number(quantity)) || Number(quantity) <= 0) {
    return res.status(400).json({ success: false, message: 'Valid productId and positive quantity are required.' });
  }
  const months = Number(tenureMonths || 3);
  if (![3, 6].includes(months)) {
    return res.status(400).json({ success: false, message: 'Sandbox BNPL tenure must be 3 or 6 months.' });
  }
  const principal = product.priceBdt * Number(quantity);
  return res.status(201).json({ success: true, sandbox: true, application: { id: `bnpl_${uuidv4().slice(0, 8)}`, farmerId: req.user.id, productId, principalBdt: principal, tenureMonths: months, monthlyInstallmentBdt: Math.ceil((principal * 1.085) / months), status: 'PENDING_REVIEW' } });
}

function getSensors(req, res) {
  const district = req.query.district;
  const readings = district ? telemetry.filter(item => item.district.toLowerCase() === district.toLowerCase()) : telemetry;
  return res.json({ success: true, sandbox: true, readings, recommendation: readings.length ? 'Moisture is within the monitored range. Review nitrogen before the next top dressing.' : 'No sensor readings found.' });
}

function getExportMatches(req, res) {
  const cropType = req.query.cropType;
  const filtered = cropType ? matches.filter(item => item.cropType.toLowerCase().includes(cropType.toLowerCase())) : matches;
  return res.json({ success: true, sandbox: true, matches: filtered });
}

function createExportInquiry(req, res) {
  const match = matches.find(item => item.id === req.body.matchId);
  if (!match) return res.status(404).json({ success: false, message: 'Export match not found.' });
  return res.status(201).json({ success: true, sandbox: true, inquiry: { id: `inq_${uuidv4().slice(0, 8)}`, matchId: match.id, farmerId: req.user.id, status: 'PENDING_REVIEW', createdAt: new Date().toISOString() } });
}

module.exports = { getInputShop, applyBnpl, getSensors, getExportMatches, createExportInquiry };
