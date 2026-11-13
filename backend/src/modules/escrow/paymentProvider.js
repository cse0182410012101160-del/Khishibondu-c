const { v4: uuidv4 } = require('uuid');

class MockPaymentProvider {
  constructor(name) {
    this.name = name;
  }

  async fund({ amount, payerMfsNumber, idempotencyKey }) {
    return {
      provider: this.name,
      providerRef: `SANDBOX_${this.name.toUpperCase()}_${uuidv4().slice(0, 12)}`,
      idempotencyKey,
      amount,
      payerMfsNumber,
      status: 'SUCCESS',
      sandbox: true
    };
  }
}

const providers = {
  bKash: new MockPaymentProvider('bKash'),
  Nagad: new MockPaymentProvider('Nagad')
};

function getPaymentProvider(paymentRail) {
  const provider = providers[paymentRail];
  if (!provider) {
    const supported = Object.keys(providers).join(', ');
    const error = new Error(`Unsupported payment rail. Use: ${supported}.`);
    error.statusCode = 400;
    throw error;
  }
  return provider;
}

module.exports = { getPaymentProvider };
