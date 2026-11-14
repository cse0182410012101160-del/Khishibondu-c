const {
  computeScore,
  SCORE_WEIGHTS,
} = require("../src/modules/credit/creditService");

function repositoryFor(farmer, orders, disputes, repayments) {
  const events = [];
  return {
    events,
    getFarmer: async (farmerId) => (farmerId === farmer.id ? farmer : null),
    getCompletedOrders: async (farmerId) =>
      orders.filter(
        (order) =>
          order.farmerId === farmerId &&
          ["Delivered", "Paid"].includes(order.status),
      ),
    getDisputes: async (farmerId) =>
      disputes.filter((dispute) => dispute.farmerId === farmerId),
    getRepayments: async (farmerId) =>
      repayments.filter((repayment) => repayment.farmerId === farmerId),
    storeCreditEvent: async (event) => events.push(event),
  };
}

describe("credit scoring", () => {
  test.each([
    {
      name: "high activity farmer",
      farmer: { id: "high", createdAt: "2022-01-01" },
      orders: Array.from({ length: 8 }, () => ({
        farmerId: "high",
        status: "Paid",
        onTime: true,
      })),
      disputes: [],
      repayments: Array.from({ length: 4 }, () => ({
        farmerId: "high",
        status: "REPAID",
      })),
      tier: "Platinum",
    },
    {
      name: "developing farmer",
      farmer: { id: "medium", createdAt: "2025-01-01" },
      orders: [
        { farmerId: "medium", status: "Paid", onTime: true },
        { farmerId: "medium", status: "Delivered", onTime: false },
        { farmerId: "medium", status: "Paid", onTime: true },
      ],
      disputes: [{ farmerId: "medium" }],
      repayments: [{ farmerId: "medium", status: "REPAID" }],
      tier: "Silver",
    },
    {
      name: "new farmer",
      farmer: { id: "low", createdAt: "2026-10-01" },
      orders: [],
      disputes: [{ farmerId: "low" }, { farmerId: "low" }],
      repayments: [],
      tier: "Bronze",
    },
  ])("$name stores a bounded score with factors", async (sample) => {
    const repository = repositoryFor(
      sample.farmer,
      sample.orders,
      sample.disputes,
      sample.repayments,
    );
    const result = await computeScore(
      sample.farmer.id,
      repository,
      new Date("2026-11-13"),
    );

    expect(result.score).toBeGreaterThanOrEqual(300);
    expect(result.score).toBeLessThanOrEqual(850);
    expect(result.tier).toBe(sample.tier);
    expect(result.factors).toHaveLength(Object.keys(SCORE_WEIGHTS).length);
    expect(repository.events).toHaveLength(1);
  });
});
