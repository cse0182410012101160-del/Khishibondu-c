const SCORE_WEIGHTS = Object.freeze({
  completedOrders: 160,
  onTimeDeliveries: 120,
  disputeFree: 120,
  repayments: 120,
  accountAge: 90,
});

function monthsBetween(start, end) {
  return Math.max(
    0,
    (end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24 * 30),
  );
}

function tierFor(score) {
  if (score >= 750) return "Platinum";
  if (score >= 670) return "Gold";
  if (score >= 580) return "Silver";
  return "Bronze";
}

async function computeScore(farmerId, repository, now = new Date()) {
  const farmer = await repository.getFarmer(farmerId);
  if (!farmer) {
    const error = new Error("Farmer not found.");
    error.statusCode = 404;
    throw error;
  }

  const [orders, disputes, repayments] = await Promise.all([
    repository.getCompletedOrders(farmerId),
    repository.getDisputes(farmerId),
    repository.getRepayments(farmerId),
  ]);
  const onTimeRate = orders.length
    ? orders.filter((order) => order.onTime !== false).length / orders.length
    : 0;
  const repaymentRate = repayments.length
    ? repayments.filter((item) =>
        ["PAID", "REPAID", "COMPLETED"].includes(item.status),
      ).length / repayments.length
    : 0;
  const agePoints = Math.min(
    SCORE_WEIGHTS.accountAge,
    Math.floor(
      (monthsBetween(new Date(farmer.createdAt), now) / 12) *
        SCORE_WEIGHTS.accountAge,
    ),
  );
  const factorValues = {
    completedOrders: Math.min(
      SCORE_WEIGHTS.completedOrders,
      orders.length * 20,
    ),
    onTimeDeliveries: Math.round(onTimeRate * SCORE_WEIGHTS.onTimeDeliveries),
    disputeFree: disputes.length === 0 ? SCORE_WEIGHTS.disputeFree : 0,
    repayments: Math.round(repaymentRate * SCORE_WEIGHTS.repayments),
    accountAge: agePoints,
  };
  const factors = Object.entries(factorValues).map(([name, points]) => ({
    name,
    points,
    weight: SCORE_WEIGHTS[name],
  }));
  const score = Math.max(
    300,
    Math.min(
      850,
      300 + factors.reduce((total, factor) => total + factor.points, 0),
    ),
  );
  const result = { score, tier: tierFor(score), factors };

  await repository.storeCreditEvent({
    farmerId,
    score,
    tier: result.tier,
    factors,
  });
  return result;
}

function createPrismaCreditRepository(prisma) {
  return {
    getFarmer: (farmerId) =>
      prisma.user.findUnique({ where: { id: farmerId } }),
    getCompletedOrders: (farmerId) =>
      prisma.order.findMany({
        where: { farmerId, status: { in: ["Delivered", "Paid"] } },
      }),
    getDisputes: (farmerId) =>
      prisma.dispute.findMany({ where: { raisedBy: farmerId } }),
    getRepayments: (farmerId) => prisma.loan.findMany({ where: { farmerId } }),
    storeCreditEvent: (event) => prisma.creditEvent.create({ data: event }),
  };
}

module.exports = { SCORE_WEIGHTS, computeScore, createPrismaCreditRepository };
