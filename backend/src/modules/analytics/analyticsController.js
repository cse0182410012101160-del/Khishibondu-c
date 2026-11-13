const db = require('../../database/store');
const { calculateCreditScore } = require('../microfinance/creditEngine');

// Farmer Financial and Operational Analytics
function getFarmerAnalytics(req, res) {
  const { farmerId } = req.params;
  const targetId = farmerId || req.user.id;

  const farmer = db.users.find(u => u.id === targetId);
  if (!farmer) {
    return res.status(404).json({ success: false, message: 'Farmer not found.' });
  }

  const farmerOrders = db.orders.filter(o => o.farmerId === targetId);
  const totalRevenue = farmerOrders
    .filter(o => o.status === 'Paid')
    .reduce((sum, o) => sum + (o.totalAmount || 0), 0);

  const pendingEscrow = farmerOrders
    .filter(o => o.escrowStatus === 'LOCKED')
    .reduce((sum, o) => sum + (o.totalAmount || 0), 0);

  const crops = db.crops.filter(c => c.farmerId === targetId);
  const creditProfile = calculateCreditScore(farmer, db.orders, db.disputes);

  // Best selling crop breakdown
  const salesByCrop = {};
  farmerOrders.forEach(o => {
    salesByCrop[o.cropTitle] = (salesByCrop[o.cropTitle] || 0) + o.totalAmount;
  });

  const topCrops = Object.keys(salesByCrop).map(title => ({
    title,
    revenue: salesByCrop[title]
  })).sort((a, b) => b.revenue - a.revenue);

  // Monthly revenue trend (Past 4 months simulated)
  const monthlyRevenue = [
    { month: 'Dec 2025', revenue: Math.round(totalRevenue * 0.15) },
    { month: 'Jan 2026', revenue: Math.round(totalRevenue * 0.25) },
    { month: 'Feb 2026', revenue: Math.round(totalRevenue * 0.35) },
    { month: 'Mar 2026', revenue: Math.round(totalRevenue * 0.25) }
  ];

  return res.json({
    success: true,
    analytics: {
      farmerId: farmer.id,
      farmerName: farmer.name,
      totalRevenueBdt: totalRevenue,
      pendingEscrowBdt: pendingEscrow,
      activeListingsCount: crops.length,
      completedOrdersCount: farmerOrders.filter(o => o.status === 'Paid').length,
      creditScore: creditProfile.score,
      creditTier: creditProfile.tier,
      fulfillmentRatePct: creditProfile.fulfillmentRatePct,
      topCrops,
      monthlyRevenue
    }
  });
}

// Admin Moderation Platform Analytics
function getAdminAnalytics(req, res) {
  const totalUsers = db.users.length;
  const farmersCount = db.users.filter(u => u.role === 'farmer').length;
  const buyersCount = db.users.filter(u => u.role === 'buyer').length;
  const ngoCount = db.users.filter(u => u.role === 'ngo').length;

  const totalGmvBdt = db.orders.reduce((sum, o) => sum + (o.totalAmount || 0), 0);
  const totalEscrowLockedBdt = db.escrowTransactions
    .filter(e => e.status === 'LOCKED')
    .reduce((sum, e) => sum + (e.amount || 0), 0);

  const activeDisputesCount = db.disputes.filter(d => d.status === 'PENDING_REVIEW').length;
  const loansDisbursedCount = db.loanApplications.filter(l => l.status === 'DISBURSED').length;
  const totalLoanVolumeDisbursedBdt = db.loanApplications
    .filter(l => l.status === 'DISBURSED')
    .reduce((sum, l) => sum + (l.approvedAmount || 0), 0);

  return res.json({
    success: true,
    analytics: {
      totalUsers,
      farmersCount,
      buyersCount,
      ngoCount,
      totalGmvBdt,
      totalEscrowLockedBdt,
      activeDisputesCount,
      totalDisputesCount: db.disputes.length,
      loansDisbursedCount,
      totalLoanVolumeDisbursedBdt,
      activeListingsCount: db.crops.length,
      totalOrdersCount: db.orders.length
    }
  });
}

// NGO/MFI portfolio analytics over consented demo records.
function getNgoAnalytics(req, res) {
  const farmers = db.users.filter(user => user.role === 'farmer');
  const applications = db.loanApplications;
  const disbursed = applications.filter(application => application.status === 'DISBURSED');
  const districtRisk = {};

  farmers.forEach(farmer => {
    const district = farmer.district || 'Unknown';
    districtRisk[district] ??= { district, applicants: 0, defaults: 0, requestedBdt: 0 };
    const farmerApplications = applications.filter(application => application.farmerId === farmer.id);
    districtRisk[district].applicants += farmerApplications.length;
    districtRisk[district].requestedBdt += farmerApplications.reduce((sum, application) => sum + (application.requestedAmount || 0), 0);
    districtRisk[district].defaults += farmerApplications.filter(application => application.status === 'DEFAULTED').length;
  });

  return res.json({
    success: true,
    analytics: {
      applicants: applications.length,
      scoreDistribution: {
        platinum: farmers.filter(farmer => calculateCreditScore(farmer, db.orders, db.disputes).tier === 'Platinum').length,
        gold: farmers.filter(farmer => calculateCreditScore(farmer, db.orders, db.disputes).tier === 'Gold').length,
        standard: farmers.filter(farmer => !['Platinum', 'Gold'].includes(calculateCreditScore(farmer, db.orders, db.disputes).tier)).length
      },
      emiCollectionRatePct: applications.length === 0 ? 0 : Math.round((disbursed.length / applications.length) * 100),
      defaultRatePct: applications.length === 0 ? 0 : Math.round((applications.filter(application => application.status === 'DEFAULTED').length / applications.length) * 100),
      districtRisk: Object.values(districtRisk)
    }
  });
}

module.exports = {
  getFarmerAnalytics,
  getAdminAnalytics,
  getNgoAnalytics
};

