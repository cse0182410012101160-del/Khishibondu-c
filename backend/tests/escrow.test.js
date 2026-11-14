const { MockProvider } = require("../src/modules/escrow/paymentProvider");
const {
  STATES,
  createEscrow,
  transitionEscrow,
} = require("../src/modules/escrow/escrowService");

function createDb() {
  const state = { escrows: [], ledger: [] };
  const db = {
    state,
    $transaction: async (callback) => callback(db),
    escrow: {
      findUnique: async ({ where }) =>
        state.escrows.find((item) => item.id === where.id) || null,
      create: async ({ data }) => {
        const escrow = { id: `escrow-${state.escrows.length + 1}`, ...data };
        state.escrows.push(escrow);
        return escrow;
      },
      update: async ({ where, data }) => {
        const escrow = state.escrows.find((item) => item.id === where.id);
        Object.assign(escrow, data);
        return escrow;
      },
    },
    ledgerEntry: {
      create: async ({ data }) => {
        state.ledger.push({ id: `ledger-${state.ledger.length + 1}`, ...data });
        return state.ledger[state.ledger.length - 1];
      },
    },
  };
  return db;
}

describe("escrow state machine", () => {
  test("records a valid flow with one ledger row per state change", async () => {
    const db = createDb();
    const provider = new MockProvider();
    const escrow = await createEscrow({
      db,
      orderId: "order-1",
      amount: 1000,
      provider,
    });

    await transitionEscrow({
      db,
      escrowId: escrow.id,
      nextState: STATES.FUNDED,
      provider,
    });
    await transitionEscrow({
      db,
      escrowId: escrow.id,
      nextState: STATES.IN_TRANSIT,
      provider,
    });
    await transitionEscrow({
      db,
      escrowId: escrow.id,
      nextState: STATES.DELIVERED,
      provider,
    });
    await transitionEscrow({
      db,
      escrowId: escrow.id,
      nextState: STATES.RELEASED,
      provider,
    });

    expect(db.state.escrows[0].status).toBe(STATES.RELEASED);
    expect(db.state.ledger.map((row) => row.status)).toEqual([
      STATES.CREATED,
      STATES.FUNDED,
      STATES.IN_TRANSIT,
      STATES.DELIVERED,
      STATES.RELEASED,
    ]);
  });

  test("rejects invalid transitions", async () => {
    const db = createDb();
    const provider = new MockProvider();
    const escrow = await createEscrow({
      db,
      orderId: "order-2",
      amount: 1000,
      provider,
    });

    await expect(
      transitionEscrow({
        db,
        escrowId: escrow.id,
        nextState: STATES.DELIVERED,
        provider,
      }),
    ).rejects.toMatchObject({ statusCode: 409 });
    expect(db.state.ledger).toHaveLength(1);
  });

  test("treats a duplicate transition as idempotent", async () => {
    const db = createDb();
    const provider = new MockProvider();
    const escrow = await createEscrow({
      db,
      orderId: "order-3",
      amount: 1000,
      provider,
    });

    await transitionEscrow({
      db,
      escrowId: escrow.id,
      nextState: STATES.FUNDED,
      provider,
    });
    const duplicate = await transitionEscrow({
      db,
      escrowId: escrow.id,
      nextState: STATES.FUNDED,
      provider,
    });

    expect(duplicate.duplicate).toBe(true);
    expect(db.state.ledger).toHaveLength(2);
  });
});
