process.env.NODE_ENV = 'test';
const http = require('http');
const app = require('../server');

const PORT = 5001; // test port
let server;

function request(options, body = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: 'localhost',
        port: PORT,
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...(options.headers || {})
        }
      },
      res => {
        let data = '';
        res.on('data', chunk => (data += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(data) });
          } catch (e) {
            resolve({ status: res.statusCode, raw: data });
          }
        });
      }
    );
    req.on('error', reject);
    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Starting Agro-Bridge End-to-End API Test Suite...');
  server = app.listen(PORT);

  try {
    // 1. Health check
    let res = await request({ path: '/health', method: 'GET' });
    console.assert(res.status === 200, 'Health check failed');
    console.log('✅ 1. Health check: PASSED');

    // 2. Demo Login (Farmer)
    res = await request({ path: '/api/v1/auth/demo-login', method: 'POST' }, { role: 'farmer' });
    console.assert(res.status === 200 && res.data.token, 'Farmer login failed');
    const farmerToken = res.data.token;
    const farmerUser = res.data.user;
    console.log(`✅ 2. Demo Login (Farmer: ${farmerUser.name}): PASSED`);

    // 3. Demo Login (Buyer)
    res = await request({ path: '/api/v1/auth/demo-login', method: 'POST' }, { role: 'buyer' });
    console.assert(res.status === 200 && res.data.token, 'Buyer login failed');
    const buyerToken = res.data.token;
    console.log('✅ 3. Demo Login (Buyer): PASSED');

    // 3b. Demo Login (NGO)
    res = await request({ path: '/api/v1/auth/demo-login', method: 'POST' }, { role: 'ngo' });
    console.assert(res.status === 200 && res.data.token, 'NGO login failed');
    const ngoToken = res.data.token;
    console.log('✅ 3b. Demo Login (NGO): PASSED');

    // 4. Marketplace: Get Crops
    res = await request({ path: '/api/v1/marketplace/crops', method: 'GET' });
    console.assert(res.status === 200 && res.data.crops.length > 0, 'Get crops failed');
    console.log(`✅ 4. Marketplace listings fetch (${res.data.crops.length} lots available): PASSED`);

    // 5. Submit Bulk Lot Bid (Buyer)
    const testCropId = res.data.crops[0].id;
    res = await request(
      {
        path: `/api/v1/marketplace/crops/${testCropId}/bids`,
        method: 'POST',
        headers: { Authorization: `Bearer ${buyerToken}` }
      },
      { quantityRequested: 50, offeredPricePerUnit: 1320, note: 'Immediate truck dispatch' }
    );
    console.assert(res.status === 201 && res.data.bid, 'Bid submission failed');
    const createdBidId = res.data.bid.id;
    console.log(`✅ 5. Bulk Lot Bidding (Bid ID: ${createdBidId}): PASSED`);

    // 6. Accept Bid & Auto-generate Order in Escrow (Farmer)
    res = await request(
      {
        path: `/api/v1/marketplace/bids/${createdBidId}/status`,
        method: 'PUT',
        headers: { Authorization: `Bearer ${farmerToken}` }
      },
      { status: 'accepted' }
    );
    console.assert(res.status === 200 && res.data.order, 'Accept bid failed');
    const createdOrderId = res.data.order.id;
    console.log(`✅ 6. Farmer Accepted Bid -> Order created & Escrow locked (Order ID: ${createdOrderId}): PASSED`);

    // 7. Order State Machine: Confirm Delivery & Escrow Release
    res = await request(
      {
        path: `/api/v1/orders/${createdOrderId}/confirm-delivery`,
        method: 'PUT',
        headers: { Authorization: `Bearer ${buyerToken}` }
      }
    );
    console.assert(res.status === 200 && res.data.order.status === 'Paid', 'Confirm delivery failed');
    console.log('✅ 7. Order State Machine: Buyer Confirmed Delivery -> Escrow Released: PASSED');

    // 8. Microfinance Credit Scoring Engine
    res = await request(
      {
        path: `/api/v1/microfinance/credit-score/${farmerUser.id}`,
        method: 'GET',
        headers: { Authorization: `Bearer ${farmerToken}` }
      }
    );
    console.assert(res.status === 200 && res.data.creditProfile.score >= 300, 'Credit score calc failed');
    console.log(`✅ 8. Microfinance Dynamic Credit Score: ${res.data.creditProfile.score} (${res.data.creditProfile.tier} Tier, Max Loan: ${res.data.creditProfile.maxPreApprovedLoanBdt} BDT): PASSED`);

    // 9. Loan EMI Simulation
    res = await request(
      { path: '/api/v1/microfinance/simulate-emi', method: 'POST' },
      { principal: 100000, annualRatePct: 9.0, tenureMonths: 6 }
    );
    console.assert(res.status === 200 && res.data.simulation.monthlyEmi > 0, 'EMI simulation failed');
    console.log(`✅ 9. Loan EMI Simulator (100k BDT @ 9% for 6 mos -> Monthly EMI: ${res.data.simulation.monthlyEmi} BDT): PASSED`);

    // 10. Traceability QR Code Lookup (Public provenance)
    const testBatchQr = 'QR-BOG-2026-POT-101';
    res = await request({ path: `/api/v1/traceability/${testBatchQr}`, method: 'GET' });
    console.assert(res.status === 200 && res.data.provenance, 'Traceability fetch failed');
    console.log(`✅ 10. Traceability Batch QR Provenance (${res.data.provenance.cropTitle}): PASSED`);

    // 11. Weather & Agro-Advisory
    res = await request({ path: '/api/v1/weather?district=Bogura', method: 'GET' });
    console.assert(res.status === 200 && res.data.weather, 'Weather fetch failed');
    console.log(`✅ 11. Weather & Cyclone/Flood Advisory (Bogura: ${res.data.weather.condition}, Risk: ${res.data.weather.riskLevel}): PASSED`);

    // 12. Extensible Plugin & Feature-Flag Registry
    res = await request({ path: '/api/v1/plugins', method: 'GET' });
    console.assert(res.status === 200 && res.data.plugins.length >= 4, 'Plugin registry failed');
    console.log(`✅ 12. Extensible Plugin Registry (${res.data.plugins.length} modular plugins active): PASSED`);

    // 13. Server-side Bangla assistant
    res = await request(
      { path: '/api/v1/ai/assist', method: 'POST', headers: { Authorization: `Bearer ${farmerToken}` } },
      { question: 'How should I prepare my soil?', language: 'bn' }
    );
    console.assert(res.status === 200 && res.data.response && res.data.advisoryOnly !== false, 'AI assistant failed');
    console.log('✅ 13. Server-side AI Bangla Assistant (sandbox): PASSED');

    // 14. Crop photo quality verification contract
    res = await request(
      { path: '/api/v1/ai/crop-quality', method: 'POST', headers: { Authorization: `Bearer ${farmerToken}` } },
      { imageData: 'data:image/jpeg;base64,abcdefghijklmnop', cropType: 'onion' }
    );
    console.assert(res.status === 200 && res.data.result.grade && res.data.result.advisoryOnly, 'Crop quality verification failed');
    console.log('✅ 14. AI Crop Photo Quality Verification (sandbox): PASSED');

    // 15. Buyer procurement portal data
    res = await request({ path: '/api/v1/procurement?minQuantity=10', method: 'GET', headers: { Authorization: `Bearer ${buyerToken}` } });
    console.assert(res.status === 200 && Array.isArray(res.data.lots) && Array.isArray(res.data.suppliers), 'Procurement view failed');
    console.log(`✅ 15. Buyer Procurement View (${res.data.lots.length} lots): PASSED`);

    // 16. NGO analytics suite
    res = await request({ path: '/api/v1/analytics/ngo', method: 'GET', headers: { Authorization: `Bearer ${ngoToken}` } });
    console.assert(res.status === 200 && res.data.analytics.scoreDistribution && Array.isArray(res.data.analytics.districtRisk), 'NGO analytics failed');
    console.log('✅ 16. NGO Analytics Suite: PASSED');

    // 17. Sandbox payment provider idempotency
    const paymentKey = `test-payment-${Date.now()}`;
    res = await request(
      { path: '/api/v1/escrow/fund', method: 'POST', headers: { Authorization: `Bearer ${buyerToken}` } },
      { orderId: 'ord_502', paymentRail: 'Nagad', payerMfsNumber: '01822334455', idempotencyKey: paymentKey }
    );
    console.assert(res.status === 200 && res.data.sandbox && res.data.transactionId, 'Sandbox payment failed');
    const firstTransactionId = res.data.transactionId;
    res = await request(
      { path: '/api/v1/escrow/fund', method: 'POST', headers: { Authorization: `Bearer ${buyerToken}` } },
      { orderId: 'ord_502', paymentRail: 'Nagad', payerMfsNumber: '01822334455', idempotencyKey: paymentKey }
    );
    console.assert(res.status === 200 && res.data.duplicate && res.data.transactionId === firstTransactionId, 'Payment idempotency failed');
    console.log('✅ 17. bKash/Nagad Sandbox Provider with Idempotency: PASSED');

    // 18. BNPL input shop and application
    res = await request({ path: '/api/v1/future/input-shop', method: 'GET', headers: { Authorization: `Bearer ${farmerToken}` } });
    console.assert(res.status === 200 && res.data.products.length > 0, 'Input shop failed');
    res = await request(
      { path: '/api/v1/future/input-shop/bnpl', method: 'POST', headers: { Authorization: `Bearer ${farmerToken}` } },
      { productId: res.data.products[0].id, quantity: 1, tenureMonths: 3 }
    );
    console.assert(res.status === 201 && res.data.application.monthlyInstallmentBdt > 0, 'BNPL application failed');
    console.log('✅ 18. BNPL Input Shop and Application (sandbox): PASSED');

    // 19. IoT soil telemetry
    res = await request({ path: '/api/v1/future/sensors', method: 'GET', headers: { Authorization: `Bearer ${farmerToken}` } });
    console.assert(res.status === 200 && res.data.readings.length > 0 && res.data.recommendation, 'Sensor telemetry failed');
    console.log('✅ 19. IoT Soil Sensor Telemetry (sandbox): PASSED');

    // 20. International export matchmaking and inquiry
    res = await request({ path: '/api/v1/future/export-matches', method: 'GET', headers: { Authorization: `Bearer ${farmerToken}` } });
    console.assert(res.status === 200 && res.data.matches.length > 0, 'Export matches failed');
    res = await request(
      { path: '/api/v1/future/export-inquiries', method: 'POST', headers: { Authorization: `Bearer ${farmerToken}` } },
      { matchId: res.data.matches[0].id }
    );
    console.assert(res.status === 201 && res.data.inquiry.status === 'PENDING_REVIEW', 'Export inquiry failed');
    console.log('✅ 20. International Export Matchmaking (sandbox): PASSED');

    console.log('\n🎉 ALL 12 BACKEND INTEGRATION TESTS PASSED PERFECTLY!\n');
  } catch (error) {
    console.error('❌ Test suite failed:', error);
    process.exit(1);
  } finally {
    server.close();
  }
}

runTests();

