const { splitPayout } = require("../src/modules/groupLots/groupLotService");
const { createFarmerForAgent } = require("../src/modules/agents/agentService");
const {
  assertCanRaiseDispute,
} = require("../src/modules/orders/disputeService");

describe("agent and group operations", () => {
  test("rejects an agent farmer profile without consent", () => {
    expect(() =>
      createFarmerForAgent(
        {
          name: "Demo Farmer",
          phone: "+880000000001",
          district: "Bogura",
          consent: false,
        },
        "agent-1",
      ),
    ).toThrow("consent");
  });

  test("splits a payout into integer paisa with no lost remainder", () => {
    const payout = splitPayout(100.01, [
      { memberId: "farmer-1", kg: 1 },
      { memberId: "farmer-2", kg: 2 },
    ]);

    expect(payout).toEqual([
      { memberId: "farmer-1", amountPaisa: 3334, amount: 33.34 },
      { memberId: "farmer-2", amountPaisa: 6667, amount: 66.67 },
    ]);
    expect(payout.reduce((sum, item) => sum + item.amountPaisa, 0)).toBe(10001);
  });
});

describe("order disputes", () => {
  test("rejects the wrong role", () => {
    expect(() =>
      assertCanRaiseDispute({
        user: { id: "ngo-1", role: "ngo" },
        order: {
          status: "DELIVERED",
          buyerId: "buyer-1",
          farmerId: "farmer-1",
        },
      }),
    ).toThrow(/role/i);
  });

  test("rejects a dispute outside transit or delivered states", () => {
    expect(() =>
      assertCanRaiseDispute({
        user: { id: "buyer-1", role: "buyer" },
        order: { status: "PAID", buyerId: "buyer-1", farmerId: "farmer-1" },
      }),
    ).toThrow(/state/i);
  });
});
