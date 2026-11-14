const { v4: uuidv4 } = require("uuid");

class PaymentProvider {
  async createPayment() {
    throw new Error("PaymentProvider.createPayment must be implemented.");
  }

  async release() {
    throw new Error("PaymentProvider.release must be implemented.");
  }

  async refund() {
    throw new Error("PaymentProvider.refund must be implemented.");
  }
}

class MockProvider extends PaymentProvider {
  constructor(name = "mock") {
    super();
    this.name = name;
    this.payments = new Map();
  }

  async createPayment({ amount, payerMfsNumber, idempotencyKey }) {
    if (this.payments.has(idempotencyKey))
      return this.payments.get(idempotencyKey);
    const result = {
      provider: this.name,
      providerRef: `SANDBOX_${this.name.toUpperCase()}_${uuidv4().slice(0, 12)}`,
      idempotencyKey,
      amount,
      payerMfsNumber,
      status: "SUCCESS",
      sandbox: true,
    };
    this.payments.set(idempotencyKey, result);
    return result;
  }

  async release({ providerRef }) {
    return {
      provider: this.name,
      providerRef,
      status: "RELEASED",
      sandbox: true,
    };
  }

  async refund({ providerRef }) {
    return {
      provider: this.name,
      providerRef,
      status: "REFUNDED",
      sandbox: true,
    };
  }

  async fund(params) {
    return this.createPayment(params);
  }
}

function getPaymentProvider(paymentRail) {
  const selected = (process.env.PAYMENT_PROVIDER || "mock").toLowerCase();
  if (selected === "mock") return new MockProvider(paymentRail || "mock");
  if (selected === "bkash")
    return require("./providers/bkashProvider").createBkashProvider();
  if (selected === "aamarpay")
    return require("./providers/aamarPayProvider").createAamarPayProvider();
  const error = new Error(`Unsupported PAYMENT_PROVIDER: ${selected}.`);
  error.statusCode = 400;
  throw error;
}

module.exports = { PaymentProvider, MockProvider, getPaymentProvider };
