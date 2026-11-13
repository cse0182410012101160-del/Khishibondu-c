class SmsProvider {
  async sendOtp() {
    throw new Error('not configured');
  }
}

module.exports = new SmsProvider();
