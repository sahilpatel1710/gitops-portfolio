const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || '1.0.0';
const ENVIRONMENT = process.env.ENVIRONMENT || 'development';

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint - required for Kubernetes
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Readiness check endpoint
app.get('/ready', (req, res) => {
  res.status(200).json({
    status: 'ready',
    timestamp: new Date().toISOString()
  });
});

// Main API endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'GitOps Sample API',
    version: VERSION,
    environment: ENVIRONMENT,
    timestamp: new Date().toISOString()
  });
});

// API info endpoint
app.get('/api/info', (req, res) => {
  res.json({
    name: 'GitOps Sample API',
    version: VERSION,
    environment: ENVIRONMENT,
    kubernetes: {
      podName: process.env.POD_NAME || 'unknown',
      nodeName: process.env.NODE_NAME || 'unknown',
      namespace: process.env.POD_NAMESPACE || 'unknown'
    }
  });
});

// Demo endpoint - returns list of items
app.get('/api/items', (req, res) => {
  res.json({
    items: [
      { id: 1, name: 'ArgoCD', category: 'GitOps' },
      { id: 2, name: 'Terraform', category: 'IaC' },
      { id: 3, name: 'Kubernetes', category: 'Orchestration' },
      { id: 4, name: 'OPA', category: 'Policy' }
    ]
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 GitOps Sample API running on port ${PORT}`);
  console.log(`📦 Version: ${VERSION}`);
  console.log(`🌍 Environment: ${ENVIRONMENT}`);
});

module.exports = app;
