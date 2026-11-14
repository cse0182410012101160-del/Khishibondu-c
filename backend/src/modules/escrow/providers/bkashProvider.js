const crypto = require("crypto");
const { PaymentProvider } = require("../paymentProvider");

class BkashProvider extends PaymentProvider {
  constructor({
    baseUrl,
    appKey,
    appSecret,
    username,
    password,
    webhookSecret,
  }) {
    super();
    this.baseUrl = baseUrl.replace(/\/$/, "");
    this.appKey = appKey;
    this.appSecret = appSecret;
    this.username = username;
    this.password = password;
    this.webhookSecret = webhookSecret;
    this.token = null;
    this.payments = new Map();
  }

  async request(path, options = {}) {
    const response = await fetch(`${this.baseUrl}${path}`, {
      ...options,
      headers: {
        "content-type": "application/json",
        accept: "application/json",
        ...(options.headers || {}),
      },
    });
    const body = await response.json();
    if (!response.ok)
      throw new Error(
        body.statusMessage || `bKash request failed with ${response.status}.`,
      );
    return body;
  }

  async getToken() {
    if (this.token) return this.token;
    const body = await this.request("/tokenized/checkout/token/grant", {
      method: "POST",
      headers: {
        username: this.username,
        password: this.password,
        "x-app-key": this.appKey,
      },
      body: JSON.stringify({
        app_key: this.appKey,
        app_secret: this.appSecret,
      }),
    });
    this.token = body.id_token;
    return this.token;
  }

  async createPayment({ amount, idempotencyKey }) {
    if (this.payments.has(idempotencyKey))
      return this.payments.get(idempotencyKey);
    const token = await this.getToken();
    const body = await this.request("/tokenized/checkout/create", {
      method: "POST",
      headers: { authorization: token, "x-app-key": this.appKey },
      body: JSON.stringify({
        mode: "0011",
        payerReference: idempotencyKey,
        callbackURL: process.env.BKASH_CALLBACK_URL,
        amount: String(amount),
        currency: "BDT",
        intent: "sale",
        merchantInvoiceNumber: idempotencyKey,
      }),
    });
    const paymentId = body.paymentID || idempotencyKey;
    const result = {
      provider: "bKash",
      providerRef: paymentId,
      idempotencyKey: paymentId,
      status: body.transactionStatus || "INITIATED",
      sandbox: true,
    };
    this.payments.set(idempotencyKey, result);
    this.payments.set(paymentId, result);
    return result;
  }

  async release({ providerRef }) {
    return this.executePayment("/tokenized/checkout/execute", providerRef);
  }

  async refund({ providerRef, amount }) {
    return this.executePayment(
      "/tokenized/checkout/payment/refund",
      providerRef,
      amount,
    );
  }

  async executePayment(path, paymentId, amount) {
    const token = await this.getToken();
    const body = await this.request(path, {
      method: "POST",
      headers: { authorization: token, "x-app-key": this.appKey },
      body: JSON.stringify({
        paymentID: paymentId,
        ...(amount ? { amount: String(amount) } : {}),
      }),
    });
    return {
      provider: "bKash",
      providerRef: paymentId,
      status: body.transactionStatus || "SUCCESS",
      sandbox: true,
    };
  }

  verifyWebhookSignature(rawBody, signature) {
    if (!this.webhookSecret || typeof signature !== "string") return false;
    const expected = crypto
      .createHmac("sha256", this.webhookSecret)
      .update(rawBody)
      .digest("hex");
    const provided = Buffer.from(signature, "utf8");
    const actual = Buffer.from(expected, "utf8");
    return (
      provided.length === actual.length &&
      crypto.timingSafeEqual(provided, actual)
    );
  }
}

function createBkashProvider() {
  const required = [
    "BKASH_BASE_URL",
    "BKASH_APP_KEY",
    "BKASH_APP_SECRET",
    "BKASH_USERNAME",
    "BKASH_PASSWORD",
  ];
  const missing = required.filter((name) => !process.env[name]);
  if (missing.length)
    throw new Error(`Missing bKash configuration: ${missing.join(", ")}.`);
  return new BkashProvider({
    baseUrl: process.env.BKASH_BASE_URL,
    appKey: process.env.BKASH_APP_KEY,
    appSecret: process.env.BKASH_APP_SECRET,
    username: process.env.BKASH_USERNAME,
    password: process.env.BKASH_PASSWORD,
    webhookSecret: process.env.BKASH_WEBHOOK_SECRET,
  });
}

module.exports = { BkashProvider, createBkashProvider };
