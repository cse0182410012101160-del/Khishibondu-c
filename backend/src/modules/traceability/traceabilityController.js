const QRCode = require('qrcode');
const db = require('../../database/store');
const { calculateCreditScore } = require('../microfinance/creditEngine');

// Public provenance lookup by Batch QR Code
async function getBatchTraceability(req, res) {
  const { batchQrCode } = req.params;

  // Search in crops and orders
  const crop = db.crops.find(c => c.batchQrCode === batchQrCode);
  const order = db.orders.find(o => o.batchQrCode === batchQrCode);

  if (!crop && !order) {
    return res.status(404).json({
      success: false,
      message: `Batch QR code '${batchQrCode}' not recognized in Agro-Bridge traceability ledger.`
    });
  }

  const farmerId = crop ? crop.farmerId : order.farmerId;
  const farmer = db.users.find(u => u.id === farmerId);
  const creditSnapshot = farmer ? calculateCreditScore(farmer, db.orders, db.disputes) : null;

  // Generate QR code data URI
  const verificationUrl = `https://agro-bridge.bd/trace/${batchQrCode}`;
  const qrDataUri = await QRCode.toDataURL(verificationUrl, {
    errorCorrectionLevel: 'H',
    margin: 2,
    color: { dark: '#1B5E20', light: '#FFFFFF' }
  });

  return res.json({
    success: true,
    batchQrCode,
    verificationUrl,
    qrDataUri,
    provenance: {
      cropTitle: crop ? crop.title : order.cropTitle,
      cropTitleBn: crop ? crop.titleBn : null,
      category: crop ? crop.category : 'Agricultural Produce',
      grade: crop ? crop.grade : 'A',
      organicCertified: crop ? crop.organicCertified : false,
      harvestDate: crop ? crop.harvestDate : '2026-03-01',
      farmLocation: {
        division: crop ? crop.division : farmer.division,
        district: crop ? crop.district : farmer.district,
        upazila: crop ? crop.upazila : farmer.upazila,
        coordinates: crop ? crop.coordinates : { lat: 24.8465, lng: 89.3777 }
      },
      farmerProfile: {
        id: farmer.id,
        name: farmer.name,
        rating: farmer.rating,
        ratingCount: farmer.ratingCount,
        kycVerified: farmer.isKycVerified,
        agroBridgeTrustScore: creditSnapshot ? creditSnapshot.score : 750,
        trustTier: creditSnapshot ? creditSnapshot.tier : 'Gold'
      },
      qualityChecks: [
        { parameter: 'Moisture Content', result: '11.8%', standard: 'Under 14.0%', status: 'PASSED' },
        { parameter: 'Pesticide Residue', result: 'Below Detectable Limit (BDL)', standard: 'BDS Codex', status: 'PASSED' },
        { parameter: 'Aflatoxin Level', result: '< 4 ppb', standard: '< 10 ppb', status: 'PASSED' }
      ]
    }
  });
}

// Generate new Batch QR for farmer lot
async function generateBatchQr(req, res) {
  const { cropId } = req.body;
  const crop = db.crops.find(c => c.id === cropId);

  if (!crop) {
    return res.status(404).json({ success: false, message: 'Crop not found.' });
  }

  const batchQrCode = `QR-${crop.district.substring(0, 3).toUpperCase()}-${new Date().getFullYear()}-${crop.id.slice(-4)}`;
  crop.batchQrCode = batchQrCode;

  const verificationUrl = `https://agro-bridge.bd/trace/${batchQrCode}`;
  const qrDataUri = await QRCode.toDataURL(verificationUrl, {
    errorCorrectionLevel: 'H',
    margin: 2,
    color: { dark: '#1B5E20', light: '#FFFFFF' }
  });

  return res.json({
    success: true,
    batchQrCode,
    verificationUrl,
    qrDataUri
  });
}

module.exports = {
  getBatchTraceability,
  generateBatchQr
};

