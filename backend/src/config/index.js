require('dotenv').config();

module.exports = {
  port: Number.parseInt(process.env.PORT || '5000', 10),
  databaseUrl: process.env.DATABASE_URL,
  jwtSecret: process.env.JWT_SECRET || 'agro_bridge_super_secure_secret_key_2026',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  apiPrefix: '/api/v1',
  otpExpiryMinutes: 5,
  defaultMockOtp: '123456',
  supportedDivisions: [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh'
  ],
  mfsProviders: ['bKash', 'Nagad', 'Rocket']
};
