require('dotenv').config();

function readEnum(name, allowed, fallback) {
  const value = process.env[name] || fallback;
  if (!allowed.includes(value)) {
    throw new Error(`${name} must be one of: ${allowed.join(', ')}`);
  }
  return value;
}

module.exports = {
  OTP_MODE: readEnum('OTP_MODE', ['dev', 'live'], 'dev'),
  PAYMENT_PROVIDER: readEnum('PAYMENT_PROVIDER', ['mock', 'sandbox', 'live'], 'mock'),
  MAP_PROVIDER: readEnum('MAP_PROVIDER', ['osm', 'google'], 'osm')
};
