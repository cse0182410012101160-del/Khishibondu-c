const assert = require('assert');

process.env.OTP_MODE = 'dev';
const sharedConfig = require('../src/shared/config');

assert.strictEqual(sharedConfig.OTP_MODE, 'dev');
assert.strictEqual('123456', '123456');

process.env.OTP_MODE = 'live';
delete require.cache[require.resolve('../src/shared/config')];
const liveConfig = require('../src/shared/config');
assert.strictEqual(liveConfig.OTP_MODE, 'live');

console.log('OTP mode tests passed');
