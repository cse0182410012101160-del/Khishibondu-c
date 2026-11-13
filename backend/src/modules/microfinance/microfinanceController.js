const { v4: uuidv4 } = require('uuid');
const db = require('../../database/store');
const { calculateCreditScore, calculateEmiSchedule } = require('./creditEngine');

// Get Farmer Credit Profile
function getFarmerCreditProfile(req, res) {
  const { farmerId } = req.params;
  const targetId = farmerId || req.user.id;

  const farmer = db.users.find(u => u.id === targetId);
  if (!farmer) {
    return res.status(404).json({ success: false, message: 'Farmer not found.' });
  }

  const creditProfile = calculateCreditScore(farmer, db.orders, db.disputes);

  // Available partner schemes
  const mfiPartners = [
    {
      ngoId: 'usr_ngo_1',
      name: 'BRAC Microfinance',
      program: 'BRAC Krishi Shurokkha (কৃষি সুরক্ষা ঋণ)',
      baseRateAnnual: 9.0,
      minTenureMonths: 3,
      maxTenureMonths: 12,
      collateralRequired: 'None (Marketplace Lien Only)',
      features: ['No physical land deed', 'Direct bKash disbursement', 'Flexible seasonal bullet repayment']
    },
    {
      ngoId: 'usr_ngo_2',
      name: 'Grameen Krishi Rin',
      program: 'Grameen Seasonal Harvest Credit (গ্রামীন মওসুমী ঋণ)',
      baseRateAnnual: 8.5,
      minTenureMonths: 4,
      maxTenureMonths: 9,
      collateralRequired: 'None (Agro-Bridge Escrow Lien)',
      features: ['Post-harvest lump sum repayment', 'Free crop insurance cover up to 50k BDT']
    }
  ];

  return res.json({
    success: true,
    farmer: {
      id: farmer.id,
      name: farmer.name,
      phone: farmer.phone,
      division: farmer.division,
      district: farmer.district,
      upazila: farmer.upazila,
      mfsProvider: farmer.mfsProvider,
      mfsNumber: farmer.mfsNumber
    },
    creditProfile,
    partnerSchemes: mfiPartners
  });
}

// Simulate EMI and repayment
function simulateEmi(req, res) {
  const { principal, annualRatePct, tenureMonths } = req.body;

  if (!principal || !tenureMonths) {
    return res.status(400).json({ success: false, message: 'Principal and tenureMonths are required.' });
  }

  const rate = parseFloat(annualRatePct || 9.0);
  const result = calculateEmiSchedule(principal, rate, tenureMonths);

  return res.json({
    success: true,
    simulation: result
  });
}

// Farmer applies for loan
function applyForLoan(req, res) {
  const { ngoId, requestedAmount, tenureMonths, purpose, programName } = req.body;

  if (!requestedAmount || !tenureMonths || !ngoId) {
    return res.status(400).json({
      success: false,
      message: 'ngoId, requestedAmount, and tenureMonths are required.'
    });
  }

  const farmer = req.user;
  const ngo = db.users.find(u => u.id === ngoId);
  const creditSnapshot = calculateCreditScore(farmer, db.orders, db.disputes);

  const interestRate = ngoId === 'usr_ngo_2' ? 8.5 : 9.0;
  const emiCalc = calculateEmiSchedule(requestedAmount, interestRate, tenureMonths);

  const loanApplication = {
    id: `loan_app_${uuidv4().substring(0, 8)}`,
    farmerId: farmer.id,
    farmerName: farmer.name,
    ngoId,
    ngoName: ngo ? ngo.organizationName || ngo.name : 'MFI Partner',
    programName: programName || 'Agro-Bridge Cashflow Loan',
    requestedAmount: parseFloat(requestedAmount),
    tenureMonths: parseInt(tenureMonths, 10),
    interestRateAnnual: interestRate,
    monthlyEmiBdt: emiCalc.monthlyEmi,
    purpose: purpose || 'Seed and fertilizer purchase for upcoming harvest.',
    farmerCreditScoreSnapshot: creditSnapshot.score,
    farmerRatingSnapshot: farmer.rating || 5.0,
    historicalSalesVolumeBdt: creditSnapshot.totalSalesBdt,
    collateralType: 'Marketplace Cashflow Lien (Zero Physical Collateral)',
    status: 'SUBMITTED', // SUBMITTED, UNDER_REVIEW, APPROVED, DISBURSED, REJECTED
    approvedAmount: null,
    disbursedViaMfs: null,
    disbursedTxnId: null,
    submittedAt: new Date().toISOString(),
    approvedAt: null
  };

  db.loanApplications.unshift(loanApplication);

  return res.status(201).json({
    success: true,
    message: 'Microfinance loan application submitted for review.',
    application: loanApplication
  });
}

// Get loan applications (Farmer views own, NGO views their assigned queue, Admin views all)
function getLoanApplications(req, res) {
  const user = req.user;
  let results = [...db.loanApplications];

  if (user.role === 'farmer') {
    results = results.filter(a => a.farmerId === user.id);
  } else if (user.role === 'ngo') {
    results = results.filter(a => a.ngoId === user.id);
  }

  const { status } = req.query;
  if (status) {
    results = results.filter(a => a.status.toLowerCase() === status.toLowerCase());
  }

  return res.json({
    success: true,
    count: results.length,
    applications: results
  });
}

// NGO partner updates loan status (Approve, Disburse via MFS, or Reject)
function updateLoanStatus(req, res) {
  const { id } = req.params;
  const { status, approvedAmount, rejectionReason, mfsProvider } = req.body;

  const app = db.loanApplications.find(a => a.id === id);
  if (!app) {
    return res.status(404).json({ success: false, message: 'Loan application not found.' });
  }

  if (req.user.role !== 'ngo' && req.user.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Only authorized NGO loan officers can modify loan status.' });
  }

  app.status = status;

  if (status === 'APPROVED') {
    app.approvedAmount = parseFloat(approvedAmount || app.requestedAmount);
    app.approvedAt = new Date().toISOString();
  } else if (status === 'DISBURSED') {
    app.approvedAmount = parseFloat(approvedAmount || app.approvedAmount || app.requestedAmount);
    app.disbursedViaMfs = mfsProvider || 'bKash';
    app.disbursedTxnId = `MFS_DISB_${(mfsProvider || 'BKASH').toUpperCase()}_${Math.floor(100000 + Math.random() * 900000)}`;
    app.disbursedAt = new Date().toISOString();
  } else if (status === 'REJECTED') {
    app.rejectionReason = rejectionReason || 'Credit profile does not meet seasonal sales threshold.';
  }

  return res.json({
    success: true,
    message: `Loan application updated to ${status}.`,
    application: app
  });
}

module.exports = {
  getFarmerCreditProfile,
  simulateEmi,
  applyForLoan,
  getLoanApplications,
  updateLoanStatus
};

