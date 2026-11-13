const express = require('express');
const cors = require('cors');
const Sentry = require('@sentry/node');
const config = require('./src/config');
const errorHandler = require('./src/middleware/errorHandler');

if (process.env.SENTRY_DSN) {
  Sentry.init({ dsn: process.env.SENTRY_DSN });
}

// Route imports
const authRoutes = require('./src/modules/auth/authRoutes');
const marketplaceRoutes = require('./src/modules/marketplace/marketplaceRoutes');
const ordersRoutes = require('./src/modules/orders/ordersRoutes');
const escrowRoutes = require('./src/modules/escrow/escrowRoutes');
const microfinanceRoutes = require('./src/modules/microfinance/microfinanceRoutes');
const traceabilityRoutes = require('./src/modules/traceability/traceabilityRoutes');
const weatherRoutes = require('./src/modules/weather/weatherRoutes');
const chatRoutes = require('./src/modules/chat/chatRoutes');
const analyticsRoutes = require('./src/modules/analytics/analyticsRoutes');
const pluginsRoutes = require('./src/modules/plugins/pluginsRoutes');
const procurementRoutes = require('./src/modules/marketplace/procurementRoutes');
const aiRoutes = require('./src/modules/ai/aiRoutes');
const futureRoutes = require('./src/modules/future/futureRoutes');
const uploadRoutes = require('./src/modules/uploads/uploadRoutes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging in development
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Mount V1 API Routes
const v1 = express.Router();
v1.use('/auth', authRoutes);
v1.use('/marketplace', marketplaceRoutes);
v1.use('/orders', ordersRoutes);
v1.use('/escrow', escrowRoutes);
v1.use('/microfinance', microfinanceRoutes);
v1.use('/traceability', traceabilityRoutes);
v1.use('/weather', weatherRoutes);
v1.use('/chat', chatRoutes);
v1.use('/analytics', analyticsRoutes);
v1.use('/plugins', pluginsRoutes);
v1.use('/procurement', procurementRoutes);
v1.use('/ai', aiRoutes);
v1.use('/future', futureRoutes);

app.use(config.apiPrefix, v1);
app.use('/uploads', uploadRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Resource ${req.originalUrl} not found on Agro-Bridge API.`
  });
});

// Centralized error handler
app.use(errorHandler);

// Start server
if (process.env.NODE_ENV !== 'test') {
  app.listen(config.port, () => {
    console.log(`=======================================================`);
    console.log(`🌾 Agro-Bridge Backend API running on port ${config.port}`);
    console.log(`📡 Base URL: http://localhost:${config.port}${config.apiPrefix}`);
    console.log(`🩺 Health check: http://localhost:${config.port}/health`);
    console.log(`=======================================================`);
  });
}

module.exports = app;
