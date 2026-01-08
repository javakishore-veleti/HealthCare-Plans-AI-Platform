// =============================================================================
// Initialize MongoDB Databases for All Components
// =============================================================================

// Switch to admin and create users
db = db.getSiblingDB('admin');

// Plans Service
db = db.getSiblingDB('plans_db');
db.createUser({
  user: 'plans_user',
  pwd: 'plans_password',
  roles: [{ role: 'readWrite', db: 'plans_db' }]
});

// Customer Onboarding Service
db = db.getSiblingDB('customer_db');
db.createUser({
  user: 'customer_user',
  pwd: 'customer_password',
  roles: [{ role: 'readWrite', db: 'customer_db' }]
});

// Order Service
db = db.getSiblingDB('order_db');
db.createUser({
  user: 'order_user',
  pwd: 'order_password',
  roles: [{ role: 'readWrite', db: 'order_db' }]
});

// AI Gateway Service (conversation history, etc.)
db = db.getSiblingDB('ai_gateway_db');
db.createUser({
  user: 'ai_gateway_user',
  pwd: 'ai_gateway_password',
  roles: [{ role: 'readWrite', db: 'ai_gateway_db' }]
});

print('MongoDB initialization completed');