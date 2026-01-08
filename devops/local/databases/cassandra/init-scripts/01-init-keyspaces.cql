-- =============================================================================
-- Initialize Cassandra Keyspaces for All Components
-- =============================================================================

-- Plans Service
CREATE KEYSPACE IF NOT EXISTS plans_ks
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- Customer Onboarding Service
CREATE KEYSPACE IF NOT EXISTS customer_ks
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- Order Service
CREATE KEYSPACE IF NOT EXISTS order_ks
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- AI Gateway Service
CREATE KEYSPACE IF NOT EXISTS ai_gateway_ks
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

-- ETL Pipeline
CREATE KEYSPACE IF NOT EXISTS etl_ks
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};