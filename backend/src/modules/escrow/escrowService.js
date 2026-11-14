const STATES = Object.freeze({
  CREATED: "CREATED",
  FUNDED: "FUNDED",
  IN_TRANSIT: "IN_TRANSIT",
  DELIVERED: "DELIVERED",
  RELEASED: "RELEASED",
  DISPUTED: "DISPUTED",
  REFUNDED: "REFUNDED",
});

const TRANSITIONS = Object.freeze({
  CREATED: [STATES.FUNDED],
  FUNDED: [STATES.IN_TRANSIT, STATES.DISPUTED, STATES.REFUNDED],
  IN_TRANSIT: [STATES.DELIVERED, STATES.DISPUTED],
  DELIVERED: [STATES.RELEASED, STATES.DISPUTED],
  DISPUTED: [STATES.RELEASED, STATES.REFUNDED],
  RELEASED: [],
  REFUNDED: [],
});

function invalidTransition(current, next) {
  const error = new Error(
    `Invalid escrow transition from ${current} to ${next}.`,
  );
  error.statusCode = 409;
  return error;
}

async function writeLedger(tx, escrow, status, providerRef) {
  await tx.ledgerEntry.create({
    data: {
      orderId: escrow.orderId,
      escrowId: escrow.id,
      type: "STATE_CHANGE",
      amount: escrow.amount,
      status,
      providerRef: providerRef || escrow.providerRef || null,
    },
  });
}

async function createEscrow({
  db,
  orderId,
  amount,
  paymentRail = "mock",
  provider,
  idempotencyKey,
}) {
  const payment = await provider.createPayment({
    amount,
    idempotencyKey: idempotencyKey || `escrow-${orderId}`,
  });
  return db.$transaction(async (tx) => {
    const escrow = await tx.escrow.create({
      data: {
        orderId,
        amount,
        paymentRail,
        providerRef: payment.providerRef,
        idempotencyKey: payment.idempotencyKey,
        status: STATES.CREATED,
      },
    });
    await writeLedger(tx, escrow, STATES.CREATED, payment.providerRef);
    return escrow;
  });
}

async function transitionEscrow({ db, escrowId, nextState, provider }) {
  const current = await db.escrow.findUnique({ where: { id: escrowId } });
  if (!current) {
    const error = new Error("Escrow not found.");
    error.statusCode = 404;
    throw error;
  }
  if (current.status === nextState) return { ...current, duplicate: true };
  if (!(TRANSITIONS[current.status] || []).includes(nextState)) {
    throw invalidTransition(current.status, nextState);
  }

  let providerResult;
  if (nextState === STATES.RELEASED)
    providerResult = await provider.release({
      providerRef: current.providerRef,
    });
  if (nextState === STATES.REFUNDED)
    providerResult = await provider.refund({
      providerRef: current.providerRef,
    });
  if (nextState === STATES.FUNDED)
    providerResult = await provider.createPayment({
      amount: current.amount,
      idempotencyKey: current.idempotencyKey,
    });

  return db.$transaction(async (tx) => {
    const escrow = await tx.escrow.update({
      where: { id: escrowId },
      data: {
        status: nextState,
        providerRef:
          providerResult && providerResult.providerRef
            ? providerResult.providerRef
            : current.providerRef,
        releasedAt: nextState === STATES.RELEASED ? new Date() : undefined,
      },
    });
    await writeLedger(
      tx,
      escrow,
      nextState,
      providerResult && providerResult.providerRef,
    );
    return escrow;
  });
}

module.exports = { STATES, TRANSITIONS, createEscrow, transitionEscrow };
