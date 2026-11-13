/**
 * Agro-Bridge Automated Credit Scoring Engine (Bangladeshi Rural Financial Modeling)
 * 
 * Replaces physical land deed collateral with verified marketplace transactional cash flow.
 * Credit Score Range: 300 - 850 (Modeled on CIB / FICO standards)
 */

function calculateCreditScore(farmer, orders, disputes) {
  // Baseline floor score
  let score = 350;

  const farmerOrders = orders.filter(o => o.farmerId === farmer.id);
  const fulfilledOrders = farmerOrders.filter(o => o.status === 'Paid' || o.status === 'Delivered');
  const farmerDisputes = disputes.filter(d => d.againstUserId === farmer.id);

  // 1. Sales Volume Factor (Max 180 points)
  // Scaled against typical BDT harvest revenues (50k to 500k+)
  const totalSalesBdt = farmer.totalSalesVolumeBdt || fulfilledOrders.reduce((sum, o) => sum + (o.totalAmount || 0), 0);
  let salesPoints = 0;
  if (totalSalesBdt >= 500000) salesPoints = 180;
  else if (totalSalesBdt >= 300000) salesPoints = 150;
  else if (totalSalesBdt >= 150000) salesPoints = 110;
  else if (totalSalesBdt >= 50000) salesPoints = 70;
  else if (totalSalesBdt > 0) salesPoints = 35;
  score += salesPoints;

  // 2. Order Fulfillment Reliability (Max 120 points)
  const totalOrdersCount = farmerOrders.length;
  let fulfillmentRatio = totalOrdersCount > 0 ? (fulfilledOrders.length / totalOrdersCount) : 1.0;
  const fulfillmentPoints = Math.round(fulfillmentRatio * 120);
  score += fulfillmentPoints;

  // 3. Buyer Rating & Feedback Score (Max 100 points)
  // Rating 1.0 to 5.0
  const rating = farmer.rating || 4.5;
  const ratingPoints = Math.round((rating / 5.0) * 100);
  score += ratingPoints;

  // 4. KYC & Platform Tenure (Max 100 points)
  let kycPoints = farmer.isKycVerified ? 60 : 20;
  // Account age bonus
  const createdDate = new Date(farmer.createdAt || '2024-01-01');
  const monthsActive = Math.max(1, (new Date() - createdDate) / (1000 * 60 * 60 * 24 * 30));
  const tenurePoints = Math.min(40, Math.round(monthsActive * 4));
  score += (kycPoints + tenurePoints);

  // 5. Dispute Penalty
  const lostDisputes = farmerDisputes.filter(d => d.status === 'RESOLVED_BUYER_REFUNDED');
  const disputePenalty = (lostDisputes.length * 40) + (farmerDisputes.length * 15);
  score = Math.max(300, score - disputePenalty);

  // Cap at 850
  score = Math.min(850, score);

  // Tier classification
  let tier = 'Bronze';
  let riskGrade = 'High Risk';
  let interestRateModifier = 1.0;
  let maxLoanMultiplier = 0.5; // multiplier on annual verified sales

  if (score >= 750) {
    tier = 'Platinum';
    riskGrade = 'Low Risk (Prime)';
    interestRateModifier = 0.85; // Discounted concession rate (e.g. 7.5% - 8.5%)
    maxLoanMultiplier = 0.8;
  } else if (score >= 670) {
    tier = 'Gold';
    riskGrade = 'Moderate-Low Risk';
    interestRateModifier = 0.92;
    maxLoanMultiplier = 0.65;
  } else if (score >= 580) {
    tier = 'Silver';
    riskGrade = 'Moderate Risk';
    interestRateModifier = 1.0;
    maxLoanMultiplier = 0.45;
  } else {
    tier = 'Bronze';
    riskGrade = 'High Risk';
    interestRateModifier = 1.15;
    maxLoanMultiplier = 0.25;
  }

  // Pre-approved loan ceiling (BDT)
  const estimatedSales = Math.max(totalSalesBdt, 100000);
  let maxPreApprovedLoan = Math.round(estimatedSales * maxLoanMultiplier);
  // Cap at 500,000 BDT for agricultural microcredit regulation limits
  maxPreApprovedLoan = Math.min(500000, Math.max(25000, maxPreApprovedLoan));

  return {
    score,
    tier,
    riskGrade,
    totalSalesBdt,
    fulfilledOrdersCount: fulfilledOrders.length,
    fulfillmentRatePct: Math.round(fulfillmentRatio * 100),
    buyerRating: rating,
    maxPreApprovedLoanBdt: maxPreApprovedLoan,
    interestRateModifier,
    breakdown: {
      salesVolumePoints: salesPoints,
      fulfillmentPoints,
      ratingPoints,
      tenureAndKycPoints: kycPoints + tenurePoints,
      disputeDeduction: disputePenalty
    }
  };
}

/**
 * Standard Amortization Formula for Loan EMI
 * EMI = [P x R x (1+R)^N] / [(1+R)^N - 1]
 * @param {number} principal (BDT)
 * @param {number} annualRatePct (e.g. 9.0)
 * @param {number} tenureMonths (e.g. 6)
 */
function calculateEmiSchedule(principal, annualRatePct, tenureMonths) {
  const p = parseFloat(principal);
  const r = (parseFloat(annualRatePct) / 100) / 12; // monthly interest rate
  const n = parseInt(tenureMonths, 10);

  if (r === 0) {
    const emi = p / n;
    return { monthlyEmi: Math.round(emi), totalInterest: 0, totalPayable: p, schedule: [] };
  }

  const emi = (p * r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1);
  const totalPayable = emi * n;
  const totalInterest = totalPayable - p;

  let balance = p;
  const schedule = [];

  for (let month = 1; month <= n; month++) {
    const interestComponent = balance * r;
    const principalComponent = emi - interestComponent;
    balance -= principalComponent;

    schedule.push({
      month,
      emi: Math.round(emi),
      principal: Math.round(principalComponent),
      interest: Math.round(interestComponent),
      remainingBalance: Math.max(0, Math.round(balance))
    });
  }

  return {
    principal: p,
    annualRatePct,
    tenureMonths: n,
    monthlyEmi: Math.round(emi),
    totalInterest: Math.round(totalInterest),
    totalPayable: Math.round(totalPayable),
    schedule
  };
}

module.exports = {
  calculateCreditScore,
  calculateEmiSchedule
};

